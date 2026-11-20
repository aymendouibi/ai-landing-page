import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../editor_controller.dart';
import 'editor_add_tab.dart';
import 'editor_design_tab.dart';
import 'editor_edit_tab.dart';
import 'editor_layers_tab.dart';

class EditorBottomPanel extends StatelessWidget {
  final EditorController controller;

  const EditorBottomPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = (500.0 + bottomInset).clamp(500.0, screenHeight * 0.85);

    return Container(
      height: panelHeight,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtleOf(context), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark(context)
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: EditorPanelContent(controller: controller, isLandscape: false),
    );
  }
}

class EditorLandscapeSidePanel extends StatelessWidget {
  final EditorController controller;

  const EditorLandscapeSidePanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: controller.isPanelOpen.value ? 350.0 : 0.0,
        child: ClipRect(
          child: OverflowBox(
            minWidth: 350.0,
            maxWidth: 350.0,
            alignment: Alignment.topRight,
            child: Container(
              width: 350.0,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                border: Border(
                  left: BorderSide(color: AppColors.borderSubtleOf(context), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.isDark(context)
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: EditorPanelContent(controller: controller, isLandscape: true),
            ),
          ),
        ),
      ),
    );
  }
}

class EditorPanelContent extends StatelessWidget {
  final EditorController controller;
  final bool isLandscape;

  const EditorPanelContent({
    super.key,
    required this.controller,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isLandscape)
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )
        else
          const SizedBox(height: 10),

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
                    color: AppColors.surfaceNeutralOf(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      EditorTabItem(controller: controller, index: 0, title: 'tab_add'.tr),
                      EditorTabItem(controller: controller, index: 1, title: 'tab_edit'.tr),
                      EditorTabItem(controller: controller, index: 2, title: 'tab_layers'.tr),
                      EditorTabItem(controller: controller, index: 3, title: 'tab_design'.tr),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Round Close Button (✕)
              GestureDetector(
                onTap: () {
                  controller.isPanelOpen.value = false;
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceNeutralOf(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.inkOf(context),
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
                return EditorAddTab(controller: controller);
              case 1:
                return EditorEditTab(controller: controller);
              case 2:
                return EditorLayersTab(controller: controller);
              case 3:
                return EditorDesignTab(controller: controller);
              default:
                return EditorAddTab(controller: controller);
            }
          }),
        ),
      ],
    );
  }
}

class EditorTabItem extends StatelessWidget {
  final EditorController controller;
  final int index;
  final String title;

  const EditorTabItem({
    super.key,
    required this.controller,
    required this.index,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedTab.value == index;

        return InkWell(
          onTap: () => controller.selectedTab.value = index,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surfaceOf(context) : Colors.transparent,
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
                    ? AppColors.inkOf(context)
                    : AppColors.inkMutedOf(context),
              ),
            ),
          ),
        );
      }),
    );
  }
}
