import 'package:flutter/foundation.dart';
import '../../standings/models/game_model.dart';
import '../models/report_response.dart';
import '../models/report_request.dart';
import '../models/analysis_envelope_model.dart';
import '../services/game_report_service.dart';
import '../views/widgets/chat_interface.dart';

/// Controller for the Game Reports micro-app.
/// Orchestrates report generation, manages loading states, and handles cloud limits via GameReportService.
class GameReportController extends ChangeNotifier {
  final GameReportService _service = GameReportService();

  // State
  bool _isLoading = false;
  String? _error;
  ReportResponse? _currentReport;
  int _remainingCloudReports = 0; // Initialize securely, update in init
  Game? _selectedGame;
  ReportStyle _selectedStyle = ReportStyle.casual;
  
  // New: Analysis envelope and chat
  AnalysisEnvelope? _currentEnvelope;
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReportResponse? get currentReport => _currentReport;
  int get remainingCloudReports => _remainingCloudReports;
  Game? get selectedGame => _selectedGame;
  ReportStyle get selectedStyle => _selectedStyle;
  bool get canUseCloud => _remainingCloudReports > 0;
  /// AI is always "ready" since we use cloud + templates now
  bool get isModelReady => true;
  AnalysisEnvelope? get currentEnvelope => _currentEnvelope;
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  bool get isChatLoading => _isChatLoading;

  /// Initialize the controller and load cloud usage quota.
  Future<void> init() async {
    await _refreshCloudQuota();
  }

  /// Check if AI article generation is available.
  Future<bool> isAiAvailable() async {
    return await _service.isAiAvailable();
  }

  /// Refresh the cloud reports remaining count.
  Future<void> _refreshCloudQuota() async {
    _remainingCloudReports = await _service.getRemainingCloudReports();
    notifyListeners();
  }

  /// Select a game to generate a report for.
  void selectGame(Game game) {
    _selectedGame = game;
    _currentReport = null;
    _error = null;
    notifyListeners();
  }

  /// Change the report style.
  void setStyle(ReportStyle style) {
    if (_selectedStyle != style) {
      _selectedStyle = style;
      // If we already have a report, regenerate with new style
      if (_selectedGame != null && _currentReport != null) {
        generateReport(useCloud: _currentReport!.isCloudEnhanced);
      } else {
        notifyListeners();
      }
    }
  }

  /// Generate a report for the selected game.
  /// Set [useCloud] to true for cloud-enhanced report (subject to quota).
  Future<void> generateReport({bool useCloud = false}) async {
    if (_selectedGame == null) {
      _error = 'No game selected';
      notifyListeners();
      return;
    }

    if (!_selectedGame!.isPlayed) {
      _error = 'Cannot generate recap for unplayed game';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentReport = await _service.generateReport(
        game: _selectedGame!,
        style: _selectedStyle,
        useCloud: useCloud,
      );
      
      // Update quota locally after generation
      if (useCloud) {
        await _refreshCloudQuota();
      }
      
    } catch (e) {
      _error = 'Failed to generate report: $e';
      debugPrint('GameReportController.generateReport error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the current report and selection.
  void clearReport() {
    _currentReport = null;
    _selectedGame = null;
    _error = null;
    notifyListeners();
  }

  /// Cleanup old rate limit entries.
  Future<void> cleanup() async {
    await _service.cleanup();
  }

  // ==================== NEW: Envelope & Chat Methods ====================

  /// Fetch the analysis envelope for the selected game from cloud function.
  Future<void> fetchAnalysisEnvelope() async {
    if (_selectedGame == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentEnvelope = await _service.fetchAnalysisEnvelope(
        gameId: _selectedGame!.gameId,
        season: _selectedGame!.season,
        week: _selectedGame!.week,
      );

      if (_currentEnvelope == null) {
        debugPrint('No envelope returned, using local data only');
      }
    } catch (e) {
      debugPrint('Failed to fetch envelope: $e');
      // Continue without envelope - local generation still works
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle voice input transcript.
  Future<void> handleVoiceInput(String transcript) async {
    await sendChatMessage(transcript);
  }

  /// Handle quick action button press.
  Future<void> handleQuickAction(String prompt) async {
    await sendChatMessage(prompt);
  }

  /// Send a chat message and generate a response.
  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _chatMessages.add(ChatMessage(text: message, isUser: true));
    _isChatLoading = true;
    notifyListeners();

    try {
      // Generate response using Service
      final response = await _service.generateConversationalResponse(
        userMessage: message,
        selectedGame: _selectedGame,
        currentEnvelope: _currentEnvelope,
      );
      
      _chatMessages.add(ChatMessage(text: response, isUser: false));
      
      // Update quota if intent used cloud resources (this is a bit tricky since the service handles it, but we need to reflect it in UI)
      // For now, let's just refresh whenever we do something that might use quota
      await _refreshCloudQuota();
      
    } catch (e) {
      _chatMessages.add(ChatMessage(
        text: 'Sorry, I couldn\'t process that. Try again?',
        isUser: false,
      ));
      debugPrint('Chat error: $e');
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  /// Clear chat history.
  void clearChat() {
    _chatMessages.clear();
    notifyListeners();
  }
}
