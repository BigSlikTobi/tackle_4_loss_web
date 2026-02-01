import 'package:flutter/material.dart';
import '../../../micro_apps/game_reports/services/function_gemma_service.dart';

/// Dialog shown when installing an app that requires a model download.
/// Displays progress and handles download flow.
class ModelDownloadDialog extends StatefulWidget {
  final String appName;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const ModelDownloadDialog({
    super.key,
    required this.appName,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<ModelDownloadDialog> createState() => _ModelDownloadDialogState();
}

class _ModelDownloadDialogState extends State<ModelDownloadDialog> {
  final FunctionGemmaService _gemmaService = FunctionGemmaService();

  double _progress = 0.0;
  bool _isDownloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      await _gemmaService.downloadModel(
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );

      // Download complete
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Download failed: $e';
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Installing ${widget.appName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startDownload,
              child: const Text('Retry'),
            ),
          ] else ...[
            const Icon(Icons.downloading, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Downloading AI Model',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This enables local AI processing\n(~300MB, one-time download)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toStringAsFixed(0)}%'),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading || _error != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCancel();
            },
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}
