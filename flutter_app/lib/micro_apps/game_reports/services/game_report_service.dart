import 'package:flutter/foundation.dart';
import '../../standings/models/game_model.dart';
import '../models/report_request.dart';
import '../models/report_response.dart';
import '../models/analysis_envelope_model.dart';
import '../services/cloud_report_limiter.dart';
import '../services/function_executor.dart';
import '../services/game_analysis_service.dart';
import '../services/intent_detector.dart';
import '../services/team_article_service.dart';

/// Service to handle business logic for Game Reports.
class GameReportService {
  final FunctionExecutor _executor = FunctionExecutor();
  final CloudReportLimiter _limiter = CloudReportLimiter();
  final GameAnalysisService _analysisService = GameAnalysisService();
  final TeamArticleService _articleService = TeamArticleService();

  /// Check if AI article generation is available.
  Future<bool> isAiAvailable() async {
    return await _articleService.isAvailable() &&
        await _limiter.canUseCloudEnhancement();
  }

  /// Get remaining cloud reports for today.
  Future<int> getRemainingCloudReports() async {
    return await _limiter.getRemainingToday();
  }

  /// Cleanup old rate limit entries.
  Future<void> cleanup() async {
    await _limiter.cleanupOldEntries();
  }

  /// Generate a report for the game.
  Future<ReportResponse> generateReport({
    required Game game,
    required ReportStyle style,
    required bool useCloud,
  }) async {
    final request = ReportRequest(
      gameId: game.gameId,
      focusTeam: null,
      style: style,
      useCloudEnhancement: useCloud,
    );

    // Generate the base report locally
    var report = _executor.generateGameRecap(game, request);

    // Optionally enhance with cloud if requested and quota available
    if (useCloud) {
      if (await _limiter.canUseCloudEnhancement()) {
        report = await _enhanceWithCloud(report, request);
        await _limiter.recordCloudUsage();
      } else {
        debugPrint('Cloud enhancement quota exhausted');
      }
    }

    return report;
  }

  /// Enhance a report using cloud Gemini API.
  Future<ReportResponse> _enhanceWithCloud(
    ReportResponse localReport,
    ReportRequest request,
  ) async {
    // TODO: Implement actual cloud Gemini enhancement
    // For now, we'll simulate by adding a marker and slightly modifying the report
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call

    return ReportResponse(
      gameId: localReport.gameId,
      awayTeam: localReport.awayTeam,
      homeTeam: localReport.homeTeam,
      awayScore: localReport.awayScore,
      homeScore: localReport.homeScore,
      headline: localReport.headline,
      body:
          '${localReport.body}\n\n*This report was enhanced with AI analysis.*',
      highlights: localReport.highlights,
      isCloudEnhanced: true,
      generatedAt: DateTime.now(),
    );
  }

  /// Fetch the analysis envelope for the selected game.
  Future<AnalysisEnvelope?> fetchAnalysisEnvelope({
    required String gameId,
    required int season,
    required int week,
  }) async {
    return await _analysisService.fetchEnvelope(
      gameId: gameId,
      season: season,
      week: week,
    );
  }

  /// Generate a response utilizing intent detection.
  Future<String> generateConversationalResponse({
    required String userMessage,
    required Game? selectedGame,
    required AnalysisEnvelope? currentEnvelope,
  }) async {
    if (selectedGame == null) {
      return 'Please select a game first to get insights.';
    }

    // 1. Detect intent
    final intent = IntentDetector.detectIntent(userMessage);
    debugPrint('Detected intent: $intent');

    // 2. For AI article requests, try cloud generation first
    if (intent == 'get_team_article' &&
        await _limiter.canUseCloudEnhancement()) {
      debugPrint('Trying AI article generation...');
      final aiText = await _articleService.generateArticle(
        teamCode: selectedGame.homeTeam,
        gameId: selectedGame.gameId,
        style: 'recap',
      );

      if (aiText != null) {
        debugPrint('AI article generated successfully');
        await _limiter.recordCloudUsage();
        return aiText;
      }
      debugPrint('AI article failed, falling back to template');
    }

    // 3. Execute the detected function
    return _executeIntent(intent, selectedGame, currentEnvelope);
  }

  /// Execute the detected intent and return formatted response.
  String _executeIntent(String intent, Game game, AnalysisEnvelope? envelope) {
    debugPrint('Executing intent: $intent');

    switch (intent) {
      case 'get_game_recap':
        return _executeGetGameRecap(game);
      case 'get_stats_breakdown':
        return _executeGetStatsBreakdown(game, envelope);
      case 'get_player_highlights':
        return _executeGetPlayerHighlights(envelope);
      case 'get_mvp_analysis':
        return _executeGetMvpAnalysis(game, envelope);
      case 'get_team_article':
        // Fallback if AI generation failed or quota exhausted
        return _executeGetGameRecap(game);
      default:
        return _executeGetGameRecap(game);
    }
  }

  String _executeGetGameRecap(Game game) {
    final request = ReportRequest(
      gameId: game.gameId,
      style: ReportStyle.casual,
      useCloudEnhancement: false,
    );

    try {
      final report = _executor.generateGameRecap(game, request);
      return '${report.headline}\n\n${report.body}';
    } catch (e) {
      return _generateFallbackResponse('recap', game);
    }
  }

  String _executeGetStatsBreakdown(Game game, AnalysisEnvelope? envelope) {
    final buffer = StringBuffer();

    buffer.writeln('📊 **Game Statistics**');
    buffer.writeln();
    buffer.writeln(
      '**Final Score:** ${game.awayTeam} ${game.awayScore} @ ${game.homeTeam} ${game.homeScore}',
    );
    buffer.writeln(
      '**Total Points:** ${(game.awayScore ?? 0) + (game.homeScore ?? 0)}',
    );
    buffer.writeln(
      '**Point Margin:** ${((game.awayScore ?? 0) - (game.homeScore ?? 0)).abs()}',
    );
    buffer.writeln('**Week:** ${game.week} | **Season:** ${game.season}');

    if (game.isOvertime) {
      buffer.writeln('**Overtime:** Yes');
    }
    if (game.stadium != null) {
      buffer.writeln('**Stadium:** ${game.stadium}');
    }
    if (game.temp != null) {
      buffer.writeln('**Temperature:** ${game.temp}°F');
    }
    if (game.referee != null) {
      buffer.writeln('**Referee:** ${game.referee}');
    }

    // Add insights from envelope if available
    if (envelope != null) {
      buffer.writeln();
      buffer.writeln('**Team Performance:**');
      for (final entry in envelope.teamSummaries.entries) {
        final team = entry.value;
        buffer.writeln(
          '• ${entry.key}: ${team.totalYards} yards, ${team.turnovers} turnovers',
        );
      }
    }

    return buffer.toString();
  }

  String _executeGetPlayerHighlights(AnalysisEnvelope? envelope) {
    final buffer = StringBuffer();
    buffer.writeln('🌟 **Key Player Performances**');
    buffer.writeln();

    if (envelope != null && envelope.playerMap.isNotEmpty) {
      final topPlayers = envelope.playerMap.values.toList()
        ..sort((a, b) => b.impactScore.compareTo(a.impactScore));

      for (final player in topPlayers.take(5)) {
        buffer.writeln(
          '**${player.name}** (${player.position}, ${player.team})',
        );
        buffer.writeln(player.statLine);
        buffer.writeln();
      }
    } else {
      buffer.writeln('Player stats not available for this game.');
      buffer.writeln(
        'Try selecting a different game or ensure the Game Analysis Package is configured.',
      );
    }

    return buffer.toString();
  }

  String _executeGetMvpAnalysis(Game game, AnalysisEnvelope? envelope) {
    final buffer = StringBuffer();
    buffer.writeln('🏆 **MVP Analysis**');
    buffer.writeln();

    if (envelope != null && envelope.playerMap.isNotEmpty) {
      final mvp = envelope.playerMap.values.reduce(
        (a, b) => a.impactScore > b.impactScore ? a : b,
      );

      buffer.writeln('**MVP:** ${mvp.name}');
      buffer.writeln('**Position:** ${mvp.position}');
      buffer.writeln('**Team:** ${mvp.team}');
      buffer.writeln('**Stats:** ${mvp.statLine}');
      buffer.writeln('**Impact Score:** ${mvp.impactScore.toStringAsFixed(1)}');
    } else {
      buffer.writeln(
        'Based on the final score (${game.awayTeam} ${game.awayScore} - ${game.homeTeam} ${game.homeScore}):',
      );
      buffer.writeln();
      buffer.writeln(
        'The MVP likely came from ${game.winner ?? game.homeTeam}.',
      );
      buffer.writeln(
        'For detailed player analysis, ensure the Game Analysis Package is configured.',
      );
    }

    return buffer.toString();
  }

  String _generateFallbackResponse(String userMessage, Game game) {
    final messageLower = userMessage.toLowerCase();

    if (messageLower.contains('recap') || messageLower.contains('summary')) {
      return 'The ${game.winner ?? game.homeTeam} ${game.winner != null ? 'won' : 'played'} '
          '${game.awayScore}-${game.homeScore} in Week ${game.week}. '
          'Select "Enhance with AI" for a detailed analysis.';
    }

    if (messageLower.contains('mvp') || messageLower.contains('best player')) {
      return 'For MVP insights, try the cloud-enhanced report which analyzes player performances.';
    }

    if (messageLower.contains('stats') || messageLower.contains('numbers')) {
      return 'Final score: ${game.awayTeam} ${game.awayScore}, ${game.homeTeam} ${game.homeScore}. '
          'Enable the AI assistant for detailed stats breakdown.';
    }

    return 'The ${game.awayTeam} ${(game.awayScore ?? 0) > (game.homeScore ?? 0) ? 'defeated' : 'lost to'} '
        'the ${game.homeTeam} ${game.awayScore}-${game.homeScore} in Week ${game.week}.';
  }
}
