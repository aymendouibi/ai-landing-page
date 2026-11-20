import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer loading placeholder for the Assets screen.
/// Renders skeleton placeholders matching pages and upload cards.
class AssetsShimmerView extends StatelessWidget {
  final int count;

  const AssetsShimmerView({
    super.key,
    this.count = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title & count shimmer
        Shimmer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 90, height: 20, borderRadius: 6),
              ShimmerBox(width: 60, height: 16, borderRadius: 6),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Shimmer project cards
        for (int i = 0; i < count; i++)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.borderSubtleOf(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.18)
                      : const Color(0x0C1E1E50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Shimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(
                    width: double.infinity,
                    height: 150,
                    borderRadius: 14,
                  ),
                  SizedBox(height: 14),
                  ShimmerBox(width: 160, height: 18, borderRadius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(width: 220, height: 12, borderRadius: 6),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 80, height: 14, borderRadius: 6),
                      ShimmerBox(width: 64, height: 26, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
