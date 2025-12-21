import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';

class T4LHeader extends StatelessWidget {
  final String? title;
  final Color? textColor;
  final List<Widget>? actions;

  const T4LHeader({
    super.key, 
    this.title, 
    this.textColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Logo Container - Matching web style
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0D2119),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/T4L_app_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            if (title != null) ...[
              const SizedBox(width: 16),
              Text(
                title!,
                style: AppTextStyles.h2.copyWith(
                  color: textColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            if (actions != null) ...[
              const Spacer(),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}
