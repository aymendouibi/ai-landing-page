import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../website_config_controller.dart';

class WebsiteConfigLandingFilesCard extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;

  const WebsiteConfigLandingFilesCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPremium = controller.isPremium;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'site_settings_landing_files'.tr,
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
                  'site_settings_import_page'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'site_settings_import_desc'.tr,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),

                // File container box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161922) : const Color(0xFFF6F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.importedZipName.value,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.importedZipInfo.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Choose ZIP file button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isImportingZip.value
                        ? null
                        : () => controller.chooseZipFile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4B5FD), // Lilac button matching mockup
                      foregroundColor: const Color(0xFF141724),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isImportingZip.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'site_settings_choose_zip'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'site_settings_import_replace_note'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSubtleOf(context),
                ),
                const SizedBox(height: 16),

                // Export Project (ZIP) action with Premium lock handling
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'site_settings_export_project'.tr,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : const Color(0xFFD97706).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPremium ? 'site_settings_premium_zip'.tr : 'site_settings_premium_only'.tr,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isPremium
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isPremium
                          ? 'site_settings_download_zip_desc'.tr
                          : 'site_settings_zip_locked_desc'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isExportingZip.value
                            ? null
                            : () => controller.exportProjectZip(),
                        icon: Icon(
                          isPremium ? LucideIcons.download : LucideIcons.lock,
                          size: 14,
                        ),
                        label: Text(
                          isPremium
                              ? 'site_settings_download_zip_btn'.tr
                              : 'site_settings_export_zip_unlock_btn'.tr,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPremium
                              ? AppColors.inkOf(context)
                              : const Color(0xFFD97706),
                          foregroundColor: isPremium
                              ? (isDark ? Colors.black : Colors.white)
                              : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => controller.copyExportCode(),
                  behavior: HitTestBehavior.opaque,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Icon(LucideIcons.copy, size: 14, color: AppColors.inkMutedOf(context)),
                      Text(
                        'site_settings_copy_code'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
