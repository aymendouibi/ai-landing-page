import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../editor_controller.dart';
import 'image_preview.dart';

class EditorAddTab extends StatelessWidget {
  final EditorController controller;

  const EditorAddTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isAddingImageSubView.value) {
        return AddImageView(controller: controller);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'add_drag_hint'.tr,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.inkMutedOf(context),
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
                SectionCard(
                  title: 'section_hero'.tr,
                  card: _buildHeroThumbnail(context),
                  onTap: () => controller.addSection('hero'),
                ),
                SectionCard(
                  title: 'section_products'.tr,
                  card: _buildProductsThumbnail(context),
                  onTap: () => controller.addSection('products'),
                ),
                SectionCard(
                  title: 'section_story'.tr,
                  card: _buildStoryThumbnail(context),
                  onTap: () => controller.addSection('story'),
                ),
                SectionCard(
                  title: 'section_gallery'.tr,
                  card: _buildGalleryThumbnail(context),
                  onTap: () => controller.addSection('gallery'),
                ),
                SectionCard(
                  title: 'section_text'.tr,
                  card: _buildTextThumbnail(context),
                  onTap: () => controller.addSection('text'),
                ),
                SectionCard(
                  title: 'section_cta'.tr,
                  card: _buildCtaThumbnail(context),
                  onTap: () => controller.addSection('cta'),
                ),
                SectionCard(
                  title: 'section_visit'.tr,
                  card: _buildVisitThumbnail(context),
                  onTap: () => controller.addSection('visit'),
                ),
                SectionCard(
                  title: 'section_image'.tr,
                  card: _buildImageThumbnail(context),
                  hasActiveBorder: true,
                  onTap: () => controller.openAddImageView(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeroThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF7F2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: 45,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF334155),
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

  Widget _buildProductsThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF7F2),
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
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFD4B79C),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF7F2),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFD4B79C),
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
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 26,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF334155),
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

  Widget _buildGalleryThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF7F2),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFD4B79C),
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
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFD4B79C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF7F2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 3,
            width: 55,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaThumbnail(BuildContext context) {
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

  Widget _buildVisitThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFE2D4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 4,
                width: 30,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF5A4D41),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 4,
                width: 18,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF5A4D41),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFD4A388),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF5EE),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 28,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget card;
  final VoidCallback onTap;
  final bool hasActiveBorder;

  const SectionCard({
    super.key,
    required this.title,
    required this.card,
    required this.onTap,
    this.hasActiveBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasActiveBorder
                      ? (AppColors.isDark(context)
                            ? Colors.white
                            : const Color(0xFF0F172A))
                      : AppColors.borderSubtleOf(context),
                  width: hasActiveBorder ? 1.5 : 1.0,
                ),
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: hasActiveBorder ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.inkOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class AddImageView extends StatelessWidget {
  final EditorController controller;

  const AddImageView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Header: Back Button + Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: GestureDetector(
            onTap: () => controller.closeAddImageView(),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: AppColors.inkOf(context),
                ),
                const SizedBox(width: 4),
                Obx(
                  () => Text(
                    controller.isReplacingImageMode.value
                        ? 'Replace image'
                        : 'Add image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Scrollable Upload Options & Your Uploads Grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Upload from device" Card
                GestureDetector(
                  onTap: () => controller.uploadImageFromDevice(
                    applyImmediately: controller.isReplacingImageMode.value,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderSubtleOf(context),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.02,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceNeutralOf(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.borderSubtleOf(context),
                            ),
                          ),
                          child: Icon(
                            LucideIcons.upload,
                            size: 20,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'editor_upload_from_device'.tr,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkOf(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'editor_upload_specs'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.inkMutedOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // "Your uploads" Section Header with Image Quota count
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'editor_your_uploads'.tr,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      Text(
                        '${controller.uploadedImages.length} ${'editor_images_count'.tr}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3-Column Image Uploads Grid
                Obx(
                  () => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.76,
                        ),
                    itemCount: controller.uploadedImages.length,
                    itemBuilder: (context, index) {
                      final img = controller.uploadedImages[index];
                      final isSelected =
                          controller.selectedUploadImageId.value == img.id;

                      return GestureDetector(
                        onTap: () {
                          controller.selectUploadImage(img.id);
                          if (controller.isReplacingImageMode.value) {
                            controller.applyImageToCurrentSection(img);
                            controller.closeAddImageView();
                            controller.selectedTab.value = 1;
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ImagePreview(
                                        url: img.url,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Selection Circle (Top Right)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? const Color(0xFF2563EB)
                                            : Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFFCBD5E1),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              LucideIcons.check,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                  // Delete Option (Top Left when selected)
                                  if (isSelected)
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: GestureDetector(
                                        onTap: () => controller
                                            .deleteUploadedImage(img.id),
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(
                                              alpha: 0.95,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.08,
                                                ),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            LucideIcons.trash2,
                                            size: 11,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Active outline if selected
                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF2563EB),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              img.filename,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AppColors.inkOf(context),
                              ),
                            ),
                            Text(
                              img.dimensions,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Sticky Bottom Bar: "✓ 1 selected · <filename>" + "[ Add to page ]" Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            border: Border(
              top: BorderSide(
                color: AppColors.borderSubtleOf(context),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final chosen = controller.uploadedImages.firstWhereOrNull(
                  (i) => i.id == controller.selectedUploadImageId.value,
                );
                final name = chosen?.filename ?? 'selected';
                return Row(
                  children: [
                    Icon(
                      LucideIcons.check,
                      size: 14,
                      color: AppColors.inkOf(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '1 selected · $name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => controller.addSelectedImageToPage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                    foregroundColor: isDark
                        ? const Color(0xFF0F172A)
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Obx(
                    () => Text(
                      controller.isReplacingImageMode.value
                          ? 'Replace image'
                          : 'Add to page',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
