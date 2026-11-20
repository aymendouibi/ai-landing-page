import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/designsystem/colors.dart';
import '../../core/designsystem/gradients.dart';
import '../../core/widgets/user_avatar_circle.dart';
import '../dashboard/components/recent_project_card.dart';
import 'assets_controller.dart';
import 'components/assets_shimmer_view.dart';
import 'components/upload_project_card.dart';

class AssetsView extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const AssetsView({super.key, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AssetsController>()
        ? Get.find<AssetsController>()
        : Get.put(AssetsController());
    final isDark = AppColors.isDark(context);

    return Stack(
      children: [
        // Soft iridescent gradient wash background (same as Profile)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.profileBackgroundGradient(isDark),
            ),
          ),
        ),

        // Foreground Content
        SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: controller.loadSites,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [
                // 1. Top Header: "Assets" Title + Circular "MR" Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'assets_title'.tr,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: AppColors.inkOf(context),
                      ),
                    ),

                    // Circular Avatar Pill
                    UserAvatarCircle(
                      size: 40,
                      isDark: isDark,
                      onTap: onAvatarTap,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Minimalist Search Bar ("Search pages and uploads")
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x33FFFFFF)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        LucideIcons.search,
                        size: 19,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.setSearchQuery,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.inkOf(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'assets_search_hint'.tr,
                            hintStyle: TextStyle(
                              fontSize: 14.5,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return GestureDetector(
                            onTap: controller.clearSearch,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Filter Pills: [All]  Pages · 4  Uploads · 4
                Obx(() => _buildFilterPillsRow(context, controller)),

                const SizedBox(height: 24),

                // 4. Content Area: Pages & Uploads with Same Project Cards
                Obx(() {
                  if (controller.isLoading.value) {
                    return const AssetsShimmerView();
                  }

                  final filter = controller.selectedFilter.value;
                  final pages = controller.filteredPages;
                  final uploads = controller.filteredUploads;

                  if (pages.isEmpty && uploads.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 48,
                        horizontal: 20,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 42,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'assets_no_results'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkOf(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${'assets_no_match_query'.tr} "${controller.searchQuery.value}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkMutedOf(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: controller.clearSearch,
                            child: Text('assets_clear_search'.tr),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filter == 'pages') {
                    return _buildPagesSection(
                      context,
                      controller,
                      isSingleTab: true,
                    );
                  } else if (filter == 'uploads') {
                    return _buildUploadsSection(
                      context,
                      controller,
                      isSingleTab: true,
                    );
                  } else {
                    // 'all' shows both Pages and Uploads
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPagesSection(
                          context,
                          controller,
                          isSingleTab: false,
                        ),
                        const SizedBox(height: 32),
                        _buildUploadsSection(
                          context,
                          controller,
                          isSingleTab: false,
                        ),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Filter Pills: [All]   Pages · 4   Uploads · 4
  Widget _buildFilterPillsRow(
    BuildContext context,
    AssetsController controller,
  ) {
    final current = controller.selectedFilter.value;
    final pagesCount = controller.pagesCount;
    final uploadsCount = controller.uploadsCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPillItem(
            context,
            label: 'assets_filter_all'.tr,
            isSelected: current == 'all',
            onTap: () => controller.setFilter('all'),
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            context,
            label: '${'assets_filter_pages'.tr} · $pagesCount',
            isSelected: current == 'pages',
            onTap: () => controller.setFilter('pages'),
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            context,
            label: '${'assets_filter_uploads'.tr} · $uploadsCount',
            isSelected: current == 'uploads',
            onTap: () => controller.setFilter('uploads'),
          ),
        ],
      ),
    );
  }

  Widget _buildPillItem(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF18181B))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  // Pages Section using the EXACT same card as projects view (RecentProjectCard)
  Widget _buildPagesSection(
    BuildContext context,
    AssetsController controller, {
    required bool isSingleTab,
  }) {
    final pages = controller.filteredPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'assets_filter_pages'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.inkOf(context),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${pages.length} ${'assets_pages_count'.tr}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMutedOf(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (pages.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtleOf(context)),
            ),
            child: Center(
              child: Text(
                'assets_no_pages_match'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.inkMutedOf(context),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 360,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: pages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = pages[index];
                return RecentProjectCard(
                  item: item,
                  onClick: () => controller.openWebsite(item.id),
                );
              },
            ),
          ),
      ],
    );
  }

  // Uploads Section using the same card styling as projects view
  Widget _buildUploadsSection(
    BuildContext context,
    AssetsController controller, {
    required bool isSingleTab,
  }) {
    final uploads = controller.filteredUploads;
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'assets_filter_uploads'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.inkOf(context),
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: controller.uploadAsset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.plus,
                      size: 13,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'assets_upload'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (uploads.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtleOf(context)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.image,
                    size: 32,
                    color: AppColors.inkMutedOf(context),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'assets_no_uploads_yet'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: controller.uploadAsset,
                    icon: const Icon(LucideIcons.upload, size: 14),
                    label: Text('assets_upload_from_device'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white
                          : const Color(0xFF18181B),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 360,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: uploads.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                // First card is "Upload New" tile
                if (index == 0) {
                  return UploadNewCard(onTap: controller.uploadAsset);
                }
                final asset = uploads[index - 1];
                return UploadProjectCard(asset: asset, controller: controller);
              },
            ),
          ),
      ],
    );
  }
}
