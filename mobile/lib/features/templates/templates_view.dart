import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/widgets/ad_banner_widget.dart';
import 'components/template_real_preview_modal.dart';
import 'templates_controller.dart';
import 'widgets/template_card.dart';
import 'widgets/templates_category_tabs.dart';
import 'widgets/templates_empty_state.dart';
import 'widgets/templates_footer_quote.dart';
import 'widgets/templates_header.dart';
import 'widgets/templates_search_bar.dart';
import 'widgets/templates_section_header.dart';
import 'widgets/templates_shimmer_list.dart';

export 'widgets/template_card.dart';
export 'widgets/templates_category_tabs.dart';
export 'widgets/templates_empty_state.dart';
export 'widgets/templates_footer_quote.dart';
export 'widgets/templates_header.dart';
export 'widgets/templates_search_bar.dart';
export 'widgets/templates_section_header.dart';

class TemplatesView extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const TemplatesView({super.key, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TemplatesController>()
        ? Get.find<TemplatesController>()
        : Get.put(TemplatesController());
    final isDark = AppColors.isDark(context);

    return Stack(
      children: [
        // 1. Ambient Aura Gradient Backdrop (Top)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 380,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF090D16),
                        const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                        const Color(0xFF1E293B).withValues(alpha: 0.3),
                        const Color(0xFF090D16),
                      ]
                    : [
                        const Color(0xFFE0E7FF).withValues(alpha: 0.65),
                        const Color(0xFFFCE7F3).withValues(alpha: 0.55),
                        const Color(0xFFE0F2FE).withValues(alpha: 0.5),
                        const Color(0xFFF8FAFC),
                      ],
                stops: const [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // 2. Main Content Scroll Area
        SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: controller.loadTemplates,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              controller: controller.scrollController,
              slivers: [
                // Top Header: Title, User Avatar, Headline & Subtitle
                SliverToBoxAdapter(
                  child: TemplatesHeader(
                    onAvatarTap: onAvatarTap,
                    isDark: isDark,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Search Input Box
                SliverToBoxAdapter(
                  child: TemplatesSearchBar(
                    controller: controller,
                    isDark: isDark,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Horizontal Category Filter Pills
                SliverToBoxAdapter(
                  child: TemplatesCategoryTabs(
                    controller: controller,
                    isDark: isDark,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Ad Banner for Free Tier
                const SliverToBoxAdapter(child: AdBannerWidget()),

                const SliverToBoxAdapter(child: SizedBox(height: 6)),

                // Section Header: "The curated edit" + count
                SliverToBoxAdapter(
                  child: TemplatesSectionHeader(
                    controller: controller,
                    isDark: isDark,
                  ),
                ),

                // Spacing before Cards List
                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Template Cards List
                Obx(() {
                  if (controller.isLoading.value) {
                    return TemplatesShimmerList(isDark: isDark);
                  }

                  final list = controller.filteredTemplates;
                  if (list.isEmpty) {
                    return SliverToBoxAdapter(
                      child: TemplatesEmptyState(isDark: isDark),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final template = list[index];
                        final isLocked = controller.isTemplateLocked(template);
                        final showInFeedAd = (index > 0 && index % 3 == 0);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showInFeedAd)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 28),
                                child: AdBannerWidget(
                                  adTag: 'templates_infeed_$index',
                                  margin: EdgeInsets.zero,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 28),
                              child: TemplateCard(
                                template: template,
                                isLocked: isLocked,
                                onPreview: () => _showPreviewSheet(
                                  context,
                                  template,
                                  controller,
                                ),
                                onUse: () => controller.useTemplate(template),
                              ),
                            ),
                          ],
                        );
                      }, childCount: list.length),
                    ),
                  );
                }),

                // Footer Quote & Bottom Spacing for Floating Dock
                SliverToBoxAdapter(
                  child: TemplatesFooterQuote(isDark: isDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void _showPreviewSheet(
    BuildContext context,
    Map<String, dynamic> template,
    TemplatesController controller,
  ) {
    TemplateRealPreviewModal.show(
      context,
      template: template,
      controller: controller,
    );
  }
}
