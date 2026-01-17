import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../theme/t4l_theme.dart';

/// Standard header component with logo, title, and configurable actions.
/// 
/// Use [kHeight] for consistent spacing calculations when positioning
/// content below the header.
class T4LHeader extends StatelessWidget {
  /// Standard header height including safe area padding.
  /// Use this constant for consistent body padding across screens.
  static const double kHeight = 68.0;
  
  /// Height including typical safe area (for estimation purposes).
  static const double kHeightWithSafeArea = 100.0;

  final String? title;
  final Widget? titleWidget;
  final Color? textColor;
  final List<Widget>? actions;
  
  /// Whether to show a back button before the logo.
  final bool showBackButton;
  
  /// Callback when back button is pressed. Defaults to Navigator.pop.
  final VoidCallback? onBack;
  
  /// Optional widget to display before the logo (e.g., custom back button).
  final Widget? leading;
  
  /// Whether to center the title. When true, title is centered and actions
  /// are positioned at the end.
  final bool centerTitle;
  
  /// Whether to show the T4L logo.
  final bool showLogo;

  const T4LHeader({
    super.key, 
    this.title, 
    this.titleWidget, 
    this.textColor, 
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.leading,
    this.centerTitle = false,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    // defaults to theme-aware textPrimary if no specific color is provided
    final themeColors = Theme.of(context).extension<T4LThemeColors>();
    final effectiveTextColor = textColor ?? themeColors?.textPrimary ?? AppColors.textPrimary;
    
    return SafeArea(
      bottom: false,
      child: Container(
        height: kHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: centerTitle ? _buildCenteredLayout(context, effectiveTextColor) : _buildStandardLayout(context, effectiveTextColor),
      ),
    );
  }
  
  Widget _buildStandardLayout(BuildContext context, Color effectiveTextColor) {
    return Row(
      children: [
        // Leading widget or back button
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ] else if (showBackButton) ...[
          _buildBackButton(context, effectiveTextColor),
          const SizedBox(width: 8),
        ],
        
        // Logo Container - Matching web style
        if (showLogo) _buildLogo(),

        if (titleWidget != null) ...[
          const SizedBox(width: 16),
          Expanded(child: titleWidget!),
        ] else if (title != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title!,
              style: AppTextStyles.h2.copyWith(
                color: effectiveTextColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else ...[
          const Spacer(),
        ],

        if (actions != null) ...actions!,
      ],
    );
  }
  
  Widget _buildCenteredLayout(BuildContext context, Color effectiveTextColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Leading/Back on left
        Positioned(
          left: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) leading!
              else if (showBackButton) _buildBackButton(context, effectiveTextColor),
              if (showLogo) ...[
                const SizedBox(width: 8),
                _buildLogo(),
              ],
            ],
          ),
        ),
        
        // Centered title
        if (titleWidget != null)
          titleWidget!
        else if (title != null)
          Text(
            title!,
            style: AppTextStyles.h2.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        
        // Actions on right
        if (actions != null)
          Positioned(
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
          ),
      ],
    );
  }
  
  Widget _buildBackButton(BuildContext context, Color color) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_rounded, color: color, size: 20),
      onPressed: onBack ?? () => Navigator.of(context).pop(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
  
  Widget _buildLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0D2119),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
    );
  }
}
