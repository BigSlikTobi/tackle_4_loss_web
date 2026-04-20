import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_model.dart';
import '../../services/settings_service.dart';
import '../../services/team_service.dart';
import '../../theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';

/// Mandatory first-launch flow.
///
/// Two non-dismissible steps — team selection then language confirmation —
/// then writes `onboarding_complete_v1 = true` via [SettingsService] and
/// returns control to the OS Shell. The system back gesture is intercepted
/// (`canPop: false`) so reviewers and users cannot bypass the picker.
class FirstLaunchFlow extends StatefulWidget {
  const FirstLaunchFlow({super.key});

  @override
  State<FirstLaunchFlow> createState() => _FirstLaunchFlowState();
}

enum _OnboardingStep { team, language }

class _FirstLaunchFlowState extends State<FirstLaunchFlow> {
  _OnboardingStep _step = _OnboardingStep.team;
  Team? _pendingTeam;
  Locale? _pendingLocale;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>();
    _pendingTeam = settings.selectedTeam;
    _pendingLocale = settings.locale;
  }

  Future<void> _confirm() async {
    final settings = context.read<SettingsService>();
    if (_pendingTeam != null) {
      await settings.setFavoriteTeam(_pendingTeam!);
    }
    if (_pendingLocale != null) {
      settings.setLocale(_pendingLocale!);
    }
    await settings.markOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: _step == _OnboardingStep.team
                ? _TeamStep(
                    selected: _pendingTeam,
                    onSelect: (team) => setState(() => _pendingTeam = team),
                    onContinue: _pendingTeam == null
                        ? null
                        : () => setState(
                            () => _step = _OnboardingStep.language),
                  )
                : _LanguageStep(
                    selected: _pendingLocale ?? const Locale('en'),
                    onSelect: (locale) =>
                        setState(() => _pendingLocale = locale),
                    onBack: () => setState(() => _step = _OnboardingStep.team),
                    onFinish: () async {
                      await _confirm();
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _TeamStep extends StatelessWidget {
  final Team? selected;
  final ValueChanged<Team> onSelect;
  final VoidCallback? onContinue;

  const _TeamStep({
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final teams = TeamService().getTeams();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME TO TACKLE 4 LOSS',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick your team',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can change this later in Settings.',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
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
              final isSelected = selected?.id == team.id;
              return GestureDetector(
                onTap: () => onSelect(team),
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
                      errorBuilder: (context, error, stackTrace) => Icon(
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
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'CONTINUE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final Locale selected;
  final ValueChanged<Locale> onSelect;
  final VoidCallback onBack;
  final Future<void> Function() onFinish;

  const _LanguageStep({
    required this.selected,
    required this.onSelect,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP 2 OF 2',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Confirm your language',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        _LanguageTile(
          label: 'English',
          isSelected: selected.languageCode == 'en',
          onTap: () => onSelect(const Locale('en')),
        ),
        const SizedBox(height: 12),
        _LanguageTile(
          label: 'Deutsch',
          isSelected: selected.languageCode == 'de',
          onTap: () => onSelect(const Locale('de')),
        ),
        const Spacer(),
        Row(
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(
                'BACK',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onFinish,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'GET STARTED',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black12),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
