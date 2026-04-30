import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_theme.dart';

/// A reusable button with the app's signature purple-to-pink gradient.
///
/// Supports disabled state (pass `null` to [onPressed]) which renders
/// a muted background instead of the gradient.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled ? AppColors.gradient : null,
        color: isEnabled
            ? null
            : AppColors.textMuted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.gradientStart.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(child: child),
        ),
      ),
    );
  }
}
