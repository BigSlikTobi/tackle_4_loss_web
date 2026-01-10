/// Main screen for the Player Wordle (NFL Guessing Game) micro app.
/// Redesigned for emotional engagement and readability.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/services/settings_service.dart';
import '../../../design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/player_wordle_controller.dart';
import '../models/game_state.dart';
import 'widgets/player_search_bar.dart';
import 'widgets/guess_card.dart';
import 'widgets/hint_button.dart';
import 'widgets/player_reveal_card.dart';

/// Main screen for the Player Wordle game.
class PlayerWordleScreen extends StatelessWidget {
  const PlayerWordleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerWordleController()..initialize(),
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

  @override
  Widget build(BuildContext context) {
    return T4LScaffold(
      title: AppLocalizations.of(context)!.playerWordleTitle,
      body: Consumer<PlayerWordleController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return _buildLoadingState();
          }

          if (controller.error != null && controller.gameState == null) {
            return _buildErrorState(context, controller);
          }

          final gameState = controller.gameState;
          if (gameState == null) {
            return Center(child: Text(AppLocalizations.of(context)!.playerWordleNoGameLoaded));
          }

          if (gameState.isGameOver && controller.mysteryPlayer != null) {
            return _buildGameOverView(context, controller);
          }

          return _buildGameView(context, controller, gameState);
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

    // Glassmorphism styling
    const double blurSigma = 10.0;
    final Color glassColor = AppColors.surface.withValues(alpha: 0.85);

    return Stack(
      children: [
        // Scrollable Middle Section (Guesses) - Now behind the glass
        Positioned.fill(
          child: gameState.guesses.isEmpty
              ? _buildEmptyGuessState()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 100, // Clear the header
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
          top: 100, // Never overlap the header area
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
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
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Builder(
                                        builder: (context) => Text(AppLocalizations.of(context)!.playerWordleStatPts, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
          
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
                                    color: AppColors.neutralSoft,
                                    borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                                    border: Border.all(color: AppColors.neutralBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.speed_rounded, size: 14, color: AppColors.brandBase),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getDifficultyLabel(context, gameState.difficulty),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const Icon(Icons.arrow_drop_down, size: 18),
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
      
                        // Filter UI (Only visible when Expanded)
                        if (showExpandedUi) ...[
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
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        backgroundColor: controller.selectedTeamFilter != null 
                                            ? AppColors.brandBase 
                                            : AppColors.neutralSoft,
                                        foregroundColor: controller.selectedTeamFilter != null 
                                            ? Colors.white 
                                            : AppColors.textPrimary,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Builder(
                                          builder: (context) => Text(controller.selectedTeamFilter ?? AppLocalizations.of(context)!.playerWordleFilterTeam, style: const TextStyle(fontSize: 12)),
                                        ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            controller.selectedTeamFilter != null 
                                                ? Icons.check 
                                                : Icons.arrow_drop_down,
                                            size: 16,
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
                                      selectedColor: AppColors.brandBase,
                                      labelStyle: TextStyle(
                                        color: controller.selectedPositionFilter == pos ? Colors.white : AppColors.textPrimary,
                                        fontSize: 11,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
      
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
                        
                        // Hint Button
                        if (!gameState.hintUsed && gameState.isPlaying && showExpandedUi)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: HintButton(
                              hintUsed: gameState.hintUsed,
                              revealedHint: gameState.revealedHint,
                              onUseHint: controller.useHint,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppBorders.radiusFull),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => Text('${AppLocalizations.of(context)!.playerWordleStatWinLabel}: ${(controller.winPercentage * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
          Builder(
            builder: (context) => Text('${AppLocalizations.of(context)!.playerWordleStatStreak.toUpperCase()}: ${controller.currentStreak}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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

  Widget _buildStatsAndHintCard(PlayerWordleController controller, GameState gameState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: AppSpacing.space1),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, AppLocalizations.of(context)!.playerWordleStatPlayed, '${controller.gamesPlayed}'),
          _buildStatItem(context, AppLocalizations.of(context)!.playerWordleStatWon, '${(controller.winPercentage * 100).toInt()}%'),
          _buildStatItem(context, AppLocalizations.of(context)!.playerWordleStatStreak, '${controller.currentStreak}'),
          if (gameState.hintUsed && gameState.revealedHint != null)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
               decoration: BoxDecoration(
                 color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                 borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                 border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.school, color: Color(0xFFF59E0B), size: 14),
                   const SizedBox(width: 6),
                   Text(
                     gameState.revealedHint!,
                     style: const TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Color(0xFFF59E0B),
                       fontSize: 11,
                     ),
                   ),
                 ],
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
  Widget _buildHeroSection(BuildContext context, GameState gameState, Color teamColor) {
    const int maxGuesses = 8; // Max guesses allowed
    final int remainingGuesses = gameState.remainingGuesses;
    
    // Reactive color for progress ring
    final Color progressColor = remainingGuesses > 4 
        ? const Color(0xFF22C55E) // Green
        : remainingGuesses > 2 
            ? const Color(0xFFEAB308) // Yellow
            : const Color(0xFFEF4444); // Red

    final controller = context.watch<PlayerWordleController>();
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.space4),
      height: 120, // Constrained height for the hero card
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            teamColor,
            teamColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        boxShadow: AppShadows.md,
      ),
      child: Row(
        children: [
          // 1. Mystery/Points Icon (Left)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.totalPoints} PTS',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.space3),
          
          // 2. Info Section (Title + Selector)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.playerWordleTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                
                // Difficulty Selector Menu
                PopupMenuButton<Difficulty>(
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  color: const Color(0xFF1E1E1E), // Dark aesthetic for menu
                  surfaceTintColor: Colors.transparent,
                  onSelected: (difficulty) {
                    if (controller.isDifficultyUnlocked(difficulty)) {
                      controller.setDifficulty(difficulty);
                    }
                  },
                  itemBuilder: (context) => [
                    _buildDifficultyMenuItem(
                      Difficulty.fan, 
                      l10n.playerWordleModeFan, 
                      true, // Always unlocked
                      0
                    ),
                    _buildDifficultyMenuItem(
                      Difficulty.rookie, 
                      l10n.playerWordleModeRookie, 
                      controller.isDifficultyUnlocked(Difficulty.rookie),
                      500
                    ),
                    _buildDifficultyMenuItem(
                      Difficulty.pro, 
                      l10n.playerWordleModePro, 
                      controller.isDifficultyUnlocked(Difficulty.pro),
                      2000
                    ),
                    _buildDifficultyMenuItem(
                      Difficulty.allMadden, 
                      l10n.playerWordleModeAllMadden, 
                      controller.isDifficultyUnlocked(Difficulty.allMadden),
                      5000
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          _getDifficultyLabel(context, gameState.difficulty),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Circular Progress (Right)
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Ring
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
                // Progress Ring
                CircularProgressIndicator(
                  value: remainingGuesses / maxGuesses,
                  strokeWidth: 6,
                  color: progressColor,
                  strokeCap: StrokeCap.round,
                ),
                // Text Counter
                Text(
                  '$remainingGuesses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Football Icon
                const _BouncingFootball(),
                
                const SizedBox(height: AppSpacing.space4),
                
                // Current Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.brandBase, AppColors.brandBase.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                    boxShadow: AppShadows.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_football, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getDifficultyLabel(context, careerRank),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.space3),
                
                // Progress to Next Level
                if (careerRank != Difficulty.allMadden) ...[
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.neutralSoft,
                            valueColor: AlwaysStoppedAnimation(AppColors.brandBase),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.playerWordlePointsToNext(pointsToNext, nextLevelName),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        l10n.playerWordleMaxLevelAchieved,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: AppSpacing.space4),
                
                // Instruction
                Text(
                  l10n.playerWordleInstructionPrimary,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  l10n.playerWordleInstructionSecondary,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                backgroundColor: AppColors.brandBase,
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

/// Animated bouncing football widget
class _BouncingFootball extends StatefulWidget {
  const _BouncingFootball();

  @override
  State<_BouncingFootball> createState() => _BouncingFootballState();
}

class _BouncingFootballState extends State<_BouncingFootball> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: const Text(
        '🏈',
        style: TextStyle(fontSize: 64),
      ),
    );
  }
}
