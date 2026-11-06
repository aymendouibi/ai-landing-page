import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
            // Top Bar: Row 1 & Row 2
            _buildTopBar(context, controller),

            // Canvas & Bottom Panel
            Expanded(
              child: Stack(
                children: [
                  // Canvas (Webview) Area
                  Positioned.fill(
                    child: Obx(
                      () => Padding(
                        padding: EdgeInsets.only(
                          bottom: controller.isPanelOpen.value ? 350 : 60,
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
                                    ? 0
                                    : 20,
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
                                    ? 0
                                    : 20,
                              ),
                              child: controller.isLoading.value ||
                                      controller.webViewController == null
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0F172A),
                                      ),
                                    )
                                  : WebViewWidget(
                                      controller: controller.webViewController!,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Docked Panel
                  Obx(
                    () => controller.isPanelOpen.value
                        ? Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildBottomPanel(context, controller),
                          )
                        : Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: () => controller.isPanelOpen.value = true,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Open Editor Panel',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                  Icons.arrow_back_ios_new,
                  size: 18,
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
                                ? Icons.sync
                                : Icons.check,
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
                      icon: const Icon(Icons.undo, size: 20),
                      color: controller.canUndo
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: controller.canUndo ? controller.undo : null,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.redo, size: 20),
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
                        icon: Icons.phone_android,
                        label: 'Mobile',
                      ),
                      const SizedBox(width: 2),
                      // Tablet
                      _buildViewportButton(
                        controller: controller,
                        mode: ViewportMode.tablet,
                        icon: Icons.tablet_mac_outlined,
                        label: 'Tablet',
                        iconOnlyWhenInactive: true,
                      ),
                      const SizedBox(width: 2),
                      // Desktop
                      _buildViewportButton(
                        controller: controller,
                        mode: ViewportMode.desktop,
                        icon: Icons.desktop_windows_outlined,
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
                  Icons.remove_red_eye_outlined,
                  size: 21,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  // Toggle panel to preview full page
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

  Widget _buildBottomPanel(BuildContext context, EditorController controller) {
    return Container(
      height: 350,
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
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
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
          // Context title: e.g. Heading in Hero
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

  // TAB 2: LAYERS
  Widget _buildLayersTab(EditorController controller) {
    final sections = controller.currentSections;
    if (sections.isEmpty) {
      return const Center(
        child: Text(
          'No sections on page. Add one from the Add tab!',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final sec = sections[index];
        final id = sec['id'] as String? ?? '';
        final comp = (sec['component'] as String? ?? 'section').capitalizeFirst ?? 'Section';
        final isSelected = controller.selectedSectionId.value == id;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getSectionIcon(sec['component'] as String?),
                size: 18,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$comp Section',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                onPressed: index > 0
                    ? () => controller.reorderSections(index, index - 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                onPressed: index < sections.length - 1
                    ? () => controller.reorderSections(index, index + 2)
                    : null,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () => controller.deleteSection(id),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSectionIcon(String? component) {
    switch (component?.toLowerCase()) {
      case 'hero':
        return Icons.view_headline;
      case 'products':
        return Icons.grid_view;
      case 'story':
        return Icons.auto_stories;
      case 'gallery':
        return Icons.photo_library;
      case 'text':
        return Icons.article;
      case 'cta':
        return Icons.touch_app;
      case 'features':
        return Icons.star_outline;
      case 'testimonials':
        return Icons.format_quote;
      default:
        return Icons.layers;
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
            'Primary Brand Color',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildColorSwatch(controller, '#B85028', const Color(0xFFB85028)),
              _buildColorSwatch(controller, '#2563EB', const Color(0xFF2563EB)),
              _buildColorSwatch(controller, '#15803D', const Color(0xFF15803D)),
              _buildColorSwatch(controller, '#BE123C', const Color(0xFFBE123C)),
              _buildColorSwatch(controller, '#0F172A', const Color(0xFF0F172A)),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Heading Font Family',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFontChip(controller, 'Inter'),
              _buildFontChip(controller, 'Playfair Display'),
              _buildFontChip(controller, 'Plus Jakarta Sans'),
              _buildFontChip(controller, 'Cinzel'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(
    EditorController controller,
    String hex,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => controller.updateThemeColor(hex),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontChip(EditorController controller, String fontName) {
    return GestureDetector(
      onTap: () => controller.updateTypography(fontName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          fontName,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
