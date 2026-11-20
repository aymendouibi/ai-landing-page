import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/routes/orientation_route_observer.dart';
import '../../core/widgets/app_showcase.dart';
import 'editor_controller.dart';
import 'widgets/editor_bottom_dock.dart';
import 'widgets/editor_bottom_panel.dart';
import 'widgets/editor_canvas_view.dart';
import 'widgets/editor_top_bar.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final EditorController controller;
  bool _showcaseTourInitiated = false;
  Worker? _loadingWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EditorController>()
        ? Get.find<EditorController>()
        : Get.put(EditorController());

    _loadingWorker = ever(controller.isLoading, (bool loading) {
      if (!loading && !_showcaseTourInitiated && mounted) {
        _scheduleShowcaseTour();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoading.value && !_showcaseTourInitiated && mounted) {
        _scheduleShowcaseTour();
      }
    });
  }

  void _scheduleShowcaseTour() {
    if (_showcaseTourInitiated) return;
    _showcaseTourInitiated = true;

    // Allow orientation animation and initial layout to fully settle before computing showcase bounds
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      // Close side panel if it was opened prematurely so canvas and bottom dock are fully visible
      controller.isPanelOpen.value = false;

      AppShowcase.checkAndStartEditorShowcase(
        context,
        [
          controller.showcaseCanvasKey,
          controller.showcaseRotateKey,
          controller.showcaseDockKey,
          controller.showcasePublishKey,
        ],
        onFinish: () {
          if (!mounted) return;
          final doc = controller.document.value;
          final pages = doc?['pages'] as List?;
          final sections = pages != null && pages.isNotEmpty
              ? pages[0]['sections'] as List?
              : null;
          if (sections == null || sections.isEmpty) {
            controller.selectedTab.value = 0;
            controller.isPanelOpen.value = true;
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _loadingWorker?.dispose();
    AppShowcase.dismiss();
    // Force portrait orientation immediately when leaving the editor
    OrientationRouteObserver.lockPortrait();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (controller.isLandscape.value != isLandscape) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.isLandscape.value = isLandscape;
        AppShowcase.dismiss();
      });
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        OrientationRouteObserver.lockPortrait();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.backgroundOf(context),
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
                top: 10,
                bottom: controller.isPanelOpen.value ? 500 : 130,
                left: 12,
                right: 12,
              ),
              child: Center(
                child: AppShowcase.item(
                  key: controller.showcaseCanvasKey,
                  title: 'editor_live_canvas'.tr,
                  description: 'showcase_canvas_desc'.tr,
                  targetPadding: EdgeInsets.zero,
                  targetShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      controller.viewport.value == ViewportMode.desktop ? 14 : 24,
                    ),
                  ),
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
                      top: 6,
                      bottom: controller.isPanelOpen.value ? 8 : 60,
                      left: 8,
                      right: 8,
                    ),
                    child: Center(
                      child: AppShowcase.item(
                        key: controller.showcaseCanvasKey,
                        title: 'editor_live_canvas'.tr,
                        description: 'showcase_canvas_desc'.tr,
                        targetPadding: EdgeInsets.zero,
                        targetShapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            controller.viewport.value == ViewportMode.desktop ? 14 : 24,
                          ),
                        ),
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
