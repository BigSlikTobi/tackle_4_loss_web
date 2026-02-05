import 'package:flutter/material.dart';

import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';


class PlayerWordleSettingsDialog extends StatelessWidget {
  const PlayerWordleSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = context.watch<PlayerWordleController>();
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.settingsTitle,
                  style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
