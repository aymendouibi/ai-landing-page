import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/widgets/app_showcase.dart';
import 'editor_controller.dart';
import 'widgets/editor_bottom_dock.dart';
import 'widgets/editor_bottom_panel.dart';
import 'widgets/editor_canvas_view.dart';
import 'widgets/editor_top_bar.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditorController());
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (controller.isLandscape.value != isLandscape) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.isLandscape.value = isLandscape;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppShowcase.checkAndStartEditorShowcase(context, [
        controller.showcaseCanvasKey,
        controller.showcaseRotateKey,
        controller.showcaseDockKey,
        controller.showcasePublishKey,
      ]);
    });

    return Scaffold(
      backgroundColor: AppColors.isDark(context)
          ? const Color(0xFF0F172A)
          : const Color(0xFFEDF2F7),
      body: SafeArea(
        child: isLandscape
            ? Column(
                children: [
                  EditorLandscapeTopBar(controller: controller),
                  Expanded(child: _buildLandscapeBody(context, controller)),
                ],
              )
            : Column(
                children: [
                  EditorTopBar(controller: controller),
                  Expanded(child: _buildPortraitBody(context, controller)),
                ],
              ),
      ),
    );
  }

  Widget _buildPortraitBody(BuildContext context, EditorController controller) {
    return Stack(
      children: [
        // Canvas (WebView) Area
        Positioned.fill(
          child: Obx(
            () => Padding(
              padding: EdgeInsets.only(
                bottom: controller.isPanelOpen.value ? 500 : 130,
              ),
              child: Center(
                child: AppShowcase.item(
                  key: controller.showcaseCanvasKey,
                  title: 'editor_live_canvas'.tr,
                  description: 'showcase_canvas_desc'.tr,
                  child: EditorCanvasView(
                    controller: controller,
                    isLandscape: false,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Slim vertical scrollbar on right edge (Screenshots 1 & 2)
        Positioned(
          right: 4,
          top: 40,
          bottom: 140,
          child: Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Bottom Dock & Floating AI Pill (Preview Mode)
        Obx(
          () => AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: controller.isPanelOpen.value ? -400 : 0,
            child: IgnorePointer(
              ignoring: controller.isPanelOpen.value,
              child: EditorFloatingBottomDock(controller: controller),
            ),
          ),
        ),

        // Bottom Docked Panel (Edit/Layers/Add/Design)
        Obx(
          () => AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: controller.isPanelOpen.value ? 0 : -530,
            child: IgnorePointer(
              ignoring: !controller.isPanelOpen.value,
              child: EditorBottomPanel(controller: controller),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeBody(
    BuildContext context,
    EditorController controller,
  ) {
    return Row(
      children: [
        // Left: The Website Canvas
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                      bottom: controller.isPanelOpen.value ? 8 : 60,
                    ),
                    child: Center(
                      child: AppShowcase.item(
                        key: controller.showcaseCanvasKey,
                        title: 'editor_live_canvas'.tr,
                        description: 'showcase_canvas_desc'.tr,
                        child: EditorCanvasView(
                          controller: controller,
                          isLandscape: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom floating dock in landscape (when side panel is closed)
              Obx(
                () => AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: 20,
                  right: 20,
                  bottom: controller.isPanelOpen.value ? -120 : 8,
                  child: IgnorePointer(
                    ignoring: controller.isPanelOpen.value,
                    child: EditorLandscapeFloatingDock(controller: controller),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right side: Slide-in Inspector Panel (Add, Edit, Layers, Design)
        EditorLandscapeSidePanel(controller: controller),
      ],
    );
  }
}
