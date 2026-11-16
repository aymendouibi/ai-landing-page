import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_showcase.dart';
import '../editor_controller.dart';

class EditorTopBar extends StatelessWidget {
  final EditorController controller;

  const EditorTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtleOf(context), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Back < | Site Name & Status | Publish button
          Row(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: AppColors.inkOf(context),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  controller.setPortrait();
                  Get.offAllNamed(AppRoutes.dashboard);
                },
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkOf(context),
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
                                : AppColors.inkMutedOf(context),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            controller.isSaving.value ? 'saving'.tr : 'saved'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMutedOf(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Settings / Config Button
              IconButton(
                icon: Icon(
                  LucideIcons.settings,
                  size: 19,
                  color: AppColors.inkOf(context),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'editor_website_config'.tr,
                onPressed: () {
                  controller.setPortrait();
                  Get.toNamed(
                    AppRoutes.websiteConfig,
                    arguments: {'websiteId': controller.websiteId},
                  );
                },
              ),
              const SizedBox(width: 6),
              // Rotate Button
              EditorRotateButton(controller: controller),
              const SizedBox(width: 8),
              // Black/White Publish Pill
              EditorPublishButton(controller: controller),
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
                      visualDensity: VisualDensity.compact,
                      color: controller.canUndo
                          ? AppColors.inkOf(context)
                          : (AppColors.isDark(context)
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: controller.canUndo ? controller.undo : null,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(LucideIcons.redo2, size: 19),
                      visualDensity: VisualDensity.compact,
                      color: controller.canRedo
                          ? AppColors.inkOf(context)
                          : (AppColors.isDark(context)
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: controller.canRedo ? controller.redo : null,
                    ),
                  ],
                ),
              ),

              // Viewport Switcher Capsule
              EditorViewportCapsule(controller: controller),

              // Preview Eye Button
              IconButton(
                icon: Icon(
                  LucideIcons.eye,
                  size: 20,
                  color: AppColors.inkMutedOf(context),
                ),
                visualDensity: VisualDensity.compact,
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
}

class EditorLandscapeTopBar extends StatelessWidget {
  final EditorController controller;

  const EditorLandscapeTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtleOf(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.inkOf(context)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              controller.setPortrait();
              Get.offAllNamed(AppRoutes.dashboard);
            },
          ),
          const SizedBox(width: 6),
          // Website name & saved status
          Flexible(
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.websiteName.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      controller.isSaving.value
                          ? LucideIcons.refreshCw
                          : LucideIcons.check,
                      size: 12,
                      color: controller.isSaving.value
                          ? const Color(0xFF3B82F6)
                          : AppColors.inkMutedOf(context),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      controller.isSaving.value ? 'saving'.tr : 'saved'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMutedOf(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Undo / Redo
          Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.undo2, size: 17),
                  color: controller.canUndo
                      ? AppColors.inkOf(context)
                      : (AppColors.isDark(context)
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: controller.canUndo ? controller.undo : null,
                ),
                IconButton(
                  icon: const Icon(LucideIcons.redo2, size: 17),
                  color: controller.canRedo
                      ? AppColors.inkOf(context)
                      : (AppColors.isDark(context)
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: controller.canRedo ? controller.redo : null,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Viewport Switcher Capsule
          EditorViewportCapsule(controller: controller),

          const SizedBox(width: 8),

          // Rotate Button
          EditorRotateButton(controller: controller),

          const SizedBox(width: 4),

          // Toggle Inspector / Layers Button
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isPanelOpen.value ? LucideIcons.panelRightClose : LucideIcons.panelRightOpen,
                size: 19,
                color: controller.isPanelOpen.value
                    ? const Color(0xFF2563EB)
                    : AppColors.inkMutedOf(context),
              ),
            ),
            tooltip: 'toggle_panel'.tr,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              controller.isPanelOpen.value = !controller.isPanelOpen.value;
            },
          ),

          const SizedBox(width: 8),

          // Settings / Config Button
          IconButton(
            icon: Icon(
              LucideIcons.settings,
              size: 17,
              color: AppColors.inkOf(context),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'editor_website_config'.tr,
            onPressed: () {
              controller.setPortrait();
              Get.toNamed(
                AppRoutes.websiteConfig,
                arguments: {'websiteId': controller.websiteId},
              );
            },
          ),

          const SizedBox(width: 10),

          // Publish Button
          EditorPublishButton(controller: controller, isLandscape: true),
        ],
      ),
    );
  }
}

class EditorViewportCapsule extends StatelessWidget {
  final EditorController controller;

  const EditorViewportCapsule({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceNeutralOf(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtleOf(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mobile
          EditorViewportButton(
            controller: controller,
            mode: ViewportMode.mobile,
            icon: LucideIcons.smartphone,
            label: 'viewport_mobile'.tr,
          ),
          const SizedBox(width: 2),
          // Tablet
          EditorViewportButton(
            controller: controller,
            mode: ViewportMode.tablet,
            icon: LucideIcons.tablet,
            label: 'viewport_tablet'.tr,
            iconOnlyWhenInactive: true,
          ),
          const SizedBox(width: 2),
          // Desktop
          EditorViewportButton(
            controller: controller,
            mode: ViewportMode.desktop,
            icon: LucideIcons.monitor,
            label: 'viewport_desktop'.tr,
            iconOnlyWhenInactive: true,
          ),
        ],
      ),
    );
  }
}

class EditorRotateButton extends StatelessWidget {
  final EditorController controller;

  const EditorRotateButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppShowcase.item(
      key: controller.showcaseRotateKey,
      title: 'editor_rotate_screen'.tr,
      description: 'showcase_rotate_desc'.tr,
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: controller.isLandscape.value
                ? (AppColors.isDark(context)
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFFEFF6FF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: controller.isLandscape.value
                ? Border.all(
                    color: AppColors.isDark(context)
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFBFDBFE),
                  )
                : null,
          ),
          child: IconButton(
            icon: Icon(
              LucideIcons.rotateCw,
              size: 18,
              color: controller.isLandscape.value
                  ? const Color(0xFF2563EB)
                  : AppColors.inkMutedOf(context),
            ),
            tooltip: controller.isLandscape.value
                ? 'switch_portrait'.tr
                : 'switch_landscape'.tr,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: controller.toggleLandscape,
          ),
        ),
      ),
    );
  }
}

class EditorPublishButton extends StatelessWidget {
  final EditorController controller;
  final bool isLandscape;

  const EditorPublishButton({
    super.key,
    required this.controller,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppShowcase.item(
      key: controller.showcasePublishKey,
      title: 'editor_publish_live'.tr,
      description: 'showcase_publish_desc'.tr,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isPublishing.value
              ? null
              : controller.publishWebsite,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.isDark(context)
                ? Colors.white
                : const Color(0xFF0F172A),
            foregroundColor: AppColors.isDark(context)
                ? const Color(0xFF0F172A)
                : Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 14 : 18,
              vertical: isLandscape ? 6 : 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: controller.isPublishing.value
              ? SizedBox(
                  width: isLandscape ? 12 : 14,
                  height: isLandscape ? 12 : 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.isDark(context)
                        ? const Color(0xFF0F172A)
                        : Colors.white,
                  ),
                )
              : Text(
                  'publish'.tr,
                  style: TextStyle(
                    fontSize: isLandscape ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class EditorViewportButton extends StatelessWidget {
  final EditorController controller;
  final ViewportMode mode;
  final IconData icon;
  final String label;
  final bool iconOnlyWhenInactive;

  const EditorViewportButton({
    super.key,
    required this.controller,
    required this.mode,
    required this.icon,
    required this.label,
    this.iconOnlyWhenInactive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.viewport.value == mode;

      return GestureDetector(
        onTap: () => controller.setViewport(mode),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 8 : (iconOnlyWhenInactive ? 6 : 8),
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceOf(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: isSelected ? Border.all(color: AppColors.borderSubtleOf(context)) : null,
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
                color: isSelected
                    ? AppColors.inkOf(context)
                    : AppColors.inkMutedOf(context),
              ),
              if (isSelected || !iconOnlyWhenInactive) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.inkOf(context)
                        : AppColors.inkMutedOf(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
