import 'package:flutter/material.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer placeholder cards shown while templates are loading.
/// Uses unified hardware-accelerated diagonal sweeps matching the template card proportions.
class TemplatesShimmerList extends StatelessWidget {
  final bool isDark;
  final int count;

  const TemplatesShimmerList({
    super.key,
    required this.isDark,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.22)
                        : const Color(0x101E1E50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Shimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero preview image shimmer
                    const ShimmerBox(
                      width: double.infinity,
                      height: 220,
                      borderRadius: 24,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // Tag/category & rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(width: 88, height: 20, borderRadius: 10),
                              ShimmerBox(width: 52, height: 20, borderRadius: 10),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Title
                          ShimmerBox(width: 220, height: 24, borderRadius: 8),
                          SizedBox(height: 8),
                          // Description
                          ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                          SizedBox(height: 6),
                          ShimmerBox(width: 180, height: 14, borderRadius: 6),
                          SizedBox(height: 18),
                          // Action buttons row
                          Row(
                            children: [
                              Expanded(
                                child: ShimmerBox(
                                  width: double.infinity,
                                  height: 44,
                                  borderRadius: 14,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ShimmerBox(
                                  width: double.infinity,
                                  height: 44,
                                  borderRadius: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: count,
        ),
      ),
    );
  }
}
