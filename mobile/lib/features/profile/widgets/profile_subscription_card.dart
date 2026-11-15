import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../dashboard/dashboard_controller.dart';
import '../../subscription/past_subscriptions_view.dart';
import '../../subscription/subscription_view.dart';

class ProfileSubscriptionCard extends StatelessWidget {
  final DashboardController controller;
  final bool isDark;

  const ProfileSubscriptionCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPro = controller.isPremium;
      // Visual Inversion matching design mockup:
      // Free tier -> Dark contrast promo card (const Color(0xFF181726))
      // Premium tier -> Light card (Colors.white or surface in dark mode)
      final isCardDark = !isPro || (isDark && isPro);
      final cardBg = !isPro
          ? const Color(0xFF181726)
          : (isDark ? const Color(0xFF1E293B) : Colors.white);

      final buttonBg = isPro
          ? const Color(0xFFDDD6FE)
          : const Color(0xFFC4B5FD);

      return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCardDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: !isPro
                  ? Colors.black.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: "Premium" + Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'profile_premium'.tr,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: isCardDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  isPro ? 'profile_monthly_price'.tr : '€4.99',
                  style: TextStyle(
                    fontSize: isPro ? 16 : 22,
                    fontWeight: FontWeight.w800,
                    color: isCardDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              isPro
                  ? (controller.subscriptionPeriodEnd.value.isNotEmpty
                        ? 'profile_active_until'.trParams({
                            'date': controller.subscriptionPeriodEnd.value,
                          })
                        : 'profile_membership_active'.tr)
                  : 'profile_more_power'.tr,
              style: TextStyle(
                fontSize: 13,
                color: isCardDark
                    ? const Color(0xFF94A3B8)
                    : AppColors.inkMutedOf(context),
              ),
            ),
            const SizedBox(height: 18),

            // 5 Bullet Features
            _buildFeatureItem(
              'profile_feature_generations'.tr,
              isDarkCard: isCardDark,
            ),
            _buildFeatureItem(
              'profile_feature_ai_models'.tr,
              isDarkCard: isCardDark,
            ),
            _buildFeatureItem(
              'profile_feature_domains'.tr,
              isDarkCard: isCardDark,
            ),
            _buildFeatureItem(
              'profile_feature_templates'.tr,
              isDarkCard: isCardDark,
            ),
            _buildFeatureItem(
              'profile_feature_ad_free'.tr,
              isDarkCard: isCardDark,
            ),
            const SizedBox(height: 18),

            // Full-Width Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => SubscriptionView.open(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: const Color(0xFF1E1B4B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isPro
                      ? 'profile_manage_subscription'.tr
                      : 'profile_upgrade_premium'.tr,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () => PastSubscriptionsView.open(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.receipt,
                        size: 14,
                        color: isCardDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'profile_past_subscriptions'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isCardDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeatureItem(String text, {required bool isDarkCard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            LucideIcons.check,
            size: 14,
            color: isDarkCard
                ? const Color(0xFFA78BFA)
                : const Color(0xFF7C5CFF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: isDarkCard
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
