import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../standings/models/game_model.dart';
import '../../standings/services/standings_service.dart';
import '../../../../core/services/team_logo_service.dart';
import '../controllers/game_report_controller.dart';
import 'widgets/chat_interface.dart';
import 'widgets/quick_action_chips.dart';
import 'widgets/game_selector.dart';
import '../../../core/widgets/shimmer_skeleton.dart';

/// Redesigned Game Reports screen with chat-first conversational UI.
class GameReportScreen extends StatefulWidget {
  final Game? initialGame;

  const GameReportScreen({super.key, this.initialGame});

  @override
  State<GameReportScreen> createState() => _GameReportScreenState();
}

class _GameReportScreenState extends State<GameReportScreen> {
  late final GameReportController _controller;
  final StandingsService _standingsService = StandingsService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  
  List<Game> _completedGames = [];
  bool _isLoadingGames = true;

  @override
  void initState() {
    super.initState();
    _controller = GameReportController();
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.init();
    await _loadCompletedGames();
    
    if (widget.initialGame != null) {
      _controller.selectGame(widget.initialGame!);
      _controller.fetchAnalysisEnvelope();
    }
  }

  Future<void> _loadCompletedGames() async {
    try {
      final allGames = await _standingsService.fetchGames();
      setState(() {
        _completedGames = allGames.where((g) => g.isPlayed).toList()
          ..sort((a, b) => b.gameday.compareTo(a.gameday));
        _isLoadingGames = false;
      });
    } catch (e) {
      setState(() => _isLoadingGames = false);
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    _controller.sendChatMessage(text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showGameSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select a Game',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: GameSelector(
                games: _completedGames,
                selectedGame: _controller.selectedGame,
                onGameSelected: (game) {
                  _controller.selectGame(game);
                  _controller.fetchAnalysisEnvelope();
                  _controller.clearChat();
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        title: 'Game Reports',
        actions: [
          _buildQuotaBadge(),
        ],
        body: _isLoadingGames
            ? ListView.builder(
                padding: const EdgeInsets.only(top: 130),
                itemCount: 5,
                itemBuilder: (_, __) => const CardSkeleton(),
              )
            : Column(
                children: [
                  // Compact Game Header
                  _buildGameHeader(),
                  
                  // Chat Messages Area (Scrollable)
                  Expanded(child: _buildChatArea()),
                  
                  // Quick Actions + Input
                  _buildBottomSection(),
                ],
              ),
      ),
    );
  }

  Widget _buildQuotaBadge() {
    return Consumer<GameReportController>(
      builder: (context, controller, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: controller.canUseCloud
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: controller.canUseCloud ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '${controller.remainingCloudReports}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: controller.canUseCloud ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameHeader() {
    return Consumer<GameReportController>(
      builder: (context, controller, _) {
        final theme = Theme.of(context);
        final game = controller.selectedGame;

        return GestureDetector(
          onTap: _showGameSelector,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 130, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Game Info
                Expanded(
                  child: game != null
                      ? Row(
                          children: [
                            _buildTeamLogo(game.awayTeam),
                            const SizedBox(width: 8),
                            Text(
                              '${game.awayScore ?? 0}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '@',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            Text(
                              '${game.homeScore ?? 0}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTeamLogo(game.homeTeam),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Week ${game.week}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Tap to select a game',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                ),
                // Change button
                Icon(
                  Icons.expand_more,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamLogo(String teamCode) {
    // TeamLogoService handles normalization and path retrieval
    final logoPath = TeamLogoService.getLogoPath(teamCode);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          logoPath,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              teamCode,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildChatArea() {
    return Consumer<GameReportController>(
      builder: (context, controller, _) {
        final theme = Theme.of(context);
        final messages = controller.chatMessages;

        if (controller.selectedGame == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_football,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a game to get started',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _showGameSelector,
                  icon: const Icon(Icons.add),
                  label: const Text('Choose Game'),
                ),
              ],
            ),
          );
        }

        if (messages.isEmpty) {
          return _buildEmptyChat(theme);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + (controller.isChatLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return _buildTypingIndicator(theme);
            }
            return _buildMessageBubble(messages[index], theme);
          },
        );
      },
    );
  }

  Widget _buildEmptyChat(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me about the game!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try tapping a quick action below or type your own question',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Consumer<GameReportController>(
      builder: (context, controller, _) {
        final theme = Theme.of(context);
        
        if (controller.selectedGame == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 100,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Actions
              QuickActionChips(
                onAction: (prompt) {
                  controller.handleQuickAction(prompt);
                  _scrollToBottom();
                },
                isLoading: controller.isChatLoading,
              ),
              const SizedBox(height: 12),
              
              // Input Field + Mic
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Ask about the game...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  IconButton(
                    onPressed: controller.isChatLoading ? null : _sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
