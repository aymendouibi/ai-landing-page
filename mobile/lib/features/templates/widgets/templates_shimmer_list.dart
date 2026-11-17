import 'package:flutter/material.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer placeholder cards shown while templates are loading.
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero preview image shimmer
                  ShimmerBox(
                    width: double.infinity,
                    height: 220,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag/category & rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerBox(width: 80, height: 16, borderRadius: 8),
                            ShimmerBox(width: 48, height: 16, borderRadius: 8),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        ShimmerBox(width: 200, height: 22, borderRadius: 8),
                        const SizedBox(height: 8),
                        // Description
                        ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                        const SizedBox(height: 6),
                        ShimmerBox(width: 160, height: 14, borderRadius: 6),
                        const SizedBox(height: 18),
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 44,
                                borderRadius: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: count,
        ),
      ),
    );
  }
}
