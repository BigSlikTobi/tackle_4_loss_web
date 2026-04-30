import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Team Info tile used in the Team Center overlay.
/// Renders a colored icon block on the left, label + subtitle in the middle,
/// and an optional ghost stat number plus chevron on the right.
class TeamMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? iconAssetPath;
  final VoidCallback onTap;
  final Color? color;

  /// Optional secondary line beneath the label (e.g. "53 active · 16 PS").
  final String? subtitle;

  /// Optional accent color for the colored left icon block.
  /// Falls back to [color] (team color) or brand green.
  final Color? accentColor;

  /// Optional big ghost number on the right side.
  final String? statText;

  /// Optional color for the stat number (e.g. red for injuries).
  final Color? statColor;

  const TeamMenuButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconAssetPath,
    required this.onTap,
    this.color,
    this.subtitle,
    this.accentColor,
    this.statText,
    this.statColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? color ?? const Color(0xFF0F3D2E);
    final accentLight = Color.lerp(accent, Colors.white, 0.18)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Colored icon block
                  Container(
                    width: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accentLight, accent],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IgnorePointer(
                          child: Opacity(
                            opacity: 0.07,
                            child: CustomPaint(
                              size: const Size(64, 80),
                              painter: _GridPainter(),
                            ),
                          ),
                        ),
                        _buildIcon(),
                      ],
                    ),
                  ),
                  // Body
                  Expanded(
                    child: Container(
                      color: const Color(0xD90F1411), // rgba(15,20,17,0.85)
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.white.withValues(alpha: 0.38),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (statText != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              statText!,
                              style: TextStyle(
                                fontFamily: 'Russo One',
                                fontSize: 18,
                                color: statColor ??
                                    Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                          ],
                          const SizedBox(width: 10),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildIcon() {
    if (iconAssetPath != null) {
      if (iconAssetPath!.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          iconAssetPath!,
          width: 26,
          height: 26,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.9),
            BlendMode.srcIn,
          ),
        );
      }
      return Image.asset(
        iconAssetPath!,
        width: 26,
        height: 26,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 24,
        ),
      );
    }
    return Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
