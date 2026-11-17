import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:startapp_sdk/startapp.dart';
import '../designsystem/colors.dart';
import '../services/ad_service.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/profile/components/subscription_plan_sheet.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  StartAppBannerAd? _bannerAd;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _loadStartAppBanner();
  }

  void _loadStartAppBanner() async {
    if (!AdService.isSupported || _isLoadingAd) return;
    _isLoadingAd = true;

    final ad = await AdService.instance.loadBannerAd(
      type: StartAppBannerType.BANNER,
      adTag: 'dashboard_bottom',
    );

    if (mounted) {
      setState(() {
        _bannerAd = ad;
        _isLoadingAd = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<DashboardController>();
    final isDark = AppColors.isDark(context);

    return Obx(() {
      // Free users only: if user has upgraded to Pro, remove all ads
      if (!controller.hasAds.value || controller.isPremium) {
        return const SizedBox.shrink();
      }

      // If native Start.io banner is loaded, render it inside container
      if (_bannerAd != null) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: StartAppBanner(_bannerAd!),
          ),
        );
      }

      // Fallback / Loading placeholder with upgrade to Pro CTA
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.70)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ad_sponsored'.tr,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ad_headline'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkOf(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ad_remove_ads'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => SubscriptionPlanSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 12, color: Color(0xFF7C5CFF)),
                    const SizedBox(width: 4),
                    Text(
                      'ad_no_ads'.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C5CFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
