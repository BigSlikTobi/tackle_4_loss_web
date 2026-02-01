import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Widget for voice input with animated mic button.
/// Uses speech_to_text for native language recognition.
class VoiceInputWidget extends StatefulWidget {
  final ValueChanged<String> onResult;
  final VoidCallback? onListeningStarted;
  final VoidCallback? onListeningStopped;

  const VoiceInputWidget({
    super.key,
    required this.onResult,
    this.onListeningStarted,
    this.onListeningStopped,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _partialResult = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        _stopListening();
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _stopListening();
        }
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Voice input not available on this device')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _partialResult = '';
    });

    _pulseController.repeat(reverse: true);
    widget.onListeningStarted?.call();

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
      ),
      localeId: 'en_US', // Can be made dynamic based on user locale
    );
  }

  void _stopListening() async {
    await _speech.stop();
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _isListening = false;
    });

    widget.onListeningStopped?.call();

    // Submit final result
    if (_partialResult.isNotEmpty) {
      widget.onResult(_partialResult);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _partialResult = result.recognizedWords;
    });

    if (result.finalResult) {
      widget.onResult(result.recognizedWords);
      _stopListening();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show partial transcript while listening
        if (_isListening && _partialResult.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _partialResult,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

        // Mic button with pulse animation
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isListening ? _pulseAnimation.value : 1.0,
              child: FloatingActionButton(
                heroTag: 'voice_input_fab',
                onPressed: _isListening ? _stopListening : _startListening,
                backgroundColor: _isListening
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        Text(
          _isListening ? 'Listening...' : 'Tap to speak',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
