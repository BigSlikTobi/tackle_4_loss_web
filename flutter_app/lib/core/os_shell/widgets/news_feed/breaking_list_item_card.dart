import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/team_logo_service.dart';
import '../../../theme/t4l_theme.dart';
import 'feed_navigation.dart';

class BreakingListItemCard extends StatefulWidget {
  final NewsFeedItem item;
  final bool isLast;

  const BreakingListItemCard(
      {super.key, required this.item, this.isLast = false});

  @override
  State<BreakingListItemCard> createState() => _BreakingListItemCardState();
}

class _BreakingListItemCardState extends State<BreakingListItemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final t4l = theme.extension<T4LThemeColors>();
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = t4l?.textPrimary ?? AppColors.neutralText;
    final textMuted = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : (t4l?.textMuted ?? AppColors.neutralTextLight);
    final brand = t4l?.brand ?? AppColors.brandBase;
    // Dark mode: use a bright accent so the category eyebrow stays readable on
    // the dark navy background (matches the V3 dock active green).
    final categoryColor = isDark ? const Color(0xFF4ADE80) : brand;
    final badgeBg =
        isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.neutralSoft;
    final divider =
        (isDark ? Colors.white : AppColors.brandBase).withValues(alpha: 0.08);
    final pressBg =
        (isDark ? Colors.white : AppColors.brandBase).withValues(alpha: 0.04);

    final firstTeamId = (item.teams != null && item.teams!.isNotEmpty)
        ? item.teams!.first['team_id']?.toString().toLowerCase() ?? ''
        : '';
    final cat = item.xPost.trim();
    final body = (item.headline ?? item.xPost).trim();
    final timeLabel = _timeAgo(item.createdAt);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        openNewsItemDetail(context, item);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.fromLTRB(20, 13, 20, 13),
        decoration: BoxDecoration(
          color: _pressed ? pressBg : Colors.transparent,
          border: Border(
            bottom: widget.isLast
                ? BorderSide.none
                : BorderSide(color: divider, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brand.withValues(alpha: 0.12)),
              ),
              padding: const EdgeInsets.all(4),
              child: firstTeamId.isNotEmpty
                  ? Image.asset(
                      TeamLogoService.getLogoPath(firstTeamId),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.sports_football,
                        size: 18,
                        color: brand,
                      ),
                    )
                  : Icon(Icons.sports_football, size: 18, color: brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MarqueeText(
                          text: cat,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· $timeLabel',
                        style: TextStyle(
                          fontSize: 9,
                          color: textMuted.withValues(alpha: 0.7),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      letterSpacing: -0.15,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: textMuted.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt.toLocal());
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return '${dt.month}/${dt.day}';
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({
    required this.text,
    required this.style,
  });

  static const double _pixelsPerSecond = 14;
  static const double _gap = 48;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _loopWidth = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final textW = tp.width;
    final textH = tp.height;
    _loopWidth = textW + _MarqueeText._gap;
    final period = _loopWidth / _MarqueeText._pixelsPerSecond;

    return ClipRect(
      child: SizedBox(
        height: textH,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = (_ctrl.lastElapsedDuration?.inMicroseconds ?? 0) /
                1e6 %
                period;
            final dx = -_MarqueeText._pixelsPerSecond * t;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: dx,
                  top: 0,
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    softWrap: false,
                    style: widget.style,
                  ),
                ),
                Positioned(
                  left: dx + _loopWidth,
                  top: 0,
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    softWrap: false,
                    style: widget.style,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
