import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../services/team_service.dart';
import '../../services/settings_service.dart';
import '../../theme/t4l_theme.dart';

class TeamSelectorDialog extends StatelessWidget {
  const TeamSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = TeamService().getTeams();
    final settings = Provider.of<SettingsService>(context);
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SELECT YOUR TEAM',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final isSelected = settings.selectedTeam?.id == team.id;

                  return GestureDetector(
                    onTap: () {
                      settings.setFavoriteTeam(team);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? team.primaryColor.withValues(alpha: 0.2)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? team.primaryColor
                              : (isDark ? Colors.white10 : Colors.black12),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white : Colors.transparent,
                        ),
                        child: Image.asset(
                          team.logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.error_outline,
                                color: isDark ? Colors.black26 : Colors.grey,
                                size: 20,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
