import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/designsystem/colors.dart';
import 'editor_controller.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditorController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.websiteName.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Text(
                controller.isSaving.value
                    ? 'Saving...'
                    : 'Rev #${controller.revisionNumber.value} (Saved)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.atmosphereViolet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.phone_android,
                color: controller.viewport.value == ViewportMode.mobile
                    ? AppColors.atmosphereViolet
                    : AppColors.inkMuted,
              ),
              tooltip: 'Mobile View (375px)',
              onPressed: () => controller.setViewport(ViewportMode.mobile),
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.tablet,
                color: controller.viewport.value == ViewportMode.tablet
                    ? AppColors.atmosphereViolet
                    : AppColors.inkMuted,
              ),
              tooltip: 'Tablet View (600px)',
              onPressed: () => controller.setViewport(ViewportMode.tablet),
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.desktop_windows,
                color: controller.viewport.value == ViewportMode.desktop
                    ? AppColors.atmosphereViolet
                    : AppColors.inkMuted,
              ),
              tooltip: 'Desktop View (Full)',
              onPressed: () => controller.setViewport(ViewportMode.desktop),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: AppColors.atmosphereViolet),
            tooltip: 'Publish to CDN',
            onPressed: controller.publishWebsite,
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () => Container(
            width: controller.viewportWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: controller.isLoading.value || controller.webViewController == null
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: controller.webViewController!),
          ),
        ),
      ),
    );
  }
}
