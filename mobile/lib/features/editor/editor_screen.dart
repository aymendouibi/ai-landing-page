import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'editor_controller.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditorController());

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Two rows
            _buildTopBar(context, controller),

            // Canvas & Bottom Floating / Docked UI
            Expanded(
              child: Stack(
                children: [
                  // Canvas (WebView) Area
                  Positioned.fill(
                    child: Obx(
                      () => Padding(
                        padding: EdgeInsets.only(
                          bottom: controller.isPanelOpen.value ? 420 : 130,
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: _calculateCanvasWidth(context, controller),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                controller.viewport.value == ViewportMode.desktop
                                    ? 14
                                    : 24,
                              ),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                controller.viewport.value == ViewportMode.desktop
                                    ? 14
                                    : 24,
                              ),
                              child: Column(
                                children: [
                                  // Desktop browser title bar (Screenshots 4 & 5)
                                  if (controller.viewport.value == ViewportMode.desktop)
                                    _buildDesktopBrowserBar(controller),

                                  // WebView
                                  Expanded(
                                    child: controller.isLoading.value ||
                                            controller.webViewController == null
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF0F172A),
                                            ),
                                          )
                                        : WebViewWidget(
                                            controller: controller.webViewController!,
                                            gestureRecognizers: {
                                              Factory<OneSequenceGestureRecognizer>(
                                                () => EagerGestureRecognizer(),
                                              ),
                                            },
                                          ),
                                  ),
                                ],
                              ),
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

                  // Bottom Dock & Floating AI Pill (Preview Mode - Screenshots 1, 2, 4, 5)
                  Obx(
                    () => AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: 0,
                      right: 0,
                      bottom: controller.isPanelOpen.value ? -400 : 0,
                      child: IgnorePointer(
                        ignoring: controller.isPanelOpen.value,
                        child: _buildFloatingBottomDock(context, controller),
                      ),
                    ),
                  ),

                  // Bottom Docked Panel (Edit/Layers/Add/Design - Screenshot 3)
                  Obx(
                    () => AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: 0,
                      right: 0,
                      bottom: controller.isPanelOpen.value ? 0 : -450,
                      child: IgnorePointer(
                        ignoring: !controller.isPanelOpen.value,
                        child: _buildBottomPanel(context, controller),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _calculateCanvasWidth(BuildContext context, EditorController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (controller.viewport.value) {
      case ViewportMode.mobile:
        return min(375.0, screenWidth - 20);
      case ViewportMode.tablet:
        return min(600.0, screenWidth - 20);
      case ViewportMode.desktop:
        return double.infinity;
    }
  }

  Widget _buildDesktopBrowserBar(EditorController controller) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  controller.siteDomain,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
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

  Widget _buildTopBar(BuildContext context, EditorController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Back < | Site Name & Status | Publish button
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.websiteName.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            controller.isSaving.value
                                ? LucideIcons.refreshCw
                                : LucideIcons.check,
                            size: 13,
                            color: controller.isSaving.value
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            controller.isSaving.value ? 'Saving...' : 'Saved',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Black Publish Pill
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isPublishing.value
                      ? null
                      : controller.publishWebsite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: controller.isPublishing.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Publish',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Undo / Redo | [ 📱 Mobile | 📱 | 🖥️ ] | Eye preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Undo / Redo
              Obx(
                () => Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.undo2, size: 19),
                      color: controller.canUndo
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: controller.canUndo ? controller.undo : null,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(LucideIcons.redo2, size: 19),
                      color: controller.canRedo
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: controller.canRedo ? controller.redo : null,
                    ),
                  ],
                ),
              ),

              // Viewport Switcher Capsule
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Mobile
                      _buildViewportButton(
                        controller: controller,
                        mode: ViewportMode.mobile,
                        icon: LucideIcons.smartphone,
                        label: 'Mobile',
                      ),
                      const SizedBox(width: 2),
                      // Tablet
                      _buildViewportButton(
                        controller: controller,
                        mode: ViewportMode.tablet,
                        icon: LucideIcons.tablet,
                        label: 'Tablet',
                        iconOnlyWhenInactive: true,
                      ),
                      const SizedBox(width: 2),
                      // Desktop
                      _buildViewportButton(
                        controller: controller,
                        mode: ViewportMode.desktop,
                        icon: LucideIcons.monitor,
                        label: 'Desktop',
                        iconOnlyWhenInactive: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Preview Eye
              IconButton(
                icon: const Icon(
                  LucideIcons.eye,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  controller.isPanelOpen.value = !controller.isPanelOpen.value;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewportButton({
    required EditorController controller,
    required ViewportMode mode,
    required IconData icon,
    required String label,
    bool iconOnlyWhenInactive = false,
  }) {
    final isSelected = controller.viewport.value == mode;

    return GestureDetector(
      onTap: () => controller.setViewport(mode),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 8 : (iconOnlyWhenInactive ? 6 : 8),
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isSelected ? Border.all(color: const Color(0xFFE2E8F0)) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
            if (isSelected || !iconOnlyWhenInactive) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // FLOATING BOTTOM DOCK (Screenshots 1, 2, 4, 5)
  Widget _buildFloatingBottomDock(BuildContext context, EditorController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Floating "Ask AI" pill
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFC084FC).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Glowing AI Sphere
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      radius: 0.8,
                      colors: [
                        Color(0xFF38BDF8),
                        Color(0xFF818CF8),
                        Color(0xFFC084FC),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF818CF8),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Dynamic Placeholder text / input field
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: controller.aiPromptController,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: controller.aiPromptPlaceholder.value,
                        hintStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => controller.submitAiPrompt(),
                    ),
                  ),
                ),

                // Purple Upward Arrow Button
                Obx(
                  () => GestureDetector(
                    onTap: controller.isAiEditing.value
                        ? null
                        : controller.submitAiPrompt,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: controller.isAiEditing.value
                          ? const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            )
                          : const Icon(
                              LucideIcons.arrowUp,
                              size: 17,
                              color: Color(0xFF4F46E5),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. White Rounded Navigation Dock: [+ Add | ✎ Edit | Layers | Design]
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(
                  icon: LucideIcons.plus,
                  label: 'Add',
                  onTap: () {
                    controller.selectedTab.value = 0;
                    controller.isPanelOpen.value = true;
                  },
                ),
                _buildDockItem(
                  icon: LucideIcons.pencil,
                  label: 'Edit',
                  onTap: () {
                    controller.selectedTab.value = 1;
                    controller.isPanelOpen.value = true;
                  },
                ),
                _buildDockItem(
                  icon: LucideIcons.layers,
                  label: 'Layers',
                  onTap: () {
                    controller.selectedTab.value = 2;
                    controller.isPanelOpen.value = true;
                  },
                ),
                _buildDockItem(
                  icon: LucideIcons.palette,
                  label: 'Design',
                  onTap: () {
                    controller.selectedTab.value = 3;
                    controller.isPanelOpen.value = true;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: const Color(0xFF0F172A)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM DOCKED PANEL (Screenshot 3 & Modal Tabs)
  Widget _buildBottomPanel(BuildContext context, EditorController controller) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Tabs row: [ Add | Edit | Layers | Design ] and (✕)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Tabs Capsule
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          _buildTabItem(controller, index: 0, title: 'Add'),
                          _buildTabItem(controller, index: 1, title: 'Edit'),
                          _buildTabItem(controller, index: 2, title: 'Layers'),
                          _buildTabItem(controller, index: 3, title: 'Design'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Round Close Button (✕)
                GestureDetector(
                  onTap: () => controller.isPanelOpen.value = false,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Active Tab Body
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 0:
                  return _buildAddTab(controller);
                case 1:
                  return _buildEditTab(controller);
                case 2:
                  return _buildLayersTab(controller);
                case 3:
                  return _buildDesignTab(controller);
                default:
                  return _buildAddTab(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    EditorController controller, {
    required int index,
    required String title,
  }) {
    final isSelected = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 0: ADD
  Widget _buildAddTab(EditorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Drag onto your page, or tap to add below the selection',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              _buildSectionCard(
                title: 'Hero',
                card: _buildHeroThumbnail(),
                onTap: () => controller.addSection('hero'),
              ),
              _buildSectionCard(
                title: 'Products',
                card: _buildProductsThumbnail(),
                onTap: () => controller.addSection('products'),
              ),
              _buildSectionCard(
                title: 'Story',
                card: _buildStoryThumbnail(),
                onTap: () => controller.addSection('story'),
              ),
              _buildSectionCard(
                title: 'Gallery',
                card: _buildGalleryThumbnail(),
                onTap: () => controller.addSection('gallery'),
              ),
              _buildSectionCard(
                title: 'Text',
                card: _buildTextThumbnail(),
                onTap: () => controller.addSection('text'),
              ),
              _buildSectionCard(
                title: 'Call to action',
                card: _buildCtaThumbnail(),
                onTap: () => controller.addSection('cta'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget card,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: card,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroThumbnail() {
    return Container(
      color: const Color(0xFFFBF7F2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            width: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFB85028),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsThumbnail() {
    return Container(
      color: const Color(0xFFFBF7F2),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFD4B79C),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryThumbnail() {
    return Container(
      color: const Color(0xFFFBF7F2),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFD4B79C),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryThumbnail() {
    return Container(
      color: const Color(0xFFFBF7F2),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4B79C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4B79C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextThumbnail() {
    return Container(
      color: const Color(0xFFFBF7F2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 3,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaThumbnail() {
    return Container(
      color: const Color(0xFFB85028),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 5,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 9,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: EDIT
  Widget _buildEditTab(EditorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              controller.selectedElementContext.value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Field: Text
          const Text(
            'Text',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.textController,
            maxLines: null,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
            onChanged: (val) => controller.updateText(val),
          ),

          const SizedBox(height: 14),

          // Field: Size
          const Text(
            'Size',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _buildSizeOption(controller, 'Small'),
                  _buildSizeOption(controller, 'Medium'),
                  _buildSizeOption(controller, 'Large'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Field: Subtitle / Description (if applicable)
          if (controller.subheadlineController.text.isNotEmpty) ...[
            const Text(
              'Subtitle / Description',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller.subheadlineController,
              maxLines: null,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
              onChanged: (val) {
                controller.selectedElementKey.value = 'subheadline';
                controller.updateText(val);
              },
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildSizeOption(EditorController controller, String sizeLabel) {
    final isSelected = controller.selectedElementSize.value == sizeLabel;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.updateSize(sizeLabel),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            sizeLabel,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 2: LAYERS (Screenshot matching media_1793959339832_3e85492f.jpg)
  Widget _buildLayersTab(EditorController controller) {
    return Obx(() {
      final sections = controller.currentSections;

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        children: [
          // 1. Navigation layer
          _buildLayerRow(
            iconWidget: _buildNavIcon(controller.selectedSectionId.value == 'sec_navigation'),
            title: 'Navigation',
            isVisible: true,
            isSelected: controller.selectedSectionId.value == 'sec_navigation',
            onTap: () => controller.selectSection('sec_navigation'),
            onToggleVisibility: () {},
          ),

          // 2. Dynamic sections list
          ...sections.map((sec) {
            final id = sec['id'] as String? ?? '';
            final compRaw = (sec['component'] as String? ?? 'section').toLowerCase();
            final comp = compRaw.capitalizeFirst ?? 'Section';
            final isSelected = controller.selectedSectionId.value == id;
            final isVisible = sec['visible'] ?? true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLayerRow(
                  iconWidget: _getSectionIconWidget(compRaw, isSelected),
                  title: comp,
                  isVisible: isVisible,
                  isSelected: isSelected,
                  onTap: () => controller.selectSection(id),
                  onToggleVisibility: () => controller.toggleSectionVisibility(id),
                  onMoveUp: () => controller.moveSection(id, 'up'),
                  onMoveDown: () => controller.moveSection(id, 'down'),
                ),
                // Indented child: Heading (Matching Screenshot exactly)
                if (isSelected)
                  _buildChildLayerRow(
                    label: 'Heading',
                    onTap: () {
                      controller.selectedTab.value = 1; // Open Edit tab
                    },
                  ),
              ],
            );
          }),

          // 3. Footer layer
          _buildLayerRow(
            iconWidget: _buildFooterIcon(controller.selectedSectionId.value == 'sec_footer'),
            title: 'Footer',
            isVisible: true,
            isSelected: controller.selectedSectionId.value == 'sec_footer',
            onTap: () => controller.selectSection('sec_footer'),
            onToggleVisibility: () {},
          ),
        ],
      );
    });
  }

  Widget _buildLayerRow({
    required Widget iconWidget,
    required String title,
    required bool isVisible,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onToggleVisibility,
    VoidCallback? onMoveUp,
    VoidCallback? onMoveDown,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            if (isSelected) ...[
              GestureDetector(
                onTap: onMoveUp,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Icon(
                    LucideIcons.chevronUp,
                    size: 19,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMoveDown,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 19,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: onToggleVisibility,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Icon(
                  isVisible
                      ? LucideIcons.eye
                      : LucideIcons.eyeOff,
                  size: 19,
                  color: isVisible
                      ? const Color(0xFF64748B)
                      : const Color(0xFFCBD5E1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildLayerRow({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 38,
        child: Stack(
          children: [
            // Vertical tree line aligned with the center of the icon above (left = 21px)
            Positioned(
              left: 21,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1.2,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            // Indented child element text
            Positioned(
              left: 50,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A);
    return Container(
      width: 17,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Column(
        children: [
          Container(
            height: 3.5,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color, width: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A);
    return Container(
      width: 17,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Column(
        children: [
          Container(
            height: 4.5,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color, width: 1.2)),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: color, width: 1.2)),
                    ),
                  ),
                ),
                const Expanded(flex: 5, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A);
    return Container(
      width: 17,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 3.5,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: color, width: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSectionIconWidget(String component, bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A);

    switch (component.toLowerCase()) {
      case 'hero':
        return _buildHeroIcon(isSelected);
      case 'products':
        return Icon(LucideIcons.shoppingBag, size: 20, color: color);
      case 'story':
      case 'about':
        return Icon(LucideIcons.bookOpen, size: 20, color: color);
      case 'visit':
      case 'contact':
        return Icon(LucideIcons.mapPin, size: 20, color: color);
      case 'gallery':
        return Icon(LucideIcons.image, size: 20, color: color);
      case 'text':
        return Icon(LucideIcons.fileText, size: 20, color: color);
      case 'cta':
        return Icon(LucideIcons.mousePointerClick, size: 20, color: color);
      case 'footer':
        return _buildFooterIcon(isSelected);
      default:
        return Icon(LucideIcons.layoutGrid, size: 20, color: color);
    }
  }

  // TAB 3: DESIGN
  Widget _buildDesignTab(EditorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.colorPresets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.36,
            ),
            itemBuilder: (context, index) {
              final preset = controller.colorPresets[index];
              return Obx(() {
                final isSelected =
                    controller.selectedColorPreset.value == preset.name;
                return GestureDetector(
                  onTap: () => controller.selectColorPreset(preset),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: preset.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aa',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: preset.aaColor,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: preset.dot1,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: preset.dot2,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          preset.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: preset.aaColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Fonts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.fontPresets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.36,
            ),
            itemBuilder: (context, index) {
              final preset = controller.fontPresets[index];
              return Obx(() {
                final isSelected =
                    controller.selectedFontPreset.value == preset.name;
                return GestureDetector(
                  onTap: () => controller.selectFontPreset(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Text(
                            'Aa',
                            style: preset.aaStyle.copyWith(
                              fontSize: 22,
                            ),
                          ),
                        ),
                        Text(
                          preset.name,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
