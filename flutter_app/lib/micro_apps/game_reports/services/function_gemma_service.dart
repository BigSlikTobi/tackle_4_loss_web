import 'package:flutter/foundation.dart';

/// MVP stub: the Game Reports MicroApp is flag-off and the `flutter_gemma`
/// package has been removed from pubspec to drop the TensorFlowLiteSelectTfOps
/// iOS dependency. The public API surface is preserved so
/// [ModelDownloadDialog] and any future caller still compile; every method
/// short-circuits until flutter_gemma is re-added.
class FunctionGemmaService {
  static final FunctionGemmaService _instance =
      FunctionGemmaService._internal();
  factory FunctionGemmaService() => _instance;
  FunctionGemmaService._internal();

  bool get isModelReady => false;

  static const String modelUrl =
      'https://huggingface.co/sasha-denisov/function-gemma-270M-it/resolve/main/functiongemma-270M-it.task';

  static void initializePlugin() {
    // No-op. See class doc.
  }

  Future<bool> isModelInstalled() async => false;

  Future<void> init() async {
    // No-op.
  }

  Future<void> refreshModelState() async {
    // No-op.
  }

  Future<void> downloadModel({
    required Function(double progress) onProgress,
  }) async {
    throw UnsupportedError(
      'FunctionGemmaService is stubbed for MVP. Re-add flutter_gemma to '
      'pubspec and restore the real implementation before shipping Game '
      'Reports.',
    );
  }

  Future<String?> generateResponse(
    String prompt, {
    List<Object?>? tools,
  }) async {
    debugPrint('FunctionGemmaService.generateResponse called on MVP stub');
    return null;
  }

  Future<void> dispose() async {
    // No-op.
  }

  @visibleForTesting
  Future<void> closeChatSession() async {
    // Exposed for tests; stub is idempotent.
  }
}
