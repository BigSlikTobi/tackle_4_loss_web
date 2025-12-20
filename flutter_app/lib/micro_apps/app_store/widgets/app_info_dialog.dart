import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/micro_app.dart';
import '../../../design_tokens.dart';
import '../../../core/utils/localization_utils.dart';

class AppInfoDialog extends StatelessWidget {
  final MicroApp app;

  const AppInfoDialog({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(app.name, style: AppTextStyles.h2),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<String>(
                future: app.descriptionAsset.isEmpty 
                  ? Future.value("No description available.")
                  : rootBundle.loadString(app.descriptionAsset).catchError((_) => "Failed to load description."),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Localization Logic (Delegated to Utility)
                  final rawContent = snapshot.data ?? 'No description.';
                  final locale = Localizations.localeOf(context).languageCode;
                  final localizedContent = LocalizationUtils.extractLocalizedMarkdownDescription(rawContent, locale);

                  return Markdown(
                    data: localizedContent,
                    styleSheet: MarkdownStyleSheet(
                      p: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      h1: AppTextStyles.h1,
                      h2: AppTextStyles.h2,
                      h3: AppTextStyles.h3,
                      strong: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
