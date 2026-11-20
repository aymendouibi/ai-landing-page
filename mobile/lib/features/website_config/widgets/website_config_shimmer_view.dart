import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer loading placeholder for the Website Config screen.
/// Renders skeleton placeholders matching the config top nav, header, and settings cards.
class WebsiteConfigShimmerView extends StatelessWidget {
  const WebsiteConfigShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Stack(
      children: [
        // Atmospheric pastel ambient glow at the top matching actual screen
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 280,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1E1B4B).withValues(alpha: 0.35),
                        const Color(0xFF1E293B).withValues(alpha: 0.20),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFBAE6FD).withValues(alpha: 0.50),
                        const Color(0xFFE9D5FF).withValues(alpha: 0.45),
                        const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                      ],
              ),
            ),
          ),
        ),

        SafeArea(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
            children: [
              // Top Nav: Return button + Site switcher placeholder
              Shimmer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 44, height: 44, borderRadius: 14),
                    ShimmerBox(width: 160, height: 44, borderRadius: 22),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Page Header shimmer
              Shimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 170, height: 28, borderRadius: 8),
                    SizedBox(height: 8),
                    ShimmerBox(width: 250, height: 16, borderRadius: 6),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Card 1: General Settings Card
              ShimmerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        ShimmerBox.circle(size: 32),
                        SizedBox(width: 12),
                        ShimmerBox(width: 130, height: 18, borderRadius: 6),
                      ],
                    ),
                    SizedBox(height: 20),
                    ShimmerBox(width: 100, height: 14, borderRadius: 5),
                    SizedBox(height: 8),
                    ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
                    SizedBox(height: 16),
                    ShimmerBox(width: 120, height: 14, borderRadius: 5),
                    SizedBox(height: 8),
                    ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card 2: Publishing / Domain Security Card
              ShimmerCard(
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            ShimmerBox.circle(size: 32, baseColor: Color(0xFF334155)),
                            SizedBox(width: 12),
                            ShimmerBox(width: 120, height: 18, borderRadius: 6, baseColor: Color(0xFF334155)),
                          ],
                        ),
                        const ShimmerBox(width: 70, height: 24, borderRadius: 12, baseColor: Color(0xFF334155)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const ShimmerBox(width: double.infinity, height: 44, borderRadius: 12, baseColor: Color(0xFF334155)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card 3: Landing Page Files Card
              ShimmerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        ShimmerBox.circle(size: 32),
                        SizedBox(width: 12),
                        ShimmerBox(width: 140, height: 18, borderRadius: 6),
                      ],
                    ),
                    SizedBox(height: 18),
                    ShimmerBox(width: double.infinity, height: 44, borderRadius: 14),
                    SizedBox(height: 10),
                    ShimmerBox(width: double.infinity, height: 44, borderRadius: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
