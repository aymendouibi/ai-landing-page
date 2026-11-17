import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/designsystem/colors.dart';
import '../../core/designsystem/gradients.dart';
import '../../core/designsystem/typography.dart';
import '../../core/widgets/ad_banner_widget.dart';
import '../../core/widgets/app_showcase.dart';
import '../../core/widgets/user_avatar_circle.dart';
import '../templates/templates_view.dart';
import '../assets/assets_view.dart';
import '../profile/profile_view.dart';
import 'components/continue_editing_hero_card.dart';
import 'components/floating_bottom_bar.dart';
import 'components/new_website_bottom_sheet.dart';
import 'components/projects_shimmer_view.dart';
import 'components/recent_project_card.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController(), permanent: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppShowcase.checkAndStartDashboardShowcase(context, [
        controller.showcaseHeroCardKey,
        controller.showcaseAddButtonKey,
      ]);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: Stack(
        children: [
          // Content views switched via IndexedStack to preserve scroll state
          Positioned.fill(
            child: Obx(
              () => IndexedStack(
                index: controller.currentTabIndex,
                children: [
                  _buildProjectsView(context, controller),
                  TemplatesView(
                    onAvatarTap: () => controller.onTabSelected('Profile'),
                  ),
                  AssetsView(
                    onAvatarTap: () => controller.onTabSelected('Profile'),
                  ),
                  const ProfileView(),
                ],
              ),
            ),
          ),

          // Persistent iOS Frosted Glass Floating Bottom Bar with Clipping Center Plus Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Obx(
              () => FloatingBottomBar(
                activeTab: controller.activeTab.value,
                onTabSelected: (tab) {
                  controller.onTabSelected(tab);
                },
                addShowcaseKey: controller.showcaseAddButtonKey,
                onAddClick: () {
                  NewWebsiteBottomSheet.show(
                    context,
                    onDescribeToAi: controller.openAiCreation,
                    onStartFromTemplate: controller.openTemplates,
                    onBlankWebsite: controller.createBlankWebsite,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsView(
    BuildContext context,
    DashboardController controller,
  ) {
    return Stack(
      children: [
        // Ambient Backdrop Aura Gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 280,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backdropAura,
            ),
          ),
        ),

        // Main Scrollable Content
        RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              top: 56,
              left: 20,
              right: 20,
              bottom: 140,
            ),
            children: [
              // Header: "Projects" + Circular User Initials Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'projects_title'.tr,
                            style: AppTypography.largePageTitle.copyWith(
                              color: AppColors.inkOf(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular Avatar
                  UserAvatarCircle(
                    size: 40,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    onTap: () => controller.onTabSelected('Profile'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Content or Shimmer Loading State
              Obx(() {
                if (controller.isLoading.value && controller.websites.isEmpty) {
                  return const ProjectsShimmerView();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Continue Editing Hero Card
                    AppShowcase.item(
                      key: controller.showcaseHeroCardKey,
                      title: 'showcase_create_landing_page_title'.tr,
                      description: 'showcase_create_landing_page_desc'.tr,
                      child: ContinueEditingHeroCard(
                        website: controller.heroWebsite,
                        onOpenClick: () {
                          final heroSite = controller.heroWebsite;
                          if (heroSite != null) {
                            controller.openWebsite(heroSite.id);
                          } else {
                            NewWebsiteBottomSheet.show(
                              context,
                              onDescribeToAi: controller.openAiCreation,
                              onStartFromTemplate: controller.openTemplates,
                              onBlankWebsite: controller.createBlankWebsite,
                            );
                          }
                        },
                      ),
                    ),

                    const AdBannerWidget(),

                    const SizedBox(height: 18),

                    // "Recent" Section Title
                    Text(
                      'recent'.tr,
                      style: AppTypography.sectionHeading.copyWith(
                        color: AppColors.inkOf(context),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Horizontal Carousel of Website Previews or Clean Empty State
                    Builder(
                      builder: (context) {
                        final items = controller.previewItems;
                        if (items.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 36,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceOf(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.borderSubtleOf(context),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMutedOf(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.layoutTemplate,
                                    size: 22,
                                    color: AppColors.inkMutedOf(context),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No recent projects',
                                  style: AppTypography.itemTitleOf(context),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Websites you create or edit will appear here.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.helperOf(context),
                                ),
                              ],
                            ),
                          );
                        }

                        return SizedBox(
                          height: 355,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return RecentProjectCard(
                                item: item,
                                onClick: () => controller.openWebsite(item.id),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
