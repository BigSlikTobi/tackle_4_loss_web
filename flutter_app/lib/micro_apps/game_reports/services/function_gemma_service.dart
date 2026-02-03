import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// Service responsible for managing the local FunctionGemma model.
/// Handles initialization, model downloading/checking, and inference.
class FunctionGemmaService {
  static final FunctionGemmaService _instance =
      FunctionGemmaService._internal();
  factory FunctionGemmaService() => _instance;
  FunctionGemmaService._internal();

  bool _isInitialized = false;
  bool _isModelDownloaded = false;
  InferenceModel? _model;
  InferenceChat? _chatSession;

  bool get isModelReady =>
      _isInitialized && _isModelDownloaded && _model != null;

  /// Model download URL for FunctionGemma
  static const String modelUrl =
      'https://huggingface.co/sasha-denisov/function-gemma-270M-it/resolve/main/functiongemma-270M-it.task';

  /// Initialize the flutter_gemma plugin (call once at app start).
  static void initializePlugin() {
    FlutterGemma.initialize(
      maxDownloadRetries: 5,
    );
  }

  /// Check if the model is already installed.
  Future<bool> isModelInstalled() async {
    try {
      // The method expects a String (model type name), not the enum
      final result =
          await FlutterGemma.isModelInstalled(ModelType.functionGemma.name);
      debugPrint('FlutterGemma.isModelInstalled returned: $result');
      return result;
    } catch (e) {
      debugPrint('Error checking model installation: $e');
      return false;
    }
  }

  /// Initialize the service by trying to load the model.
  Future<void> init() async {
    debugPrint('FunctionGemmaService.init: Attempting to load model...');
    await _tryLoadModel();
  }

  /// Refresh the model state - call this after model download completes elsewhere.
  Future<void> refreshModelState() async {
    debugPrint('FunctionGemmaService: Refreshing model state...');
    await _tryLoadModel();
    debugPrint('FunctionGemmaService: isModelReady = $isModelReady');
  }

  /// Try to load the model directly - if it succeeds, we know it's installed.
  Future<void> _tryLoadModel() async {
    if (_model != null) {
      debugPrint('Model already loaded');
      return;
    }

    try {
      debugPrint('Attempting to get active model...');
      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );
      _isModelDownloaded = true;
      _isInitialized = true;
      debugPrint('FunctionGemma model loaded successfully! Model: $_model');
    } catch (e) {
      debugPrint('Could not load model (may not be installed): $e');
      _isModelDownloaded = false;
      _isInitialized = false;
    }
  }

  /// Download and install the FunctionGemma model.
  Future<void> downloadModel({
    required Function(double progress) onProgress,
  }) async {
    if (_isModelDownloaded) return;

    try {
      await FlutterGemma.installModel(
        modelType: ModelType.functionGemma,
      )
          .fromNetwork(
        modelUrl,
      )
          .withProgress((progress) {
        // progress is an int representing percentage (0-100)
        onProgress(progress / 100);
      }).install();

      // Model downloaded, now try to load it
      await _tryLoadModel();
    } catch (e) {
      debugPrint('Model download failed: $e');
      rethrow;
    }
  }

  /// Generate a response from the model using function calling.
  /// [tools] are the function definitions to provide to the model.
  Future<String?> generateResponse(String prompt, {List<Tool>? tools}) async {
    // Auto-refresh state if model isn't ready but might be installed
    if (!isModelReady) {
      debugPrint('Model not ready, refreshing state...');
      await refreshModelState();
    }

    if (!isModelReady || _model == null) {
      debugPrint(
          'Model still not ready after refresh. isModelReady=$isModelReady, model=$_model');
      return null;
    }

    try {
      await _closeChatSession();

      // Create a new chat session for each request
      _chatSession = await _model!.createChat(
        tools: tools ?? [],
        supportsFunctionCalls: true,
      );

      // Add user query
      await _chatSession!.addQueryChunk(Message.text(
        text: prompt,
        isUser: true,
      ));

      // Generate response (returns sealed ModelResponse, pattern match to extract)
      final response = await _chatSession!.generateChatResponse();

      // Handle different response types
      return switch (response) {
        TextResponse(token: final text) => text,
        FunctionCallResponse(name: final name, args: final args) =>
          'FUNCTION_CALL:$name:${args.toString()}',
        ThinkingResponse(content: final content) => content,
      };
    } catch (e) {
      debugPrint('Inference error: $e');
      return null;
    } finally {
      await _closeChatSession();
    }
  }

  /// Cleanup resources when the service is no longer needed.
  Future<void> dispose() async {
    await _closeChatSession();
    await _model?.close();
    _chatSession = null;
    _model = null;
    _isInitialized = false;
  }

  Future<void> _closeChatSession() async {
    final session = _chatSession;
    _chatSession = null;
    if (session == null) {
      return;
    }

    try {
      await session.session.close();
    } catch (e) {
      debugPrint('Failed to close chat session: $e');
    }
  }
}
