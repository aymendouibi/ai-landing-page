import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer loading placeholder for the Projects (Dashboard) screen.
/// Renders skeleton placeholders for the Hero Card and the Recent Projects carousel
/// with unified hardware-accelerated diagonal sweeps.
class ProjectsShimmerView extends StatelessWidget {
  const ProjectsShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Card Shimmer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderSubtleOf(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0x141E1E50),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge & status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 104, height: 24, borderRadius: 12),
                    ShimmerBox(width: 68, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 16),
                // Hero preview area
                const ShimmerBox(
                  width: double.infinity,
                  height: 195,
                  borderRadius: 16,
                ),
                const SizedBox(height: 16),
                // Title & subtitle
                const ShimmerBox(width: 210, height: 24, borderRadius: 8),
                const SizedBox(height: 8),
                const ShimmerBox(width: 280, height: 14, borderRadius: 6),
                const SizedBox(height: 18),
                // Button
                const ShimmerBox.button(
                  width: double.infinity,
                  height: 48,
                  borderRadius: 16,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // "Recent" Section Title Shimmer
        const Shimmer(
          child: ShimmerBox(width: 110, height: 22, borderRadius: 6),
        ),

        const SizedBox(height: 14),

        // Horizontal Recent Projects Carousel Shimmer
        SizedBox(
          height: 355,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return Container(
                width: 260,
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
                        height: 160,
                        borderRadius: 14,
                      ),
                      SizedBox(height: 14),
                      ShimmerBox(width: 150, height: 18, borderRadius: 6),
                      SizedBox(height: 8),
                      ShimmerBox(width: 190, height: 12, borderRadius: 6),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerBox(width: 76, height: 14, borderRadius: 6),
                          ShimmerBox(width: 64, height: 26, borderRadius: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
