import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/user_site_info.dart';
import '../assets_controller.dart';

class SiteAssetCard extends StatelessWidget {
  final UserSiteInfo site;
  final AssetsController controller;
  final bool isFiltered;

  const SiteAssetCard({
    super.key,
    required this.site,
    required this.controller,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFiltered
              ? AppColors.atmosphereViolet
              : AppColors.borderSubtleOf(context),
          width: isFiltered ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview Image Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: site.imageUrl != null && site.imageUrl!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: site.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceMutedOf(context),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceMutedOf(context),
                            child: Icon(
                              LucideIcons.globe,
                              color: AppColors.inkMutedOf(context),
                              size: 28,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                  : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.layout,
                              color: AppColors.inkMutedOf(context),
                              size: 32,
                            ),
                          ),
                        ),
                ),
              ),

              // Status badge top-left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: site.isLive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        site.isLive ? 'LIVE' : 'DRAFT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Assets count badge top-right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.atmosphereViolet.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.image, size: 11, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${site.assetCount} ${'assets_items'.tr}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  site.domain ?? site.subdomain ?? site.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons: Open in Editor + Filter Assets
                Row(
                  children: [
                    // Open in Editor primary button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.openWebsite(site.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.penTool,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'assets_open_editor'.tr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filter Assets button
                    GestureDetector(
                      onTap: () {
                        if (isFiltered) {
                          controller.clearSiteFilter();
                        } else {
                          controller.filterBySite(site.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isFiltered
                              ? AppColors.atmosphereViolet
                              : AppColors.surfaceMutedOf(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isFiltered ? LucideIcons.filterX : LucideIcons.filter,
                          size: 14,
                          color: isFiltered
                              ? Colors.white
                              : AppColors.inkOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
