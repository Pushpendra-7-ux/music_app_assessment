import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_theme.dart';

/// A pill-shaped info chip with a gradient icon.
/// Used on the Artist profile screen for stats like monthly listeners and track count.
class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const StatChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gradientStart.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.gradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
