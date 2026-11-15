import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../website_config_controller.dart';

class WebsiteConfigDeleteCard extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;

  const WebsiteConfigDeleteCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  static void showDeleteDialog(
    BuildContext context,
    WebsiteConfigController controller,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('site_settings_delete_title'.tr),
        content: Text(
          'site_settings_delete_confirm'.trParams({
            'name': controller.websiteName.value.isNotEmpty
                ? controller.websiteName.value
                : 'this page',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text('common_cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              controller.deleteWebsite();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF241518) : const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF581C26) : const Color(0xFFFECDD3),
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'site_settings_delete_heading'.tr,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE11D48),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'site_settings_delete_desc'.tr,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isDeleting.value
                    ? null
                    : () => showDeleteDialog(context, controller, isDark),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF3F1922) : const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isDeleting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEF4444),
                        ),
                      )
                    : Text(
                        'site_settings_delete_btn'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
