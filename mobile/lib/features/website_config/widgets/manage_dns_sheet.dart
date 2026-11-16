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

  const ManageDnsSheet({
    super.key,
    required this.controller,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required WebsiteConfigController controller,
    required bool isDark,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) =>
          ManageDnsSheet(controller: controller, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'site_settings_manage_dns_domain'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkOf(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'site_settings_dns_config_desc'.tr,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.inkMutedOf(context),
              ),
            ),
            const SizedBox(height: 18),

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
                children: [
                  _buildDnsRow('CNAME', '@', 'sites.aibuilder.app', context),
                  const Divider(height: 16),
                  _buildDnsRow(
                    'TXT',
                    '_verify',
                    'aibuilder-site-verify',
                    context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text:
                              'Type: CNAME\nHost: @\nTarget: sites.aibuilder.app\n\nType: TXT\nHost: _verify\nValue: aibuilder-site-verify',
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
                    child: Text(
                      'site_settings_copy_records'.tr,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      AppSnackbar.success('site_settings_dns_verified'.tr);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('site_settings_verify_dns'.tr),
                  ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              host,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.inkOf(context),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.inkMutedOf(context),
          ),
        ),
      ],
    );
  }
}
