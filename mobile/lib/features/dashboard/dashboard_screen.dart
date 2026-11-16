import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/designsystem/gradients.dart';
import '../../core/designsystem/typography.dart';
import '../../core/widgets/ad_banner_widget.dart';
import '../../core/widgets/app_showcase.dart';
import '../templates/templates_view.dart';
import '../assets/assets_view.dart';
import '../profile/profile_view.dart';
import 'components/continue_editing_hero_card.dart';
import 'components/floating_bottom_bar.dart';
import 'components/new_website_bottom_sheet.dart';
import 'components/recent_project_card.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

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
                  Row(
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
                      Text(
                        'projects_title'.tr,
                        style: AppTypography.largePageTitle.copyWith(
                          color: AppColors.inkOf(context),
                        ),
                      ),
                    ],
                  ),

                  // Circular Avatar
                  GestureDetector(
                    onTap: () => controller.onTabSelected('Profile'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.inkOf(context),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Obx(
                        () => Text(
                          controller.userInitials.value,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Obx(
                () => controller.isLoading.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: AppColors.atmosphereViolet,
                          minHeight: 2,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Continue Editing Hero Card
              Obx(() {
                final heroSite = controller.heroWebsite;
                return AppShowcase.item(
                  key: controller.showcaseHeroCardKey,
                  title: 'showcase_create_landing_page_title'.tr,
                  description: 'showcase_create_landing_page_desc'.tr,
                  child: ContinueEditingHeroCard(
                    website: heroSite,
                    onOpenClick: () {
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
                );
              }),

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

              // Horizontal Carousel of Website Previews
              SizedBox(
                height: 355,
                child: Obx(() {
                  final items = controller.previewItems;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return RecentProjectCard(
                        item: item,
                        onClick: () {
                          if (item.id.startsWith('showcase_')) {
                            final targetId = controller.heroWebsite?.id;
                            if (targetId != null) {
                              controller.openWebsite(targetId);
                            } else {
                              NewWebsiteBottomSheet.show(
                                context,
                                onDescribeToAi: controller.openAiCreation,
                                onStartFromTemplate: controller.openTemplates,
                                onBlankWebsite: controller.createBlankWebsite,
                              );
                            }
                          } else {
                            controller.openWebsite(item.id);
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
