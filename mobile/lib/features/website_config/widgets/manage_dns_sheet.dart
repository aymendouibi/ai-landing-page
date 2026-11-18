import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
import '../../../core/designsystem/colors.dart';
import '../website_config_controller.dart';

class ManageDnsSheet extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;

  /// The domain entry from [controller.domains] that this sheet manages.
  /// Must contain at least `id` and `domain`. May also contain `status`
  /// and nested `ssl_status` from the backend response.
  final Map<String, dynamic> domainEntry;

  const ManageDnsSheet({
    super.key,
    required this.controller,
    required this.isDark,
    required this.domainEntry,
  });

  static Future<void> show(
    BuildContext context, {
    required WebsiteConfigController controller,
    required bool isDark,
    required Map<String, dynamic> domainEntry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => ManageDnsSheet(
        controller: controller,
        isDark: isDark,
        domainEntry: domainEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final domainName = domainEntry['domain']?.toString() ?? '';
    final domainId = domainEntry['id']?.toString() ?? '';
    final domainStatus =
        domainEntry['status']?.toString().toLowerCase() ?? 'pending';
    final isActive = domainStatus == 'active';

    // Try to get DNS instructions from controller (set after attachDomain),
    // or fall back to ssl_status stored on the domain model itself.
    final dns = controller.dnsInstructions.value;
    final sslStatus = domainEntry['ssl_status'];

    // CNAME record
    final cnameRecord = dns?['cname_record'] as Map<String, dynamic>?;
    final cnameTarget = cnameRecord?['target']?.toString() ??
        (sslStatus is Map ? sslStatus['cname_target']?.toString() : null) ??
        'ai-builder-api.onrender.com';

    // TXT verification record
    final txtRecord = dns?['txt_record'] as Map<String, dynamic>?;
    final txtName = txtRecord?['name']?.toString() ??
        (sslStatus is Map ? sslStatus['txt_record_name']?.toString() : null) ??
        '_aibuilder-challenge.$domainName';
    final txtValue = txtRecord?['value']?.toString() ??
        (sslStatus is Map ? sslStatus['txt_record_value']?.toString() : null) ??
        domainEntry['verification_token']?.toString() ??
        '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'site_settings_manage_dns_domain'.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Domain name label
            Text(
              domainName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7C5CFF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'DNS verified and SSL active. No action required.'
                  : 'site_settings_dns_config_desc'.tr,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.inkMutedOf(context),
              ),
            ),
            const SizedBox(height: 18),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? LucideIcons.circleCheck : LucideIcons.clock,
                    size: 14,
                    color: isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActive ? 'Verified & Active' : 'Pending Verification',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DNS Records Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161922)
                    : const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtleOf(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDnsRow('CNAME', domainName, cnameTarget, context),
                  const Divider(height: 16),
                  _buildDnsRow('TXT', txtName, txtValue, context),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.copy, size: 14),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              'Type: CNAME\nHost: $domainName\nTarget: $cnameTarget\n\nType: TXT\nHost: $txtName\nValue: $txtValue',
                        ),
                      );
                      AppSnackbar.copied(
                        message: 'site_settings_dns_copied'.tr,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(
                      'site_settings_copy_records'.tr,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (!isActive)
                  Expanded(
                    child: Obx(() {
                      final isVerifying =
                          controller.verifyingDomainIds.contains(domainId);
                      return ElevatedButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                final verified =
                                    await controller.verifyDomain(domainId);
                                if (context.mounted) {
                                  if (verified) {
                                    Navigator.pop(context);
                                    AppSnackbar.success(
                                      'site_settings_dns_verified'.tr,
                                    );
                                  } else {
                                    AppSnackbar.info(
                                      'DNS records not yet propagated. Please allow up to 24 hours for global propagation and try again.',
                                      title: 'Not Verified Yet',
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C5CFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF7C5CFF).withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isVerifying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('site_settings_verify_dns'.tr),
                      );
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDnsRow(
    String type,
    String host,
    String value,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C5CFF),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Host',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMutedOf(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          host,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.inkOf(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          type == 'CNAME' ? 'Target' : 'Value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.inkOf(context),
          ),
        ),
      ],
    );
  }
}
