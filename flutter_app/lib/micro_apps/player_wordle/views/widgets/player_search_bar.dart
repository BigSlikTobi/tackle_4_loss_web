/// Player Search Bar widget for autocomplete player search.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/player_model.dart';

/// Search bar with autocomplete for player names.
class PlayerSearchBar extends StatefulWidget {
  /// Search results to display
  final List<Player> searchResults;
  
  /// Whether search is in progress
  final bool isSearching;
  
  /// Whether form submission is in progress
  final bool isSubmitting;
  
  /// Whether the game is still active
  final bool enabled;
  
  /// Callback when search text changes
  final ValueChanged<String> onSearchChanged;
  
  /// Callback when a player is selected
  final ValueChanged<Player> onPlayerSelected;
  
  /// Callback to clear search
  final VoidCallback onClear;

  /// Callback to load more results (pagination)
  final VoidCallback? onLoadMore;

  /// External FocusNode to control focus from parent
  final FocusNode? focusNode;

  const PlayerSearchBar({
    super.key,
    required this.searchResults,
    required this.isSearching,
    required this.isSubmitting,
    required this.enabled,
    required this.onSearchChanged,
    required this.onPlayerSelected,
    required this.onClear,
    this.onLoadMore,
    this.focusNode,
  });

  @override
  State<PlayerSearchBar> createState() => _PlayerSearchBarState();
}

class _PlayerSearchBarState extends State<PlayerSearchBar> {
  final _controller = TextEditingController();
  late FocusNode _focusNode;
  final _scrollController = ScrollController();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void didUpdateWidget(PlayerSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchResults != oldWidget.searchResults) {
      setState(() {
        _showDropdown = widget.searchResults.isNotEmpty;
      });
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    // Optional: You might want to hide it if focus is lost? 
    // But for the "Browse" requirement, keeping it open is better until explicit clear.
    // However, if we click away to something else? 
    // Let's stick to: If results exist, show them.
    setState(() {
       _showDropdown = widget.searchResults.isNotEmpty;
    });
  }

  void _onTextChanged(String value) {
    widget.onSearchChanged(value);
    setState(() {
      _showDropdown = widget.searchResults.isNotEmpty;
    });
  }

  void _selectPlayer(Player player) {
    _controller.clear();
    _focusNode.unfocus();
    widget.onClear();
    widget.onPlayerSelected(player);
    setState(() => _showDropdown = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchField(),
        if (_showDropdown && widget.searchResults.isNotEmpty)
          _buildDropdown(),
      ],
    );
  }

  Widget _buildSearchField() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        boxShadow: AppShadows.base,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enableInteractiveSelection: false, // Prevent gesture crash on long press
        enabled: widget.enabled && !widget.isSubmitting,
        onChanged: _onTextChanged,
        style: const TextStyle(
          fontSize: AppTypography.fontSizeMd,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.enabled 
              ? l10n.playerWordleSearchHint 
              : l10n.playerWordleGameOverSearchHint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
          ),
          prefixIcon: widget.isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                    setState(() => _showDropdown = false);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      margin: const EdgeInsets.only(top: AppSpacing.space1),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        boxShadow: AppShadows.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        child: ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.searchResults.length + (widget.isSearching ? 1 : 0),
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: AppColors.neutralBorder,
          ),
          itemBuilder: (context, index) {
            if (index == widget.searchResults.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    width: 24, 
                    height: 24, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            final player = widget.searchResults[index];
            return _buildPlayerTile(player);
          },
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Player player) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1 / 2,
      ),
      leading: CircleAvatar(
        radius: 20,
        foregroundImage: player.headshot != null
            ? NetworkImage(player.headshot!)
            : null,
        onForegroundImageError: (_, __) {}, // Silently handle network errors
        backgroundColor: AppColors.neutralBorder,
        child: const Icon(Icons.person, color: AppColors.textSecondary),
      ),
      title: Text(
        player.displayName,
        style: const TextStyle(
          fontSize: AppTypography.fontSizeMd,
          fontWeight: AppTypography.fontWeightBold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Text(
            '${player.team ?? l10n.playerWordleNotAvailable} · ${player.position ?? l10n.playerWordleNotAvailable}',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.textSecondary,
            ),
          );
        },
      ),
      onTap: () => _selectPlayer(player),
    );
  }
}
