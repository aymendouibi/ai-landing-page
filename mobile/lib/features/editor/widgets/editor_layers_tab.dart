import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../editor_controller.dart';

class EditorLayersTab extends StatelessWidget {
  final EditorController controller;

  const EditorLayersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sections = controller.currentSections;

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        children: [
          // 1. Navigation layer
          LayerRow(
            iconWidget: _buildNavIcon(context, controller.selectedSectionId.value == 'sec_navigation'),
            title: 'layer_navigation'.tr,
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
                LayerRow(
                  iconWidget: _getSectionIconWidget(context, compRaw, isSelected),
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
                  ChildLayerRow(
                    label: 'layer_heading'.tr,
                    onTap: () {
                      controller.selectedTab.value = 1; // Open Edit tab
                    },
                  ),
              ],
            );
          }),

          // 3. Footer layer
          LayerRow(
            iconWidget: _buildFooterIcon(context, controller.selectedSectionId.value == 'sec_footer'),
            title: 'layer_footer'.tr,
            isVisible: true,
            isSelected: controller.selectedSectionId.value == 'sec_footer',
            onTap: () => controller.selectSection('sec_footer'),
            onToggleVisibility: () {},
          ),
        ],
      );
    });
  }

  Widget _buildNavIcon(BuildContext context, bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : AppColors.inkOf(context);
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

  Widget _buildHeroIcon(BuildContext context, bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : AppColors.inkOf(context);
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

  Widget _buildFooterIcon(BuildContext context, bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : AppColors.inkOf(context);
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

  Widget _getSectionIconWidget(BuildContext context, String component, bool isSelected) {
    final color = isSelected ? const Color(0xFF2563EB) : AppColors.inkOf(context);

    switch (component.toLowerCase()) {
      case 'hero':
        return _buildHeroIcon(context, isSelected);
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
        return _buildFooterIcon(context, isSelected);
      default:
        return Icon(LucideIcons.layoutGrid, size: 20, color: color);
    }
  }
}

class LayerRow extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final bool isVisible;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const LayerRow({
    super.key,
    required this.iconWidget,
    required this.title,
    required this.isVisible,
    required this.isSelected,
    required this.onTap,
    required this.onToggleVisibility,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (AppColors.isDark(context)
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
                  : const Color(0xFFEFF6FF))
              : Colors.transparent,
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
                  color: AppColors.inkOf(context),
                ),
              ),
            ),
            if (isSelected) ...[
              GestureDetector(
                onTap: onMoveUp,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Icon(
                    LucideIcons.chevronUp,
                    size: 19,
                    color: AppColors.inkOf(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMoveDown,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 19,
                    color: AppColors.inkOf(context),
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
                      ? (AppColors.isDark(context)
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B))
                      : (AppColors.isDark(context)
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildLayerRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ChildLayerRow({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.isDark(context)
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
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
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkSecondaryOf(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

