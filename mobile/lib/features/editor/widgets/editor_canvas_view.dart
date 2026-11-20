import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/designsystem/colors.dart';
import '../editor_controller.dart';

class EditorCanvasView extends StatelessWidget {
  final EditorController controller;
  final bool isLandscape;

  const EditorCanvasView({
    super.key,
    required this.controller,
    this.isLandscape = false,
  });

  double? _calculateCanvasWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = max(
      0.0,
      isLandscape && controller.isPanelOpen.value
          ? screenWidth - 350 - 24
          : screenWidth - 24,
    );

    switch (controller.viewport.value) {
      case ViewportMode.mobile:
        return min(375.0, availableWidth);
      case ViewportMode.tablet:
        return min(600.0, availableWidth);
      case ViewportMode.desktop:
        return availableWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _calculateCanvasWidth(context),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(
            controller.viewport.value == ViewportMode.desktop ? 14 : 24,
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            controller.viewport.value == ViewportMode.desktop ? 14 : 24,
          ),
          child: Column(
            children: [
              // Desktop browser title bar (Screenshots 4 & 5)
              if (controller.viewport.value == ViewportMode.desktop)
                DesktopBrowserBar(controller: controller),

              // WebView
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxHeight <= 1 || constraints.maxWidth <= 1) {
                      return const SizedBox.shrink();
                    }
                    if (controller.isLoading.value ||
                        controller.webViewController == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      );
                    }
                    return WebViewWidget(
                      controller: controller.webViewController!,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DesktopBrowserBar extends StatelessWidget {
  final EditorController controller;

  const DesktopBrowserBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // 3 window dots
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // Centered URL Pill (Screenshot 4 & 5: lumencoffee.com)
          Expanded(
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  final url = controller.liveSiteUrl;
                  Clipboard.setData(ClipboardData(text: url));
                  Get.snackbar(
                    'editor_view_live_site'.tr,
                    '${'editor_site_link_copied'.tr}: $url',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                    backgroundColor: const Color(0xFF0F172A),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.globe, size: 11, color: Color(0xFF10B981)),
                      const SizedBox(width: 5),
                      Text(
                        controller.siteDomain,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

