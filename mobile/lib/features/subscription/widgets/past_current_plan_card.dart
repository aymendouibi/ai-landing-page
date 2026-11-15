import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dashboard/dashboard_controller.dart';

class PastCurrentPlanCard extends StatelessWidget {
  final DashboardController? controller;

  const PastCurrentPlanCard({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = controller?.isPremium ?? false;
    final periodEnd = controller?.subscriptionPeriodEnd.value ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF13111C),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'past_sub_your_current_plan'.tr,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isPro ? 'Premium' : 'Free',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPro
                ? (periodEnd.isNotEmpty
                      ? 'Active Premium subscription until $periodEnd.'
                      : 'Active Premium subscription.')
                : 'No active subscription. No upcoming charges.',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFFCBD5E1),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
