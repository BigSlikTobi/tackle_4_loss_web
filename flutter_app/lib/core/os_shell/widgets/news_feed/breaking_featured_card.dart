import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/team_logo_service.dart';
import 'feed_navigation.dart';

class BreakingFeaturedCard extends StatefulWidget {
  final NewsFeedItem item;

  const BreakingFeaturedCard({super.key, required this.item});

  @override
  State<BreakingFeaturedCard> createState() => _BreakingFeaturedCardState();
}

class _BreakingFeaturedCardState extends State<BreakingFeaturedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final firstTeamId = (item.teams != null && item.teams!.isNotEmpty)
        ? item.teams!.first['team_id']?.toString().toLowerCase() ?? ''
        : '';
    final headline = (item.headline ?? item.xPost).toUpperCase();
    final timeLabel = _timeAgo(item.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          openNewsItemDetail(context, item);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A1E13),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x380A1E16),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  if (item.imageUrl != null)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        fadeInDuration: const Duration(milliseconds: 250),
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: item.imageUrl != null
                              ? const [
                                  Color(0x660A1E13),
                                  Color(0xCC0A1E13),
                                  Color(0xF20A1E13),
                                ]
                              : const [
                                  Color(0xFF0A1E13),
                                  Color(0xFF183D28),
                                  Color(0xFF0F2D1D),
                                ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _FieldLinesPainter(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (firstTeamId.isNotEmpty)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Image.asset(
                                  TeamLogoService.getLogoPath(firstTeamId),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              timeLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0x59FFFFFF),
                              ),
                            ),
                          ],
                        ),
                        if (item.imageUrl != null) const SizedBox(height: 80),
                        Text(
                          headline,
                          style: GoogleFonts.anton(
                            fontSize: 26,
                            height: 0.97,
                            letterSpacing: -0.3,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.xPost,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Color(0x8CFFFFFF),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0x1AFFFFFF),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'READ FULL STORY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Color(0xCCC9A256),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right,
                                size: 16, color: Color(0xCCC9A256)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt.toLocal());
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}

class _FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const cols = 8;
    final dx = size.width / cols;
    for (var i = 0; i <= cols; i++) {
      canvas.drawLine(Offset(i * dx, 0), Offset(i * dx, size.height), paint);
    }
    final mid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), mid);
  }

  @override
  bool shouldRepaint(covariant _FieldLinesPainter oldDelegate) => false;
}
