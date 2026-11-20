import 'package:flutter/material.dart';
import '../../../core/widgets/shimmer_box.dart';

/// Shimmer placeholder cards shown while past subscriptions / invoices are loading.
class PastSubscriptionsShimmerView extends StatelessWidget {
  final int count;

  const PastSubscriptionsShimmerView({
    super.key,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year header shimmer
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 12),
          child: Shimmer(
            child: ShimmerBox(width: 70, height: 22, borderRadius: 6),
          ),
        ),

        // Shimmer subscription cards
        for (int i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerCard(
              padding: const EdgeInsets.all(18),
              borderRadius: 20,
              child: Row(
                children: [
                  const ShimmerBox.circle(size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 130, height: 16, borderRadius: 6),
                        SizedBox(height: 6),
                        ShimmerBox(width: 90, height: 12, borderRadius: 5),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      ShimmerBox(width: 55, height: 16, borderRadius: 6),
                      SizedBox(height: 6),
                      ShimmerBox(width: 50, height: 18, borderRadius: 10),
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
