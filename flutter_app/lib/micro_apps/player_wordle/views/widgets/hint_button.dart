/// Hint Button widget for the alma mater lifeline.
library;

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../design_tokens.dart';

/// Button to reveal the mystery player's college (alma mater).
class HintButton extends StatelessWidget {
  /// Whether the hint has already been used
  final bool hintUsed;
  
  /// The revealed college name (if hint used)
  final String? revealedHint;
  
  /// Callback when hint is requested
  final VoidCallback onUseHint;

  const HintButton({
    super.key,
    required this.hintUsed,
    this.revealedHint,
    required this.onUseHint,
  });

  @override
  Widget build(BuildContext context) {
    if (hintUsed && revealedHint != null) {
      return _buildRevealedHint(context);
    }
    
    return _buildHintButton(context);
  }

  Widget _buildRevealedHint(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.school,
            color: Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(
            '${l10n.playerWordleStatCollege}: $revealedHint',
            style: const TextStyle(
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightBold,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: onUseHint,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFF59E0B),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
      ),
      icon: const Icon(Icons.lightbulb_outline, size: 18),
      label: Text(
        l10n.playerWordleHint,
        style: const TextStyle(
          fontSize: AppTypography.fontSizeSm,
        ),
      ),
    );
  }
}
