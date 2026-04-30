import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../models/team_article.dart';

const Color _kGold = Color(0xFFC9A256);
const Color _kFieldDark1 = Color(0xFF071810);
const Color _kFieldDark2 = AppColors.brandBase; // 0xFF0F3D2E
const Color _kFieldDark3 = Color(0xFF08221A);

class DailyUpdateCard extends StatefulWidget {
  final TeamArticle? article;
  final VoidCallback onTap;
  final VoidCallback? onImageTap;
  final Color? teamColor;

  const DailyUpdateCard({
    super.key,
    this.article,
    required this.onTap,
    this.onImageTap,
    this.teamColor,
  });

  @override
  State<DailyUpdateCard> createState() => _DailyUpdateCardState();
}

class _DailyUpdateCardState extends State<DailyUpdateCard>
    with TickerProviderStateMixin {
  late final AnimationController _chipPulse;
  late final AnimationController _wave;
  late final AnimationController _playPulse;

  @override
  void initState() {
    super.initState();
    _chipPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _playPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _chipPulse.dispose();
    _wave.dispose();
    _playPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.article == null) return _buildSkeleton();

    final title = widget.article!.title.isNotEmpty
        ? widget.article!.title
        : 'Latest Team Update';

    return GestureDetector(
      onTap: widget.onImageTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1F14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Field gradient base
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kFieldDark1, _kFieldDark2, _kFieldDark3],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // Field-line watermark
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.045,
                    child: CustomPaint(painter: _FieldLinesPainter()),
                  ),
                ),
              ),
              // Bottom fade
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGoldChip(),
                    const SizedBox(height: 12),
                    Text(
                      title.toUpperCase(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Russo One',
                        fontSize: 17,
                        height: 1.2,
                        letterSpacing: 0.17,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildBottomRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoldChip() {
    return AnimatedBuilder(
      animation: _chipPulse,
      builder: (_, __) {
        final t = _chipPulse.value; // 0..1
        // scale 1 -> 1.03 -> 1
        final scale = 1.0 + 0.03 * (t < 0.5 ? t * 2 : (1 - t) * 2);
        // ring 0..7px, opacity 0.55 -> 0
        final ringSize = 7.0 * t;
        final ringAlpha = (0.55 * (1 - t)).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: _kGold,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: ringAlpha),
                  blurRadius: 0,
                  spreadRadius: ringSize,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.headphones, size: 11, color: AppColors.brandBase),
                SizedBox(width: 5),
                Text(
                  'DAILY UPDATE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: AppColors.brandBase,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildWaveform(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY · LISTEN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.38,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '3:04 / 8:22',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildPlayButton(),
      ],
    );
  }

  Widget _buildWaveform() {
    const barCount = 12;
    return SizedBox(
      height: 22,
      width: barCount * 4.5,
      child: AnimatedBuilder(
        animation: _wave,
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (i) {
              final phase = (_wave.value + i * 0.08) % 1.0;
              // sin-like 4..20 height
              final tri = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
              final h = 4.0 + 16.0 * tri;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  width: 2.5,
                  height: h,
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _playPulse,
        builder: (_, __) {
          final t = _playPulse.value;
          final ring = 8.0 * t;
          final alpha = (0.3 * (1 - t)).clamp(0.0, 1.0);
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: alpha),
                  blurRadius: 0,
                  spreadRadius: ring,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.brandBase,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white24),
      ),
    );
  }
}

class _FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Vertical yard lines
    const cols = 9;
    final step = size.width / (cols - 1);
    for (int i = 0; i < cols; i++) {
      final x = i * step;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Midfield horizontal
    final midPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      midPaint,
    );
    // Center ellipse
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 100,
        height: 76,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
