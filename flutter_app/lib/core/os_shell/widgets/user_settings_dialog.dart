import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../../design_tokens.dart';
import '../../services/settings_service.dart';
import 'team_selector_dialog.dart';

class UserSettingsDialog extends StatelessWidget {
  const UserSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsService>(context);
    final isDark = settings.isDarkMode;

    // Dynamic Colors
    final bgColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final containerColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsTitle,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.settingsLanguage,
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              label: 'English',
              langCode: 'en',
              isSelected: settings.locale.languageCode == 'en',
              onTap: () {
                settings.setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: 'Deutsch',
              langCode: 'de',
              isSelected: settings.locale.languageCode == 'de',
              onTap: () {
                settings.setLocale(const Locale('de'));
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
            Text(
              'APPEARANCE',
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: settings.isDarkMode,
                    onChanged: (value) => settings.toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'YOUR TEAM',
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      settings.selectedTeam?.logoUrl ?? 'assets/logos/nfl_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      settings.selectedTeam?.name ?? 'No Team Selected',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const TeamSelectorDialog(),
                      );
                    },
                    child: const Text('CHANGE', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.settingsClose, style: const TextStyle(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String langCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.langCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final isDark = settings.isDarkMode;
    
    // Dynamic Colors
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? textColor : subTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
