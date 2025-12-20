import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../services/team_service.dart';
import '../../services/settings_service.dart';
import '../../models/team_model.dart';

class TeamSelectorDialog extends StatelessWidget {
  const TeamSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = TeamService().getTeams();
    final settings = Provider.of<SettingsService>(context);

    return Dialog(
      backgroundColor: AppColors.surface,
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
            const Text(
              'SELECT YOUR TEAM',
              style: TextStyle(
                color: AppColors.textPrimary,
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
                            ? team.primaryColor.withOpacity(0.2) 
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? team.primaryColor : Colors.white10,
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        team.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.error_outline,
                          color: Colors.white24,
                          size: 20,
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
                child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
