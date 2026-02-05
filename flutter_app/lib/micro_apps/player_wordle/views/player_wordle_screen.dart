/// Main screen for the Player Wordle (NFL Guessing Game) micro app.
/// Redesigned for emotional engagement and readability.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/player_wordle_controller.dart';
import '../models/game_state.dart';
import 'widgets/guess_card.dart';
import 'widgets/player_reveal_card.dart';
import 'widgets/settings_dialog.dart';
import '../../../../core/theme/t4l_theme.dart';
import 'game_mode_picker_screen.dart';
import 'widgets/guess_panel.dart';

/// Main screen for the Player Wordle game.
class PlayerWordleScreen extends StatelessWidget {
  /// Initial game mode (daily or career)
  final GameMode initialMode;

  const PlayerWordleScreen({
    super.key,
    this.initialMode = GameMode.career,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = PlayerWordleController();
        if (initialMode == GameMode.daily) {
          controller.startDailyChallenge();
        } else {
          controller.initialize();
        }
        return controller;
      },
      child: const _PlayerWordleScreenContent(),
    );
  }
}

class _PlayerWordleScreenContent extends StatefulWidget {
  const _PlayerWordleScreenContent();

  @override
  State<_PlayerWordleScreenContent> createState() =>
      _PlayerWordleScreenContentState();
}

class _PlayerWordleScreenContentState
    extends State<_PlayerWordleScreenContent> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _showSettings() {
    final controller = context.read<PlayerWordleController>();
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: controller,
        child: const PlayerWordleSettingsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return T4LScaffold(
      title: 'Guess the Player',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettings,
          // color: Use default theme color (white in dark mode)
        ),
      ],
      body: Consumer<PlayerWordleController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return _buildLoadingState();
          }

          if (controller.error != null && controller.gameState == null) {
            return _buildErrorState(context, controller);
          }

          final gameState = controller.gameState;

          return Stack(
            children: [
              // Main Game Content
              if (gameState == null)
                Center(
                    child: Text(
                        AppLocalizations.of(context)!.playerWordleNoGameLoaded))
              else if (gameState.isGameOver && controller.mysteryPlayer != null)
                _buildGameOverView(context, controller)
              else
                _buildGameView(context, controller, gameState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 6.28,
                child: child,
              );
            },
            child: const Icon(
              Icons.sports_football,
              size: 64,
              color: AppColors.brandBase,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Builder(
            builder: (context) => Text(
              AppLocalizations.of(context)!.playerWordleLoading,
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(
    BuildContext context,
    PlayerWordleController controller,
    GameState gameState,
  ) {
    return Stack(
      children: [
        // Scrollable Middle Section (Guesses) - Now behind the glass
        Positioned.fill(
          child: gameState.guesses.isEmpty
              ? _buildEmptyGuessState()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.space2, // Clean spacing below header
                    left: AppSpacing.space2,
                    right: AppSpacing.space2,
                    bottom:
                        300, // Large padding to allow scrolling above the glass bar
                  ),
                  itemCount: gameState.guesses.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = gameState.guesses.length - 1 - index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GuessCard(
                        key: ValueKey(gameState
                            .guesses[reversedIndex].guessedPlayer.playerId),
                        guess: gameState.guesses[reversedIndex],
                        guessNumber: reversedIndex + 1,
                        isLatest: reversedIndex == gameState.guesses.length - 1,
                      ),
                    );
                  },
                ),
        ),

        // Fixed Bottom Section - New GuessPanel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GuessPanel(
            selectedTeam: controller.selectedTeamFilter,
            selectedPosition: controller.selectedPositionFilter,
            filteredPlayers: controller.searchResults,
            isLoading: controller.isSearching,
            difficulty: gameState.difficulty,
            guessedPlayerIds:
                gameState.guesses.map((g) => g.guessedPlayer.playerId).toSet(),
            isDailyChallenge: controller.isDailyChallenge,
            dailyStreak: controller.dailyStreak,
            remainingGuesses: gameState.remainingGuesses,
            totalPoints: controller.totalPoints,
            onTeamSelected: controller.setTeamFilter,
            onPositionSelected: controller.setPositionFilter,
            onPlayerSelected: controller.submitGuess,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGuessState() {
    return Consumer<PlayerWordleController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        final points = controller.totalPoints;

        // Determine achieved career rank based on total points
        Difficulty careerRank;
        int currentThreshold;
        int nextThreshold;
        String nextLevelName;

        if (points < 500) {
          careerRank = Difficulty.fan;
          currentThreshold = 0;
          nextThreshold = 500;
          nextLevelName = l10n.playerWordleLevelRookie;
        } else if (points < 2000) {
          careerRank = Difficulty.rookie;
          currentThreshold = 500;
          nextThreshold = 2000;
          nextLevelName = l10n.playerWordleLevelPro;
        } else if (points < 5000) {
          careerRank = Difficulty.pro;
          currentThreshold = 2000;
          nextThreshold = 5000;
          nextLevelName = l10n.playerWordleLevelAllMadden;
        } else {
          careerRank = Difficulty.allMadden;
          currentThreshold = 5000;
          nextThreshold = 5000;
          nextLevelName = l10n.playerWordleMaxLevel;
        }

        final progress = careerRank == Difficulty.allMadden
            ? 1.0
            : (points - currentThreshold) / (nextThreshold - currentThreshold);
        final pointsToNext = nextThreshold - points;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Level Progress (Compact)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.brandBase,
                            AppColors.brandBase.withValues(alpha: 0.7)
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${controller.totalPoints}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.playerWordleStatPts,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (careerRank != Difficulty.allMadden) ...[
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppBorders.radiusFull),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: AppColors.neutralSoft,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.brandBase),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.playerWordlePointsToNext(
                                  pointsToNext, nextLevelName),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n.playerWordleLevelAllMadden,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // Extra space to ensure content stays above the bottom interaction bar
                // Extra space to ensure content stays above the bottom interaction bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOverView(
    BuildContext context,
    PlayerWordleController controller,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            PlayerRevealCard(
              player: controller.mysteryPlayer!,
              gameStatus: controller.gameState!.status,
              guessCount: controller.gameState!.guesses.length,
              onPlayAgain: () => controller.startNewGame(),
              gameState: controller.gameState,
            ),
            const SizedBox(height: AppSpacing.space3),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    PlayerWordleController controller,
  ) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.breakingNewsRed,
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(AppLocalizations.of(context)!.playerWordleFailedToLoad,
                style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.space1),
            Text(
              controller.error ??
                  AppLocalizations.of(context)!.playerWordleUnknownError,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space4),
            ElevatedButton.icon(
              onPressed: controller.startNewGame,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.playerWordleTryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
