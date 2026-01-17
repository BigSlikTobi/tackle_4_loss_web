/// Main screen for the Player Wordle (NFL Guessing Game) micro app.
/// Redesigned for emotional engagement and readability.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/os_shell/widgets/t4l_scaffold.dart';

import '../../../design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/player_wordle_controller.dart';
import '../models/game_state.dart';
import 'widgets/player_search_bar.dart';
import 'widgets/guess_card.dart';
import 'widgets/hint_button.dart';
import 'widgets/player_reveal_card.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/team_hint_button.dart';
import '../../../../core/theme/t4l_theme.dart';
import 'game_mode_picker_screen.dart';

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
  State<_PlayerWordleScreenContent> createState() => _PlayerWordleScreenContentState();
}

class _PlayerWordleScreenContentState extends State<_PlayerWordleScreenContent> {
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
        child: PlayerWordleSettingsDialog(),
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
                Center(child: Text(AppLocalizations.of(context)!.playerWordleNoGameLoaded))
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
    // Determine expanded UI state: show filters/hints only when focused or searching
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final isFocused = _searchFocusNode.hasFocus;
    final hasSearchResults = controller.searchResults.isNotEmpty;
    final bool showExpandedUi = isFocused || hasSearchResults;

    // Theme extraction
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Glassmorphism styling
    const double blurSigma = 10.0;
    final Color glassColor = colors.surface.withValues(alpha: 0.85);

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
                    bottom: 300, // Large padding to allow scrolling above the glass bar
                  ),
                  itemCount: gameState.guesses.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = gameState.guesses.length - 1 - index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GuessCard(
                        key: ValueKey(gameState.guesses[reversedIndex].guessedPlayer.playerId),
                        guess: gameState.guesses[reversedIndex],
                        guessNumber: reversedIndex + 1,
                        isLatest: reversedIndex == gameState.guesses.length - 1,
                      ),
                    );
                  },
                ),
        ),

        // Fixed Bottom Section (Glassmorphic) - Pinned to bottom with header clearance
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0, // Fill the available body space (which already starts below header)
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70% of screen
              ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppBorders.radiusXl),
                topRight: Radius.circular(AppBorders.radiusXl),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: isKeyboardOpen ? 12 : MediaQuery.of(context).padding.bottom + AppSpacing.space1,
                    top: 12,
                  ),
                  decoration: BoxDecoration(
                    color: glassColor,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: (isDark ? Colors.white : colors.border).withValues(alpha: 0.2), width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Integrated Game Info Bar (Always Visible)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.emoji_events_rounded, color: AppColors.brandBase, size: 20),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${controller.totalPoints}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
                                      ),
                                      Builder(
                                        builder: (context) => Text(AppLocalizations.of(context)!.playerWordleStatPts, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: colors.textSecondary)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
          
                              // Show Daily Challenge badge OR Difficulty selector
                              if (controller.isDailyChallenge)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [colors.brand, colors.brand.withValues(alpha: 0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.brand.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Daily Challenge',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (controller.dailyStreak > 0) ...[
                                        const SizedBox(width: 6),
                                        const Text('🔥', style: TextStyle(fontSize: 12)),
                                        Text(
                                          '${controller.dailyStreak}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              else
                              PopupMenuButton<Difficulty>(
                                initialValue: gameState.difficulty,
                                onSelected: (item) {
                                  if (controller.isDifficultyUnlocked(item)) {
                                    controller.setDifficulty(item);
                                  }
                                },
                                itemBuilder: (context) => [
                                  _buildDifficultyMenuItem(Difficulty.fan, 'Fan', controller.isDifficultyUnlocked(Difficulty.fan), 0),
                                  _buildDifficultyMenuItem(Difficulty.rookie, 'Rookie', controller.isDifficultyUnlocked(Difficulty.rookie), 500),
                                  _buildDifficultyMenuItem(Difficulty.pro, 'Pro', controller.isDifficultyUnlocked(Difficulty.pro), 2000),
                                  _buildDifficultyMenuItem(Difficulty.allMadden, 'All-Madden', controller.isDifficultyUnlocked(Difficulty.allMadden), 5000),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.trending_up, size: 14, color: Color(0xFFF59E0B)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Career Mode: ${_getDifficultyLabel(context, gameState.difficulty)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 12, 
                                          color: const Color(0xFFF59E0B),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFFF59E0B)),
                                    ],
                                  ),
                                ),
                              ),
          
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      value: gameState.remainingGuesses / 8,
                                      strokeWidth: 3,
                                      color: gameState.remainingGuesses > 4 
                                          ? Colors.green 
                                          : (gameState.remainingGuesses > 2 ? Colors.orange : Colors.red),
                                      backgroundColor: AppColors.neutralSoft,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Text(
                                    '${gameState.remainingGuesses}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
      
                        if (controller.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.space2),
                              decoration: BoxDecoration(
                                color: AppColors.breakingNewsRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                              ),
                              child: Text(
                                controller.error!,
                                style: TextStyle(color: AppColors.breakingNewsRed),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
      
                        // Filter UI - Always visible for easy browsing
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
                          child: Row(
                            children: [
                              MenuAnchor(
                                builder: (context, menuController, child) {
                                  return FilledButton.tonal(
                                    onPressed: () {
                                      if (menuController.isOpen) {
                                        menuController.close();
                                      } else {
                                        menuController.open();
                                      }
                                    },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      backgroundColor: controller.selectedTeamFilter != null 
                                          ? colors.brand 
                                          : colors.surface,
                                      foregroundColor: controller.selectedTeamFilter != null 
                                          ? colors.contrastText 
                                          : colors.textPrimary,
                                      minimumSize: const Size(44, 44), // Accessibility minimum
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Builder(
                                        builder: (context) => Text(controller.selectedTeamFilter ?? AppLocalizations.of(context)!.playerWordleFilterTeam, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          controller.selectedTeamFilter != null 
                                              ? Icons.check 
                                              : Icons.arrow_drop_down,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                menuChildren: [
                                  MenuItemButton(
                                    onPressed: () => controller.setTeamFilter(null),
                                    child: Builder(
                                      builder: (context) => Text(AppLocalizations.of(context)!.playerWordleFilterAllTeams),
                                    ),
                                  ),
                                  for (final team in ['ARI', 'ATL', 'BAL', 'BUF', 'CAR', 'CHI', 'CIN', 'CLE', 'DAL', 'DEN', 'DET', 'GB', 'HOU', 'IND', 'JAX', 'KC', 'LAC', 'LAR', 'LV', 'MIA', 'MIN', 'NE', 'NO', 'NYG', 'NYJ', 'PHI', 'PIT', 'SEA', 'SF', 'TB', 'TEN', 'WAS'])
                                    MenuItemButton(
                                      onPressed: () => controller.setTeamFilter(team),
                                      child: Text(team),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              
                              for (final pos in _getAvailablePositions(gameState.difficulty))
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    label: Text(pos),
                                    selected: controller.selectedPositionFilter == pos,
                                    onSelected: (selected) {
                                      controller.setPositionFilter(selected ? pos : null);
                                    },
                                    showCheckmark: false,
                                    selectedColor: colors.brand,
                                    labelStyle: TextStyle(
                                      color: controller.selectedPositionFilter == pos ? colors.contrastText : colors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
      
                        // Stats (Visible when Expanded OR if no guesses yet)
                        if (gameState.guesses.isNotEmpty && showExpandedUi)
                          _buildStatsAndHintBar(controller, gameState),
      
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
                          child: PlayerSearchBar(
                            key: const Key('player_search_bar'),
                            focusNode: _searchFocusNode,
                            searchResults: controller.searchResults,
                            isSearching: controller.isSearching,
                            isSubmitting: controller.isSubmitting,
                            enabled: gameState.isPlaying,
                            onSearchChanged: controller.searchPlayers,
                            onPlayerSelected: controller.submitGuess,
                            onClear: controller.clearSearch,
                            onLoadMore: controller.loadMoreResults,
                          ),
                        ),
                        
                        // Hint Button - always visible when available
                        if (!gameState.hintUsed && gameState.isPlaying)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: HintButton(
                              hintUsed: gameState.hintUsed,
                              revealedHint: gameState.revealedHint,
                              onUseHint: controller.useHint,
                            ),
                          ),
                        
                        // Team Hint Button (Daily Challenge - after 3 guesses)
                        if (controller.isDailyChallenge && gameState.isPlaying)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TeamHintButton(
                              canUse: controller.canUseTeamHint,
                              hasEnoughPoints: controller.totalPoints >= 50,
                              totalPoints: controller.totalPoints,
                              revealedTeam: controller.revealedTeamHint,
                              onUseHint: controller.useTeamHint,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildStatsAndHintBar(PlayerWordleController controller, GameState gameState) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radiusFull),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => Text('${AppLocalizations.of(context)!.playerWordleStatWinLabel}: ${(controller.winPercentage * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textSecondary)),
          ),
          Builder(
            builder: (context) => Text('${AppLocalizations.of(context)!.playerWordleStatStreak.toUpperCase()}: ${controller.currentStreak}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textSecondary)),
          ),
          if (gameState.hintUsed && gameState.revealedHint != null)
             Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.school, color: Color(0xFFF59E0B), size: 14),
                 const SizedBox(width: 4),
                 Text(
                   gameState.revealedHint!,
                   style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), fontSize: 11),
                 ),
               ],
             ),
        ],
      ),
    );
  }






  PopupMenuItem<Difficulty> _buildDifficultyMenuItem(
    Difficulty value, 
    String label, 
    bool unlocked, 
    int cost
  ) {
    return PopupMenuItem(
      value: value,
      enabled: unlocked,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!unlocked) ...[
            const Icon(Icons.lock, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: unlocked ? AppColors.textPrimary : Colors.grey,
              ),
            ),
          ),
           if (!unlocked) ...[
             const SizedBox(width: 8),
             Text(
               '${cost}pts',
               style: const TextStyle(fontSize: 10, color: Colors.grey),
             ),
           ],
        ],
      ),
    );
  }

  List<String> _getAvailablePositions(Difficulty difficulty) {
    if (difficulty == Difficulty.fan || difficulty == Difficulty.rookie) {
      // Restricted set for easier modes
      return ['QB', 'RB', 'WR', 'TE', 'DE', 'CB'];
    }
    // Full set for Pro/All-Madden
    return ['QB', 'RB', 'WR', 'TE', 'OL', 'DL', 'DE', 'LB', 'DB', 'S', 'K', 'P'];
  }

  String _getDifficultyLabel(BuildContext context, Difficulty diff) {
    final l10n = AppLocalizations.of(context)!;
    return switch (diff) {
      Difficulty.fan => l10n.playerWordleLevelFan,
      Difficulty.rookie => l10n.playerWordleLevelRookie,
      Difficulty.pro => l10n.playerWordleLevelPro,
      Difficulty.allMadden => l10n.playerWordleLevelAllMadden,
    };
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.brandBase, AppColors.brandBase.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${controller.totalPoints}',
                            style: TextStyle(
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
                              borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: AppColors.neutralSoft,
                                valueColor: AlwaysStoppedAnimation(AppColors.brandBase),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.playerWordlePointsToNext(pointsToNext, nextLevelName),
                              style: TextStyle(
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
                          Icon(Icons.emoji_events, color: Colors.amber, size: 16),
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
                
                const SizedBox(height: AppSpacing.space6),
                
                // Call to action
                Column(
                  children: [
                    Text(
                      l10n.playerWordleStartGuessing,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 32,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.breakingNewsRed,
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(AppLocalizations.of(context)!.playerWordleFailedToLoad, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.space1),
            Text(
              controller.error ?? AppLocalizations.of(context)!.playerWordleUnknownError,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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


