import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../profile/components/subscription_plan_sheet.dart';
import '../website_config_controller.dart';
import 'manage_dns_sheet.dart';

class WebsiteConfigDomainSecurityCard extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;

  const WebsiteConfigDomainSecurityCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasDomain = controller.domains.isNotEmpty;
      final primaryDomain = hasDomain
          ? (controller.domains.first['domain']?.toString() ?? '')
          : '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'site_settings_domain_security'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.inkOf(context),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'site_settings_custom_domain'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
                const SizedBox(height: 8),

                // Domain input box
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161922)
                        : const Color(0xFFF6F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: controller.domainInputController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: primaryDomain.isNotEmpty
                          ? primaryDomain
                          : 'site_settings_custom_domain_placeholder'.tr,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Free tier custom domains alert banner
                if (!controller.isPremium) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C5CFF).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF7C5CFF).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.lock,
                                  size: 14,
                                  color: Color(0xFF7C5CFF),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'site_settings_premium_feature'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7C5CFF),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF64748B,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'site_settings_free_tier'.tr,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'site_settings_custom_domain_premium_req'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                SubscriptionPlanSheet.show(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C5CFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'site_settings_upgrade_premium_price'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Status Row: "Connected" on left, "Manage DNS" on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hasDomain
                            ? 'site_settings_connected'.tr
                            : 'site_settings_not_connected'.tr,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasDomain
                              ? const Color(0xFF10B981)
                              : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ManageDnsSheet.show(
                        context,
                        controller: controller,
                        isDark: isDark,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'site_settings_manage_dns'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C5CFF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSubtleOf(context),
                ),
                const SizedBox(height: 16),

                // SSL Certificate row
                Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 18,
                      color: AppColors.inkOf(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'site_settings_ssl_cert'.tr,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkOf(context),
                            ),
                          ),
                          Text(
                            'site_settings_ssl_active'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Force HTTPS row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'site_settings_force_https'.tr,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkOf(context),
                            ),
                          ),
                          Text(
                            'site_settings_force_https_desc'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: controller.forceHttps.value,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFFC4B5FD),
                      inactiveTrackColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      onChanged: (val) => controller.forceHttps.value = val,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
