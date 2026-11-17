import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/widgets/app_showcase.dart';
import '../editor_controller.dart';

class EditorFloatingBottomDock extends StatelessWidget {
  final EditorController controller;

  const EditorFloatingBottomDock({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Floating "Ask AI" pill
          EditorFloatingAiPill(controller: controller, isLandscape: false),

          const SizedBox(height: 10),

          // 2. Rounded Navigation Dock: [+ Add | ✎ Edit | Layers | Design]
          AppShowcase.item(
            key: controller.showcaseDockKey,
            title: 'showcase_toolkit_title'.tr,
            description: 'showcase_toolkit_desc'.tr,
            targetPadding: const EdgeInsets.all(4),
            targetShapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.borderSubtleOf(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.isDark(context)
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  EditorDockItem(
                    icon: LucideIcons.plus,
                    label: 'tab_add'.tr,
                    onTap: () {
                      controller.selectedTab.value = 0;
                      controller.isPanelOpen.value = true;
                    },
                  ),
                  EditorDockItem(
                    icon: LucideIcons.pencil,
                    label: 'tab_edit'.tr,
                    onTap: () {
                      controller.selectedTab.value = 1;
                      controller.isPanelOpen.value = true;
                    },
                  ),
                  EditorDockItem(
                    icon: LucideIcons.layers,
                    label: 'tab_layers'.tr,
                    onTap: () {
                      controller.selectedTab.value = 2;
                      controller.isPanelOpen.value = true;
                    },
                  ),
                  EditorDockItem(
                    icon: LucideIcons.palette,
                    label: 'tab_design'.tr,
                    onTap: () {
                      controller.selectedTab.value = 3;
                      controller.isPanelOpen.value = true;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditorLandscapeFloatingDock extends StatelessWidget {
  final EditorController controller;

  const EditorLandscapeFloatingDock({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 420;
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              // 1. Floating AI pill (flexible)
              Expanded(
                child: EditorFloatingAiPill(
                  controller: controller,
                  isLandscape: true,
                ),
              ),
              const SizedBox(width: 8),
              // 2. Navigation Dock Tabs
              AppShowcase.item(
                key: controller.showcaseDockKey,
                title: 'showcase_toolkit_title'.tr,
                description: 'showcase_toolkit_desc'.tr,
                targetPadding: const EdgeInsets.all(4),
                targetShapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderSubtleOf(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.isDark(context)
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EditorCompactDockItem(
                        icon: LucideIcons.plus,
                        label: isVeryNarrow ? '' : 'tab_add'.tr,
                        onTap: () {
                          controller.selectedTab.value = 0;
                          controller.isPanelOpen.value = true;
                        },
                      ),
                      EditorCompactDockItem(
                        icon: LucideIcons.pencil,
                        label: isVeryNarrow ? '' : 'tab_edit'.tr,
                        onTap: () {
                          controller.selectedTab.value = 1;
                          controller.isPanelOpen.value = true;
                        },
                      ),
                      EditorCompactDockItem(
                        icon: LucideIcons.layers,
                        label: isVeryNarrow ? '' : 'tab_layers'.tr,
                        onTap: () {
                          controller.selectedTab.value = 2;
                          controller.isPanelOpen.value = true;
                        },
                      ),
                      EditorCompactDockItem(
                        icon: LucideIcons.palette,
                        label: isVeryNarrow ? '' : 'tab_design'.tr,
                        onTap: () {
                          controller.selectedTab.value = 3;
                          controller.isPanelOpen.value = true;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditorFloatingAiPill extends StatelessWidget {
  final EditorController controller;
  final bool isLandscape;

  const EditorFloatingAiPill({
    super.key,
    required this.controller,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isLandscape ? 44 : 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
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
          // Glowing AI Sphere (tappable to open Ask AI sheet)
          GestureDetector(
            onTap: () => controller.openAskAiSheet(),
            child: Container(
              width: isLandscape ? 24 : 28,
              height: isLandscape ? 24 : 28,
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
          ),

          const SizedBox(width: 8),

          // Dynamic Placeholder text / input field
          Expanded(
            child: Obx(
              () => TextField(
                controller: controller.aiPromptController,
                style: TextStyle(
                  fontSize: isLandscape ? 12.5 : 13.5,
                  color: AppColors.inkOf(context),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: controller.aiPromptPlaceholder.value,
                  hintStyle: TextStyle(
                    color: AppColors.inkMutedOf(context),
                    fontSize: isLandscape ? 12.5 : 13.5,
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
                width: isLandscape ? 28 : 32,
                height: isLandscape ? 28 : 32,
                decoration: BoxDecoration(
                  color: AppColors.isDark(context)
                      ? const Color(0xFF312E81)
                      : const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: controller.isAiEditing.value
                    ? const Center(
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      )
                    : Icon(
                        LucideIcons.arrowUp,
                        size: isLandscape ? 15 : 17,
                        color: AppColors.isDark(context)
                            ? const Color(0xFF818CF8)
                            : const Color(0xFF4F46E5),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditorDockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const EditorDockItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: AppColors.inkOf(context)),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditorCompactDockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const EditorCompactDockItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.inkOf(context)),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkOf(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
