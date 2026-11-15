import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../website_config_controller.dart';

class WebsiteConfigPublishingCard extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;

  const WebsiteConfigPublishingCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  static void showUnpublishConfirmDialog(
    BuildContext context,
    WebsiteConfigController controller,
  ) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('site_settings_unpublish_title'.tr),
        content: Text('site_settings_unpublish_desc'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text('common_cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              controller.unpublishSite();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text('site_settings_unpublish_btn'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = controller.isLive;

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141724), // Matches mockup dark container exactly
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Title & Status Badge (Live / Draft)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'site_settings_publishing'.tr,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isLive
                        ? const Color(0xFF132E27)
                        : Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isLive ? 'live'.tr : 'draft'.tr,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isLive ? const Color(0xFF34D399) : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'site_settings_publishing_desc'.tr,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),

            // Segmented Control: [ Published ]  [ Unpublished ]
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF242738),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Published button
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.isPublishing.value
                          ? null
                          : () {
                              if (!isLive) controller.publishSite();
                            },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isLive
                              ? const Color(0xFFC4B5FD) // Lilac active pill
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'site_settings_published'.tr,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isLive ? FontWeight.w700 : FontWeight.w600,
                            color: isLive ? const Color(0xFF141724) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Unpublished button
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.isUnpublishing.value
                          ? null
                          : () {
                              if (isLive) showUnpublishConfirmDialog(context, controller);
                            },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !isLive
                              ? const Color(0xFF32364C)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'site_settings_unpublished'.tr,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: !isLive ? FontWeight.w700 : FontWeight.w600,
                            color: !isLive ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Footer URL
            Text(
              '${'site_settings_live_at'.tr} ${controller.liveUrl.value.isNotEmpty ? controller.liveUrl.value : "https://morgan.design"}',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    });
  }
}
