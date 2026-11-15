import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../editor_controller.dart';
import 'editor_add_tab.dart';
import 'editor_icon_helper.dart';
import 'image_preview.dart';

class _EditTheme {
  static Color cardBg(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF1E293B)
      : const Color(0xFFF8FAFC);

  static Color cardBorder(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF334155)
      : const Color(0xFFE2E8F0);

  static Color fieldBg(BuildContext context) =>
      AppColors.isDark(context) ? const Color(0xFF0F172A) : Colors.white;

  static Color fieldBorder(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF334155)
      : const Color(0xFFE2E8F0);

  static Color chipBg(BuildContext context) =>
      AppColors.isDark(context) ? const Color(0xFF334155) : Colors.white;

  static Color chipBorder(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF475569)
      : const Color(0xFFCBD5E1);

  static Color capsuleBg(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF0F172A)
      : const Color(0xFFF1F5F9);

  static Color divider(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF334155)
      : const Color(0xFFE2E8F0);
}

class EditorEditTab extends StatelessWidget {
  final EditorController controller;

  const EditorEditTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isAddingImageSubView.value) {
        return AddImageView(controller: controller);
      }

      if (controller.selectedSectionType.value == 'image') {
        return ImageEditTab(controller: controller);
      }

      final secId = controller.selectedSectionId.value;
      if (secId == null || secId.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.mousePointerClick,
                  size: 38,
                  color: AppColors.inkMutedOf(context),
                ),
                const SizedBox(height: 12),
                Text(
                  'editor_no_section_selected'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'editor_no_section_desc'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final comp = controller.selectedSectionType.value.toLowerCase();
      final isNav = comp == 'navigation' || secId == 'sec_navigation';
      final isFooter = comp == 'footer' || secId == 'sec_footer';
      final isHero = comp == 'hero';
      final isCta = comp == 'cta';
      final isTestimonials = comp == 'testimonials' || comp == 'reviews';
      final isStats = comp == 'statistics' || comp == 'metrics';
      final isFeatures = comp == 'features' || comp == 'benefits';
      final isProducts =
          comp == 'products' ||
          comp == 'pricing' ||
          comp == 'store' ||
          comp == 'product_grid' ||
          comp == 'pricing_grid';
      final isFaq = comp == 'faq';
      final isContact = comp == 'contact' || comp == 'visit';
      final isGallery = comp == 'gallery';
      final isAboutOrStory = comp == 'about' || comp == 'story';

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Header & Actions (Move Up, Move Down, Duplicate, Delete)
            _SectionHeaderAndActionsCard(
              controller: controller,
              sectionId: secId,
              compName: comp,
              isNav: isNav,
              isFooter: isFooter,
            ),

            const SizedBox(height: 12),

            // Wix Section Style & Layout Toolbar (For all sections except Navigation)
            if (!isNav) ...[
              _WixSectionStyleToolbar(controller: controller),
              const SizedBox(height: 14),
            ],

            // Section Specific Specialized Editors
            if (isNav) ...[
              _NavigationEditorCard(controller: controller),
            ] else if (isFooter) ...[
              _FooterEditorCard(controller: controller),
            ] else if (isProducts) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'Section Title',
                subtitleLabel: 'Section Subtitle',
                titleHint: 'e.g. Our Products, Offerings...',
                subtitleHint: 'Supporting description for products...',
              ),
              const SizedBox(height: 14),
              _ProductsEditorList(controller: controller),
            ] else if (isFeatures) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'Features Title',
                subtitleLabel: 'Features Subtitle',
                titleHint: 'e.g. Why Choose Us...',
                subtitleHint: 'Supporting description for features...',
              ),
              const SizedBox(height: 14),
              _FeaturesEditorList(controller: controller),
            ] else if (isFaq) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'FAQ Title',
                subtitleLabel: 'FAQ Subtitle',
                titleHint: 'e.g. Frequently Asked Questions...',
                subtitleHint: 'Common answers for our customers...',
              ),
              const SizedBox(height: 14),
              _FaqEditorList(controller: controller),
            ] else if (isContact) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'Contact Section Title',
                hasSubtitle: false,
                titleHint: 'e.g. Get in Touch, Visit Us...',
              ),
              const SizedBox(height: 14),
              _ContactEditorCard(controller: controller),
            ] else if (isTestimonials) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'Testimonials Title',
                subtitleLabel: 'Testimonials Subtitle',
                titleHint: 'e.g. Customer Love, Reviews...',
              ),
              const SizedBox(height: 14),
              _TestimonialsEditorList(controller: controller),
            ] else if (isGallery) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'Gallery Title',
                subtitleLabel: 'Gallery Subtitle',
                titleHint: 'e.g. Photo Showcase, Our Work...',
              ),
              const SizedBox(height: 14),
              _GalleryEditorList(controller: controller),
            ] else if (isStats) ...[
              _SectionTitleAndSubtitleEditor(
                controller: controller,
                titleLabel: 'Metrics Section Title',
                hasSubtitle: false,
                titleHint: 'e.g. Key Numbers, Impact...',
              ),
              const SizedBox(height: 14),
              _StatisticsEditorList(controller: controller),
            ] else if (isHero) ...[
              _EyebrowBadgeField(controller: controller),
              _SectionHeadlineField(
                controller: controller,
                label: 'Hero Headline',
              ),
              const SizedBox(height: 14),
              _SectionHeadlineSizeSelector(controller: controller),
              const SizedBox(height: 14),
              _SectionSubheadlineField(
                controller: controller,
                label: 'Hero Subheadline',
              ),
              const SizedBox(height: 14),
              _CtaEditorCard(controller: controller),
              if (controller.selectedImageProps.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionImageCard(controller: controller),
              ],
            ] else if (isCta) ...[
              if (controller.badgeController.text.isNotEmpty) ...[
                _EyebrowBadgeField(controller: controller),
              ],
              _SectionHeadlineField(
                controller: controller,
                label: 'Call to Action Headline',
              ),
              const SizedBox(height: 14),
              _SectionSubheadlineField(
                controller: controller,
                label: 'Subheadline',
              ),
              const SizedBox(height: 14),
              _CtaEditorCard(controller: controller),
            ] else if (isAboutOrStory) ...[
              _SectionHeadlineField(
                controller: controller,
                label: 'Story Headline',
              ),
              const SizedBox(height: 14),
              _SectionSubheadlineField(
                controller: controller,
                label: 'Story Body / Description',
              ),
              if (controller.selectedImageProps.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionImageCard(controller: controller),
              ],
            ] else ...[
              _SectionHeadlineField(controller: controller),
              const SizedBox(height: 14),
              _SectionSubheadlineField(controller: controller),
              if (controller.selectedImageProps.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionImageCard(controller: controller),
              ],
            ],

            // Collapsible Advanced JSON Properties
            if (!isNav && !isFooter) ...[
              const SizedBox(height: 18),
              _AdvancedPropsDisclosure(controller: controller),
            ],

            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}

class _SectionHeaderAndActionsCard extends StatelessWidget {
  final EditorController controller;
  final String sectionId;
  final String compName;
  final bool isNav;
  final bool isFooter;

  const _SectionHeaderAndActionsCard({
    required this.controller,
    required this.sectionId,
    required this.compName,
    required this.isNav,
    required this.isFooter,
  });

  IconData _iconForComp(String comp) {
    switch (comp.toLowerCase()) {
      case 'products':
      case 'store':
      case 'pricing':
      case 'product_grid':
      case 'pricing_grid':
        return LucideIcons.shoppingBag;
      case 'features':
      case 'benefits':
        return LucideIcons.sparkles;
      case 'faq':
        return LucideIcons.helpCircle;
      case 'contact':
      case 'visit':
        return LucideIcons.mail;
      case 'gallery':
        return LucideIcons.images;
      case 'testimonials':
      case 'reviews':
        return LucideIcons.messageSquareQuote;
      case 'statistics':
      case 'metrics':
        return LucideIcons.barChart2;
      case 'navigation':
        return LucideIcons.panelTop;
      case 'footer':
        return LucideIcons.panelBottom;
      case 'hero':
      default:
        return LucideIcons.layoutTemplate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = controller.selectedElementContext.value.isNotEmpty
        ? controller.selectedElementContext.value
        : (compName.capitalizeFirst ?? 'Section');
    final icon = _iconForComp(compName);
    final canReorderOrDelete = !isNav && !isFooter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _EditTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _EditTheme.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: AppColors.isDark(context) ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: AppColors.isDark(context)
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Section ID: $sectionId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: AppColors.isDark(context) ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  compName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.isDark(context)
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          if (canReorderOrDelete) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: _EditTheme.divider(context)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SectionHeaderActionButton(
                  icon: LucideIcons.chevronUp,
                  label: 'Up',
                  onTap: () => controller.moveSection(sectionId, 'up'),
                ),
                _SectionHeaderActionButton(
                  icon: LucideIcons.chevronDown,
                  label: 'Down',
                  onTap: () => controller.moveSection(sectionId, 'down'),
                ),
                _SectionHeaderActionButton(
                  icon: LucideIcons.copy,
                  label: 'Duplicate',
                  onTap: () => controller.duplicateSection(sectionId),
                ),
                _SectionHeaderActionButton(
                  icon: LucideIcons.trash2,
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () => _confirmDeleteSection(
                    context,
                    controller,
                    sectionId,
                    compName,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SectionHeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xFFEF4444);
    final isDark = AppColors.isDark(context);

    final bg = isDestructive
        ? dangerColor.withValues(alpha: isDark ? 0.18 : 0.1)
        : _EditTheme.chipBg(context);
    final border = isDestructive
        ? dangerColor.withValues(alpha: isDark ? 0.35 : 0.25)
        : _EditTheme.chipBorder(context);
    final fg = isDestructive ? dangerColor : AppColors.inkOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitleAndSubtitleEditor extends StatelessWidget {
  final EditorController controller;
  final String titleLabel;
  final String subtitleLabel;
  final String titleHint;
  final String subtitleHint;
  final bool hasSubtitle;

  const _SectionTitleAndSubtitleEditor({
    required this.controller,
    this.titleLabel = 'Section Title',
    this.subtitleLabel = 'Section Subtitle',
    this.titleHint = 'Enter section heading...',
    this.subtitleHint = 'Enter section description...',
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleLabel,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.textController,
          maxLines: null,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.inkOf(context),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: titleHint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.inkMutedOf(context),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            filled: true,
            fillColor: _EditTheme.fieldBg(context),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (val) {
            controller.selectedElementKey.value = 'headline';
            controller.updateText(val);
          },
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            subtitleLabel,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.subheadlineController,
            maxLines: null,
            style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
            decoration: InputDecoration(
              isDense: true,
              hintText: subtitleHint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.inkMutedOf(context),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) {
              controller.selectedElementKey.value = 'subheadline';
              controller.updateText(val);
            },
          ),
        ],
      ],
    );
  }
}

class _SectionHeadlineField extends StatelessWidget {
  final EditorController controller;
  final String label;

  const _SectionHeadlineField({
    required this.controller,
    this.label = 'Heading / Title',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.textController,
          maxLines: null,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.inkOf(context),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            filled: true,
            fillColor: _EditTheme.fieldBg(context),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (val) {
            controller.selectedElementKey.value = 'headline';
            controller.updateText(val);
          },
        ),
      ],
    );
  }
}

class _SectionHeadlineSizeSelector extends StatelessWidget {
  final EditorController controller;

  const _SectionHeadlineSizeSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'editor_size'.tr,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _EditTheme.capsuleBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _EditTheme.fieldBorder(context)),
          ),
          child: Row(
            children: [
              SizeOption(controller: controller, sizeLabel: 'Small'),
              SizeOption(controller: controller, sizeLabel: 'Medium'),
              SizeOption(controller: controller, sizeLabel: 'Large'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionSubheadlineField extends StatelessWidget {
  final EditorController controller;
  final String label;

  const _SectionSubheadlineField({
    required this.controller,
    this.label = 'Subtitle / Description',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.subheadlineController,
          maxLines: null,
          style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter section description or supporting copy...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.inkMutedOf(context),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: _EditTheme.fieldBg(context),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (val) {
            controller.selectedElementKey.value = 'subheadline';
            controller.updateText(val);
          },
        ),
      ],
    );
  }
}

class _SectionImageCard extends StatelessWidget {
  final EditorController controller;

  const _SectionImageCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.selectedImageProps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'editor_section_image'.tr,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _EditTheme.cardBg(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _EditTheme.cardBorder(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ImagePreview(
                      url: controller.selectedImageUrl,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedImageFilename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        Text(
                          'editor_tap_edit_upload'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.inkMutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.openReplaceImageView(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _EditTheme.chipBg(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _EditTheme.chipBorder(context),
                        ),
                      ),
                      child: Text(
                        'common_replace'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              QuickImageStrip(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdvancedPropsDisclosure extends StatelessWidget {
  final EditorController controller;

  const _AdvancedPropsDisclosure({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _EditTheme.cardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _EditTheme.cardBorder(context)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: Icon(
            LucideIcons.code2,
            size: 16,
            color: AppColors.inkMutedOf(context),
          ),
          title: Text(
            'editor_advanced_properties'.tr,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 12,
          ),
          children: [_UniversalWixPropsInspector(controller: controller)],
        ),
      ),
    );
  }
}

void _confirmDeleteSection(
  BuildContext context,
  EditorController controller,
  String sectionId,
  String compName,
) {
  final label = compName.capitalizeFirst ?? 'Section';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.isDark(context)
          ? const Color(0xFF1E293B)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'editor_delete_section_title'.trParams({'name': label}),
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.inkOf(context),
        ),
      ),
      content: Text(
        'editor_delete_section_confirm'.tr,
        style: TextStyle(fontSize: 13.5, color: AppColors.inkMutedOf(context)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'common_cancel'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            controller.deleteSection(sectionId);
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'common_delete'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

class ImageEditTab extends StatelessWidget {
  final EditorController controller;

  const ImageEditTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Item Card (Thumbnail, Image label, filename, Replace button)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ImagePreview(
                      url: controller.selectedImageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'editor_image'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.selectedImageFilename,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.inkMutedOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: _EditTheme.capsuleBg(context),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => controller.openReplaceImageView(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.scan,
                              size: 14,
                              color: AppColors.inkOf(context),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'replace'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Image Switcher: Choose from uploads + View all
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'choose_from_uploads'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMutedOf(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.openReplaceImageView(),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'editor_view_all'.tr,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            QuickImageStrip(controller: controller),

            const SizedBox(height: 18),

            // Image fit row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'image_fit'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkOf(context),
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _EditTheme.capsuleBg(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FitOption(
                        controller: controller,
                        fitType: 'fit',
                        label: 'fit_contain'.tr,
                        icon: LucideIcons.scan,
                      ),
                      FitOption(
                        controller: controller,
                        fitType: 'crop',
                        label: 'fit_crop'.tr,
                        icon: LucideIcons.crop,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Alt text label
            Text(
              'alt_text'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.inkOf(context),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.altTextController,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkOf(context),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                filled: true,
                fillColor: _EditTheme.fieldBg(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _EditTheme.fieldBorder(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => controller.updateImageAltText(val),
            ),

            const SizedBox(height: 10),

            // AI Alt Text and Screen reader caption (with Flexible to never overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: controller.isGeneratingAltText.value
                        ? null
                        : () => controller.generateAiAltText(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.isGeneratingAltText.value) ...[
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ] else ...[
                          const Icon(
                            LucideIcons.sparkles,
                            size: 15,
                            color: Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            'help_write_alt'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'for_screen_readers'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Delete image section button
            Center(
              child: TextButton.icon(
                onPressed: () => controller.deleteCurrentImageSection(),
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: Color(0xFFDC2626),
                ),
                label: Text(
                  'delete_image_from_page'.tr,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}

class QuickImageStrip extends StatelessWidget {
  final EditorController controller;

  const QuickImageStrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.uploadedImages;
      final currentUrl = controller.selectedImageUrl;

      return SizedBox(
        height: 62,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            // First item: "+ Upload" button
            if (index == 0) {
              return GestureDetector(
                onTap: () =>
                    controller.uploadImageFromDevice(applyImmediately: true),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _EditTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _EditTheme.chipBorder(context),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.uploadCloud,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'common_upload'.tr,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final img = images[index - 1];
            final isCurrent =
                img.url == currentUrl ||
                img.filename == controller.selectedImageFilename;

            return GestureDetector(
              onTap: () {
                controller.selectUploadImage(img.id);
                controller.applyImageToCurrentSection(img);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF2563EB)
                        : _EditTheme.fieldBorder(context),
                    width: isCurrent ? 2.5 : 1.0,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ImagePreview(url: img.url, fit: BoxFit.cover),
                    ),
                    if (isCurrent)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class FitOption extends StatelessWidget {
  final EditorController controller;
  final String fitType;
  final String label;
  final IconData icon;

  const FitOption({
    super.key,
    required this.controller,
    required this.fitType,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedImageFit.value == fitType;
      return GestureDetector(
        onTap: () => controller.updateImageFit(fitType),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceOf(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.inkOf(context)
                    : AppColors.inkMutedOf(context),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.inkOf(context)
                      : AppColors.inkMutedOf(context),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class SizeOption extends StatelessWidget {
  final EditorController controller;
  final String sizeLabel;

  const SizeOption({
    super.key,
    required this.controller,
    required this.sizeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedElementSize.value == sizeLabel;

        return GestureDetector(
          onTap: () => controller.updateSize(sizeLabel),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.surfaceOf(context)
                  : Colors.transparent,
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

class _EyebrowBadgeField extends StatelessWidget {
  final EditorController controller;
  const _EyebrowBadgeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'editor_badge_eyebrow'.tr,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.badgeController,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkOf(context),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'e.g. ✦ FEATURED 2026',
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.inkMutedOf(context),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: _EditTheme.fieldBg(context),
            prefixIcon: Icon(
              LucideIcons.tag,
              size: 14,
              color: AppColors.inkMutedOf(context),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (val) => controller.updateBadge(val),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _CtaEditorCard extends StatelessWidget {
  final EditorController controller;
  const _CtaEditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _EditTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _EditTheme.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.mousePointerClick,
                  size: 15,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'editor_cta_group'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Button Label
          Text(
            'editor_btn_label'.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller.ctaTextController,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.inkOf(context),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. Get Started, Download App',
              hintStyle: TextStyle(
                fontSize: 12.5,
                color: AppColors.inkMutedOf(context),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => controller.updateCtaProperty('ctaText', val),
          ),

          const SizedBox(height: 10),

          // Action / Destination Link
          Text(
            'editor_btn_destination'.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller.ctaLinkController,
            style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
            decoration: InputDecoration(
              isDense: true,
              hintText: '#features, https://..., tel:, mailto:',
              hintStyle: TextStyle(
                fontSize: 12.5,
                color: AppColors.inkMutedOf(context),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              prefixIcon: Icon(
                LucideIcons.link,
                size: 14,
                color: AppColors.inkMutedOf(context),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => controller.updateCtaProperty('ctaLink', val),
          ),

          const SizedBox(height: 8),

          // Quick presets chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildPresetChip(context, '# Section', () {
                controller.ctaLinkController.text = '#features';
                controller.updateCtaProperty('ctaLink', '#features');
              }),
              _buildPresetChip(context, 'Web URL', () {
                controller.ctaLinkController.text = 'https://';
                controller.updateCtaProperty('ctaLink', 'https://');
              }),
              _buildPresetChip(context, 'Email', () {
                controller.ctaLinkController.text = 'mailto:hello@example.com';
                controller.updateCtaProperty(
                  'ctaLink',
                  'mailto:hello@example.com',
                );
              }),
              _buildPresetChip(context, 'Phone', () {
                controller.ctaLinkController.text = 'tel:+15551234567';
                controller.updateCtaProperty('ctaLink', 'tel:+15551234567');
              }),
            ],
          ),

          // Secondary CTA (if Hero or configured)
          if (controller.selectedSectionType.value == 'hero' ||
              controller.secondaryCtaTextController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: _EditTheme.divider(context), height: 1),
            const SizedBox(height: 10),
            Text(
              'editor_secondary_btn'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.inkOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.secondaryCtaTextController,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Secondary Label',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) =>
                        controller.updateCtaProperty('secondaryCtaText', val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.secondaryCtaLinkController,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Secondary Link',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) =>
                        controller.updateCtaProperty('secondaryCtaLink', val),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: _EditTheme.chipBg(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _EditTheme.chipBorder(context)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.inkOf(context),
          ),
        ),
      ),
    );
  }
}

class _TestimonialsEditorList extends StatelessWidget {
  final EditorController controller;
  const _TestimonialsEditorList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.testimonialItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'editor_testimonials'.tr} (${items.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              GestureDetector(
                onTap: controller.addTestimonial,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'common_add'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final quote = item['quote'] ?? item['content'] ?? '';
            final author = item['author'] ?? item['name'] ?? '';
            final role = item['role'] ?? '';
            final rating = (item['rating'] as num?)?.toInt() ?? 5;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _EditTheme.cardBg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _EditTheme.cardBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'editor_testimonial_num'.trParams({'num': '${idx + 1}'}),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.deleteTestimonial(idx),
                        child: const Icon(
                          LucideIcons.trash2,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating stars
                  Row(
                    children: List.generate(5, (starIdx) {
                      final isFilled = starIdx < rating;
                      return GestureDetector(
                        onTap: () {
                          final updated = Map<String, dynamic>.from(item);
                          updated['rating'] = starIdx + 1;
                          controller.updateTestimonial(idx, updated);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            LucideIcons.star,
                            size: 16,
                            color: isFilled
                                ? const Color(0xFFF59E0B)
                                : _EditTheme.chipBorder(context),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),

                  // Quote
                  TextField(
                    controller: TextEditingController(text: quote)
                      ..selection = TextSelection.collapsed(
                        offset: quote.length,
                      ),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Customer testimonial quote...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final updated = Map<String, dynamic>.from(item);
                      updated['quote'] = val;
                      controller.updateTestimonial(idx, updated);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Author & Role
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: author)
                            ..selection = TextSelection.collapsed(
                              offset: author.length,
                            ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Author Name',
                            hintStyle: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['author'] = val;
                            controller.updateTestimonial(idx, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: role)
                            ..selection = TextSelection.collapsed(
                              offset: role.length,
                            ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMutedOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Role / Company',
                            hintStyle: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['role'] = val;
                            controller.updateTestimonial(idx, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

// ==========================================
// 1. Wix Section Style & Layout Toolbar
// ==========================================
class _WixSectionStyleToolbar extends StatelessWidget {
  final EditorController controller;
  const _WixSectionStyleToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bg = controller.selectedSectionBackground.value;
      final align = controller.selectedSectionAlign.value;
      final pad = controller.selectedSectionPadding.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _EditTheme.cardBg(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _EditTheme.cardBorder(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.paintBucket,
                  size: 14,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  'editor_section_styling'.tr,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Background Presets
            Text(
              'editor_bg_theme'.tr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMutedOf(context),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildStyleChip(
                  context,
                  'Default',
                  bg == 'default',
                  () => controller.updateSectionStyle('background', 'default'),
                ),
                const SizedBox(width: 6),
                _buildStyleChip(
                  context,
                  'Surface',
                  bg == 'surface',
                  () => controller.updateSectionStyle('background', 'surface'),
                ),
                const SizedBox(width: 6),
                _buildStyleChip(
                  context,
                  'Dark',
                  bg == 'dark',
                  () => controller.updateSectionStyle('background', 'dark'),
                ),
                const SizedBox(width: 6),
                _buildStyleChip(
                  context,
                  'Brand',
                  bg == 'brand',
                  () => controller.updateSectionStyle('background', 'brand'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Text Alignment & Padding Row
            Row(
              children: [
                // Alignment
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'editor_text_align'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _buildIconChip(
                            context,
                            LucideIcons.alignLeft,
                            align == 'left',
                            () => controller.updateSectionStyle(
                              'textAlign',
                              'left',
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildIconChip(
                            context,
                            LucideIcons.alignCenter,
                            align == 'center',
                            () => controller.updateSectionStyle(
                              'textAlign',
                              'center',
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildIconChip(
                            context,
                            LucideIcons.alignRight,
                            align == 'right',
                            () => controller.updateSectionStyle(
                              'textAlign',
                              'right',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Padding
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'editor_padding'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _buildStyleChip(
                            context,
                            'S',
                            pad == 'compact',
                            () => controller.updateSectionStyle(
                              'padding',
                              'compact',
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStyleChip(
                            context,
                            'M',
                            pad == 'normal',
                            () => controller.updateSectionStyle(
                              'padding',
                              'normal',
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStyleChip(
                            context,
                            'L',
                            pad == 'spacious',
                            () => controller.updateSectionStyle(
                              'padding',
                              'spacious',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStyleChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : _EditTheme.fieldBg(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : _EditTheme.chipBorder(context),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.inkOf(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconChip(
    BuildContext context,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : _EditTheme.fieldBg(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : _EditTheme.chipBorder(context),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 15,
            color: isSelected ? Colors.white : AppColors.inkOf(context),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. Navigation Layer Editor
// ==========================================
class _NavigationEditorCard extends StatelessWidget {
  final EditorController controller;
  const _NavigationEditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.navItems;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _EditTheme.cardBg(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _EditTheme.cardBorder(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.compass,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(
                  'editor_nav_brand_links'.tr,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Brand Text
            Text(
              'editor_brand_logo_name'.tr,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMutedOf(context),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: controller.navLogoTextController,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.inkOf(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'e.g. Lumen Coffee',
                hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                filled: true,
                fillColor: _EditTheme.fieldBg(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _EditTheme.fieldBorder(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => controller.updateNavLogo(text: val),
            ),

            const SizedBox(height: 12),

            // Custom Brand Logo Image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custom Brand Logo Image',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
                GestureDetector(
                  onTap: controller.pickAndSetLogo,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.imagePlus, size: 13, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        'Upload Image',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            TextField(
              controller: controller.navLogoSrcController,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkOf(context),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'https://... or uploaded image URL',
                hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                filled: true,
                fillColor: _EditTheme.fieldBg(context),
                prefixIcon: const Icon(LucideIcons.image, size: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _EditTheme.fieldBorder(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => controller.updateNavLogo(src: val),
            ),

            const SizedBox(height: 12),

            // Custom Favicon (Browser Icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Favicon (Browser Tab Icon)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
                GestureDetector(
                  onTap: controller.pickAndSetFavicon,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.globe, size: 13, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        'Upload Favicon',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            TextField(
              controller: controller.faviconController,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkOf(context),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'https://.../favicon.png',
                hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                filled: true,
                fillColor: _EditTheme.fieldBg(context),
                prefixIcon: const Icon(LucideIcons.globe, size: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _EditTheme.fieldBorder(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF10B981),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => controller.updateFavicon(val),
            ),

            const SizedBox(height: 12),

            // Navigation Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'editor_menu_links'.tr} (${items.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
                GestureDetector(
                  onTap: controller.addNavItem,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.plus,
                          size: 12,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'editor_add_link'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final label = item['label'] ?? '';
              final href = item['href'] ?? item['url'] ?? '';
              final isButton = item['type'] == 'button';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _EditTheme.fieldBg(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _EditTheme.fieldBorder(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: TextEditingController(text: label)
                          ..selection = TextSelection.collapsed(
                            offset: label.length,
                          ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkOf(context),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Label',
                          hintStyle: TextStyle(
                            color: AppColors.inkMutedOf(context),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          final updated = Map<String, dynamic>.from(item);
                          updated['label'] = val;
                          controller.updateNavItem(idx, updated);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: TextEditingController(text: href)
                          ..selection = TextSelection.collapsed(
                            offset: href.length,
                          ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMutedOf(context),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '#link or url',
                          hintStyle: TextStyle(
                            color: AppColors.inkMutedOf(context),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          final updated = Map<String, dynamic>.from(item);
                          updated['href'] = val;
                          controller.updateNavItem(idx, updated);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final updated = Map<String, dynamic>.from(item);
                        updated['type'] = isButton ? 'link' : 'button';
                        controller.updateNavItem(idx, updated);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isButton
                              ? const Color(0xFF2563EB)
                              : _EditTheme.capsuleBg(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'editor_btn_tag'.tr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isButton
                                ? Colors.white
                                : AppColors.inkMutedOf(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => controller.deleteNavItem(idx),
                      child: const Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ==========================================
// 3. Footer Layer Editor
// ==========================================
class _FooterEditorCard extends StatelessWidget {
  final EditorController controller;
  const _FooterEditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final links = controller.footerLinks;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _EditTheme.cardBg(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _EditTheme.cardBorder(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.panelBottom,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(
                  'editor_footer_copyright_links'.tr,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Copyright notice
            Text(
              'editor_copyright_notice'.tr,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMutedOf(context),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: controller.footerCopyrightController,
              style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
              decoration: InputDecoration(
                isDense: true,
                hintText: '© 2026 Brand. All rights reserved.',
                hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                filled: true,
                fillColor: _EditTheme.fieldBg(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _EditTheme.fieldBorder(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => controller.updateFooterCopyright(val),
            ),

            const SizedBox(height: 12),

            // Footer Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'editor_footer_links'.tr} (${links.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOf(context),
                  ),
                ),
                GestureDetector(
                  onTap: controller.addFooterLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.plus,
                          size: 12,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'editor_add_link'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...links.asMap().entries.map((entry) {
              final idx = entry.key;
              final link = entry.value;
              final label = link['label'] ?? '';
              final href = link['href'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _EditTheme.fieldBg(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _EditTheme.fieldBorder(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: TextEditingController(text: label)
                          ..selection = TextSelection.collapsed(
                            offset: label.length,
                          ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkOf(context),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Label',
                          hintStyle: TextStyle(
                            color: AppColors.inkMutedOf(context),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          final updated = Map<String, dynamic>.from(link);
                          updated['label'] = val;
                          controller.updateFooterLink(idx, updated);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: TextEditingController(text: href)
                          ..selection = TextSelection.collapsed(
                            offset: href.length,
                          ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMutedOf(context),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '#link or url',
                          hintStyle: TextStyle(
                            color: AppColors.inkMutedOf(context),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          final updated = Map<String, dynamic>.from(link);
                          updated['href'] = val;
                          controller.updateFooterLink(idx, updated);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.deleteFooterLink(idx),
                      child: const Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ==========================================
// 4. Products & Pricing Tiers Editor
// ==========================================
class _ProductsEditorList extends StatelessWidget {
  final EditorController controller;
  const _ProductsEditorList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.productItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'editor_pricing_plans'.tr} (${items.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              GestureDetector(
                onTap: controller.addProduct,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'editor_add_item'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final name = item['name'] ?? item['title'] ?? '';
            final price = item['price'] ?? '';
            final desc = item['description'] ?? '';
            final btnText = item['buttonText'] ?? 'Get Started';
            final btnLink = item['buttonLink'] ?? '#';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _EditTheme.cardBg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _EditTheme.cardBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'editor_item_num'.trParams({'num': '${idx + 1}'}),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.deleteProduct(idx),
                        child: const Icon(
                          LucideIcons.trash2,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: TextEditingController(text: name)
                            ..selection = TextSelection.collapsed(
                              offset: name.length,
                            ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Product or Plan Name',
                            hintStyle: TextStyle(
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['name'] = val;
                            controller.updateProduct(idx, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: TextEditingController(text: price)
                            ..selection = TextSelection.collapsed(
                              offset: price.length,
                            ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '\$29.00',
                            hintStyle: TextStyle(
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['price'] = val;
                            controller.updateProduct(idx, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: TextEditingController(
                      text: desc,
                    )..selection = TextSelection.collapsed(offset: desc.length),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkMutedOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Short description or tier highlights...',
                      hintStyle: TextStyle(
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final updated = Map<String, dynamic>.from(item);
                      updated['description'] = val;
                      controller.updateProduct(idx, updated);
                    },
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: btnText)
                            ..selection = TextSelection.collapsed(
                              offset: btnText.length,
                            ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Button Text',
                            hintStyle: TextStyle(
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['buttonText'] = val;
                            controller.updateProduct(idx, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: btnLink)
                            ..selection = TextSelection.collapsed(
                              offset: btnLink.length,
                            ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMutedOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Action Link',
                            hintStyle: TextStyle(
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['buttonLink'] = val;
                            controller.updateProduct(idx, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

// ==========================================
// 5. FAQ Editor
// ==========================================
class _FaqEditorList extends StatelessWidget {
  final EditorController controller;
  const _FaqEditorList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.faqItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'editor_qa'.tr} (${items.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              GestureDetector(
                onTap: controller.addFaq,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'editor_add_question'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final q = item['question'] ?? '';
            final a = item['answer'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _EditTheme.cardBg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _EditTheme.cardBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'editor_faq_num'.trParams({'num': '${idx + 1}'}),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.deleteFaq(idx),
                        child: const Icon(
                          LucideIcons.trash2,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: TextEditingController(text: q)
                      ..selection = TextSelection.collapsed(offset: q.length),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Enter question...',
                      hintStyle: TextStyle(
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final updated = Map<String, dynamic>.from(item);
                      updated['question'] = val;
                      controller.updateFaq(idx, updated);
                    },
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: TextEditingController(text: a)
                      ..selection = TextSelection.collapsed(offset: a.length),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkMutedOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Enter helpful answer...',
                      hintStyle: TextStyle(
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final updated = Map<String, dynamic>.from(item);
                      updated['answer'] = val;
                      controller.updateFaq(idx, updated);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

// ==========================================
// 6. Contact & Visit Details Editor
// ==========================================
class _ContactEditorCard extends StatelessWidget {
  final EditorController controller;
  const _ContactEditorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _EditTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _EditTheme.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.mail, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                'editor_contact_info'.tr,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Email
          Text(
            'editor_contact_email'.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller.contactEmailController,
            style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'hello@company.com',
              hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              prefixIcon: Icon(
                LucideIcons.atSign,
                size: 14,
                color: AppColors.inkMutedOf(context),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => controller.updateContactDetail('email', val),
          ),
          const SizedBox(height: 10),

          // Phone
          Text(
            'editor_contact_phone'.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller.contactPhoneController,
            style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
            decoration: InputDecoration(
              isDense: true,
              hintText: '+1 (555) 123-4567',
              hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              prefixIcon: Icon(
                LucideIcons.phone,
                size: 14,
                color: AppColors.inkMutedOf(context),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => controller.updateContactDetail('phone', val),
          ),
          const SizedBox(height: 10),

          // Address
          Text(
            'editor_contact_address'.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller.contactAddressController,
            style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
            decoration: InputDecoration(
              isDense: true,
              hintText: '123 Market Street, San Francisco, CA',
              hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              prefixIcon: Icon(
                LucideIcons.mapPin,
                size: 14,
                color: AppColors.inkMutedOf(context),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => controller.updateContactDetail('address', val),
          ),
          const SizedBox(height: 10),

          // Hours
          Text(
            'editor_contact_hours'.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller.contactHoursController,
            style: TextStyle(fontSize: 13, color: AppColors.inkOf(context)),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Mon - Fri: 8:00 AM - 6:00 PM',
              hintStyle: TextStyle(color: AppColors.inkMutedOf(context)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              filled: true,
              fillColor: _EditTheme.fieldBg(context),
              prefixIcon: Icon(
                LucideIcons.clock,
                size: 14,
                color: AppColors.inkMutedOf(context),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _EditTheme.fieldBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => controller.updateContactDetail('hours', val),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. Gallery Photos Editor
// ==========================================
class _GalleryEditorList extends StatelessWidget {
  final EditorController controller;
  const _GalleryEditorList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.galleryImages;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'editor_gallery_photos'.tr} (${items.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              GestureDetector(
                onTap: controller.addGalleryImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'editor_add_photo'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final img = entry.value;
            final url = img['url'] ?? img['src'] ?? '';
            final caption = img['caption'] ?? img['alt'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _EditTheme.cardBg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _EditTheme.cardBorder(context)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 44,
                        color: _EditTheme.capsuleBg(context),
                        child: Icon(
                          LucideIcons.image,
                          size: 20,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: TextEditingController(text: url)
                            ..selection = TextSelection.collapsed(
                              offset: url.length,
                            ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Image URL',
                            hintStyle: TextStyle(
                              color: AppColors.inkMutedOf(context),
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(img);
                            updated['url'] = val;
                            controller.updateGalleryImage(idx, updated);
                          },
                        ),
                        TextField(
                          controller: TextEditingController(text: caption)
                            ..selection = TextSelection.collapsed(
                              offset: caption.length,
                            ),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.inkMutedOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Caption or Alt text',
                            hintStyle: TextStyle(
                              color: AppColors.inkMutedOf(context),
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(img);
                            updated['caption'] = val;
                            controller.updateGalleryImage(idx, updated);
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.deleteGalleryImage(idx),
                    child: const Icon(
                      LucideIcons.trash2,
                      size: 15,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

// ==========================================
// 8. Wix Universal Property Inspector (Modify ANY prop)
// ==========================================
class _UniversalWixPropsInspector extends StatefulWidget {
  final EditorController controller;
  const _UniversalWixPropsInspector({required this.controller});

  @override
  State<_UniversalWixPropsInspector> createState() =>
      _UniversalWixPropsInspectorState();
}

class _UniversalWixPropsInspectorState
    extends State<_UniversalWixPropsInspector> {
  bool _isExpanded = false;
  final TextEditingController _newKeyCtrl = TextEditingController();
  final TextEditingController _newValCtrl = TextEditingController();
  bool _showAddForm = false;

  @override
  void dispose() {
    _newKeyCtrl.dispose();
    _newValCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final props = widget.controller.customProps;
      final keys = props.keys
          .where(
            (k) =>
                k != 'items' && k != 'images' && k != 'metrics' && k != 'links',
          )
          .toList();

      return Container(
        decoration: BoxDecoration(
          color: _EditTheme.cardBg(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _EditTheme.cardBorder(context)),
        ),
        child: Column(
          children: [
            // Header tile
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 2,
              ),
              leading: const Icon(
                LucideIcons.slidersHorizontal,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              title: Row(
                children: [
                  Text(
                    'editor_property_inspector'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'editor_all_props'.tr,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 16,
                color: AppColors.inkMutedOf(context),
              ),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),

            if (_isExpanded) ...[
              Divider(color: _EditTheme.divider(context), height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'editor_fine_tune_props'.tr,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...keys.map((key) {
                      final val = props[key]?.toString() ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _EditTheme.fieldBg(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _EditTheme.fieldBorder(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkOf(context),
                                ),
                              ),
                            ),
                            Text(
                              ':',
                              style: TextStyle(
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: val)
                                  ..selection = TextSelection.collapsed(
                                    offset: val.length,
                                  ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkOf(context),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: AppColors.inkMutedOf(context),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (newVal) => widget.controller
                                    .updateCustomProperty(key, newVal),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  widget.controller.deleteCustomProperty(key),
                              child: Icon(
                                LucideIcons.x,
                                size: 14,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    if (_showAddForm) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _EditTheme.fieldBg(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2563EB)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextField(
                                    controller: _newKeyCtrl,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.inkOf(context),
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText:
                                          'Property Key (e.g. badgeColor)',
                                      hintStyle: TextStyle(
                                        color: AppColors.inkMutedOf(context),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: _newValCtrl,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkOf(context),
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Value',
                                      hintStyle: TextStyle(
                                        color: AppColors.inkMutedOf(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _showAddForm = false),
                                  child: Text(
                                    'common_cancel'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMutedOf(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_newKeyCtrl.text.trim().isNotEmpty) {
                                      widget.controller.addCustomProperty(
                                        _newKeyCtrl.text.trim(),
                                        _newValCtrl.text.trim(),
                                      );
                                      _newKeyCtrl.clear();
                                      _newValCtrl.clear();
                                      setState(() => _showAddForm = false);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    'editor_add_property'.tr,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => setState(() => _showAddForm = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _EditTheme.fieldBg(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _EditTheme.chipBorder(context),
                              style: BorderStyle.solid,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.plus,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'editor_add_custom_field'.tr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _StatisticsEditorList extends StatelessWidget {
  final EditorController controller;
  const _StatisticsEditorList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.statItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'editor_stats_metrics'.tr} (${items.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              GestureDetector(
                onTap: controller.addStat,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'common_add'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final value = item['value'] ?? '';
            final label = item['label'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _EditTheme.cardBg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _EditTheme.cardBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'editor_stat_num'.trParams({'num': '${idx + 1}'}),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.deleteStat(idx),
                        child: const Icon(
                          LucideIcons.trash2,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Value (e.g. 99.9%, 10M+)
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: TextEditingController(text: value)
                            ..selection = TextSelection.collapsed(
                              offset: value.length,
                            ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '99.9%',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['value'] = val;
                            controller.updateStat(idx, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Label (e.g. Customer Satisfaction)
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: TextEditingController(text: label)
                            ..selection = TextSelection.collapsed(
                              offset: label.length,
                            ),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkOf(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Label (e.g. Active Users)',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMutedOf(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: _EditTheme.fieldBg(context),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _EditTheme.fieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['label'] = val;
                            controller.updateStat(idx, updated);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

class _FeaturesEditorList extends StatelessWidget {
  final EditorController controller;
  const _FeaturesEditorList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.featureItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'editor_features_icons'.tr} (${items.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              GestureDetector(
                onTap: controller.addFeature,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'common_add'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final iconName = item['icon']?.toString() ?? 'Sparkles';
            final title = item['title'] ?? '';
            final description = item['description'] ?? '';
            final iconData = EditorIconHelper.getIcon(iconName);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _EditTheme.cardBg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _EditTheme.cardBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon Box with tap to open IconPickerSheet
                      GestureDetector(
                        onTap: () async {
                          final selected = await IconPickerSheet.show(
                            context,
                            currentIcon: iconName,
                          );
                          if (selected != null) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['icon'] = selected;
                            controller.updateFeature(idx, updated);
                          }
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            iconData,
                            size: 20,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Change Icon Pill
                      GestureDetector(
                        onTap: () async {
                          final selected = await IconPickerSheet.show(
                            context,
                            currentIcon: iconName,
                          );
                          if (selected != null) {
                            final updated = Map<String, dynamic>.from(item);
                            updated['icon'] = selected;
                            controller.updateFeature(idx, updated);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _EditTheme.chipBg(context),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _EditTheme.chipBorder(context),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                iconName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkOf(context),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevronDown,
                                size: 12,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Delete
                      GestureDetector(
                        onTap: () => controller.deleteFeature(idx),
                        child: const Icon(
                          LucideIcons.trash2,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Feature Title
                  TextField(
                    controller: TextEditingController(text: title)
                      ..selection = TextSelection.collapsed(
                        offset: title.length,
                      ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Feature Title',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final updated = Map<String, dynamic>.from(item);
                      updated['title'] = val;
                      controller.updateFeature(idx, updated);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Feature Description
                  TextField(
                    controller: TextEditingController(text: description)
                      ..selection = TextSelection.collapsed(
                        offset: description.length,
                      ),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkMutedOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Feature description and benefits...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: _EditTheme.fieldBg(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _EditTheme.fieldBorder(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final updated = Map<String, dynamic>.from(item);
                      updated['description'] = val;
                      controller.updateFeature(idx, updated);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}
