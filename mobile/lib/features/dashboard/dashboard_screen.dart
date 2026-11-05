import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/designsystem/gradients.dart';
import '../../core/designsystem/typography.dart';
import 'components/continue_editing_hero_card.dart';
import 'components/floating_bottom_bar.dart';
import 'components/new_website_bottom_sheet.dart';
import 'components/recent_project_card.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showProfileDialog(BuildContext context, DashboardController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Obx(
                () => Text(
                  controller.userInitials.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value ?? 'Creator Account',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                const Text(
                  'user@aibuilder.local',
                  style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                ),
              ],
            ),
          ],
        ),
        content: const Text(
          'Manage your active projects or sign out to switch accounts.',
          style: TextStyle(fontSize: 14, color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
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
              padding: const EdgeInsets.only(
                top: 56,
                left: 20,
                right: 20,
                bottom: 120,
              ),
              children: [
                // Header: "Projects" + Circular User Initials Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Projects',
                      style: AppTypography.largePageTitle,
                    ),

                    // Circular Avatar
                    GestureDetector(
                      onTap: () => _showProfileDialog(context, controller),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Obx(
                          () => Text(
                            controller.userInitials.value,
                            style: const TextStyle(
                              color: Colors.white,
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
                  return ContinueEditingHeroCard(
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
                  );
                }),

                const SizedBox(height: 28),

                // "Recent" Section Title
                const Text(
                  'Recent',
                  style: AppTypography.sectionHeading,
                ),

                const SizedBox(height: 14),

                // Horizontal Carousel of Website Previews
                SizedBox(
                  height: 345,
                  child: Obx(() {
                    final items = controller.previewItems;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
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

          // iOS Frosted Glass Floating Bottom Bar with Clipping Center Plus Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Obx(
              () => FloatingBottomBar(
                activeTab: controller.activeTab.value,
                onTabSelected: (tab) {
                  controller.onTabSelected(tab);
                  if (tab == 'Profile') {
                    _showProfileDialog(context, controller);
                  }
                },
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
}
