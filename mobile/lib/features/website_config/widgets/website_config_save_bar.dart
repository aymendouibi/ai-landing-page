import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../website_config_controller.dart';

class WebsiteConfigSaveBar extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;

  const WebsiteConfigSaveBar({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isSavingMetadata.value
                  ? null
                  : () => controller.saveMetadata(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF141622),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: controller.isSavingMetadata.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'site_settings_save_changes'.tr,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'site_settings_changes_live_note'.tr,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      );
    });
  }
}
