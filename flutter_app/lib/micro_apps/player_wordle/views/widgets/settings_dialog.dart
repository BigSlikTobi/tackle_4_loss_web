import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/player_wordle_controller.dart';
import '../../models/game_state.dart';

class PlayerWordleSettingsDialog extends StatelessWidget {
  const PlayerWordleSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayerWordleController>();
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

  Widget _buildDifficultyOption(
    BuildContext context,
    PlayerWordleController controller,
    Difficulty difficulty,
    String label,
    String description,
    IconData icon,
  ) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isSelected = controller.selectedDifficulty == difficulty;
    final isUnlocked = controller.isDifficultyUnlocked(difficulty);
    final color = isSelected
        ? colors.brand
        : (isUnlocked
            ? colors.textPrimary
            : colors.textSecondary.withValues(alpha: 0.5));

    return InkWell(
      onTap: isUnlocked ? () => controller.setDifficulty(difficulty) : null,
      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space2, horizontal: AppSpacing.space2),
        margin: const EdgeInsets.only(bottom: AppSpacing.space1),
        decoration: BoxDecoration(
          color: isSelected ? colors.brand.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          border: isSelected ? Border.all(color: colors.brand) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: isUnlocked
                          ? colors.textSecondary
                          : colors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.brand, size: 20)
            else if (!isUnlocked)
              Icon(Icons.lock, color: colors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
