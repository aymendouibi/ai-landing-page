import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer loading placeholder for the Projects (Dashboard) screen.
/// Renders skeleton placeholders for the Hero Card and the Recent Projects carousel.
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 90, height: 20, borderRadius: 10),
                  ShimmerBox(width: 60, height: 20, borderRadius: 10),
                ],
              ),
              const SizedBox(height: 16),
              // Hero preview area
              ShimmerBox(
                width: double.infinity,
                height: 180,
                borderRadius: 16,
              ),
              const SizedBox(height: 16),
              // Title & subtitle
              ShimmerBox(width: 180, height: 22, borderRadius: 8),
              const SizedBox(height: 8),
              ShimmerBox(width: 240, height: 14, borderRadius: 6),
              const SizedBox(height: 18),
              // Button
              ShimmerBox(
                width: double.infinity,
                height: 48,
                borderRadius: 16,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // "Recent" Section Title Shimmer
        ShimmerBox(width: 100, height: 20, borderRadius: 6),

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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: double.infinity,
                      height: 160,
                      borderRadius: 14,
                    ),
                    const SizedBox(height: 14),
                    ShimmerBox(width: 140, height: 18, borderRadius: 6),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 180, height: 12, borderRadius: 6),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(width: 70, height: 14, borderRadius: 6),
                        ShimmerBox(width: 60, height: 24, borderRadius: 8),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
