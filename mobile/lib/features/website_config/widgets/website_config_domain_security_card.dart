import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
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

                // Domain input box + attach button
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                            hintText:
                                'site_settings_custom_domain_placeholder'.tr,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkOf(context),
                          ),
                          onSubmitted: controller.isPremium
                              ? (_) => _handleAttach(context)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final isAttaching = controller.isAttachingDomain.value;
                      return SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: isAttaching
                              ? null
                              : () => _handleAttach(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C5CFF),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF7C5CFF).withValues(alpha: 0.5),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isAttaching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(LucideIcons.plus, size: 18),
                        ),
                      );
                    }),
                  ],
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
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

                // Connected domains list
                if (hasDomain) ...[
                  ...controller.domains.map(
                    (d) => _buildDomainTile(context, d),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'site_settings_not_connected'.tr,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

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

  /// Builds a tile for each attached domain showing status, manage DNS, and delete.
  Widget _buildDomainTile(BuildContext context, Map<String, dynamic> domain) {
    final name = domain['domain']?.toString() ?? '';
    final id = domain['id']?.toString() ?? '';
    final status = domain['status']?.toString().toLowerCase() ?? 'pending';
    final isActive = status == 'active';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF161922)
              : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtleOf(context)),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? LucideIcons.circleCheck : LucideIcons.clock,
              size: 16,
              color: isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  Text(
                    isActive ? 'Connected' : 'Pending verification',
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ManageDnsSheet.show(
                context,
                controller: controller,
                isDark: isDark,
                domainEntry: domain,
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  isActive
                      ? 'site_settings_manage_dns'.tr
                      : 'site_settings_verify_dns'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C5CFF),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _confirmDelete(context, id, name),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  LucideIcons.trash2,
                  size: 15,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAttach(BuildContext context) {
    if (!controller.isPremium) {
      SubscriptionPlanSheet.show(context);
      return;
    }
    final domain = controller.domainInputController.text.trim();
    if (domain.isEmpty || !domain.contains('.')) {
      AppSnackbar.error(
        'Please enter a valid domain name (e.g. mybusiness.com)',
        title: 'Invalid Domain',
      );
      return;
    }
    controller.attachDomain(domain).then((ok) {
      if (ok && controller.domains.isNotEmpty && context.mounted) {
        // Automatically open the DNS sheet for the newly added domain
        final newDomain = controller.domains.last;
        ManageDnsSheet.show(
          context,
          controller: controller,
          isDark: isDark,
          domainEntry: newDomain,
        );
      }
    });
  }

  void _confirmDelete(BuildContext context, String domainId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Domain'),
        content: Text('Disconnect "$name" from this website?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteDomain(domainId).then((ok) {
                if (ok) {
                  AppSnackbar.success('Domain "$name" disconnected.');
                }
              });
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
