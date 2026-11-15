import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/services/media_asset_service.dart';
import '../assets_controller.dart';

class StorageQuotaCard extends StatelessWidget {
  final AssetsController controller;

  const StorageQuotaCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final mediaService = controller.mediaService;

    return Obx(() {
      final assetsCount = mediaService.uploadedImages.length;
      final maxAssets = MediaAssetService.maxImageUploadLimit;
      final sitesCount = controller.sites.length;
      final storagePercent = mediaService.storagePercentage;
      final storageText = mediaService.formattedStorageUsed;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderSubtleOf(context),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Stats pills + Upload Action Button
            Row(
              children: [
                // Sites stat pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMutedOf(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF38BDF8,
                            ).withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            LucideIcons.globe,
                            size: 16,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$sitesCount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.inkOf(context),
                              ),
                            ),
                            Text(
                              'assets_stat_sites'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Uploaded Assets stat pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMutedOf(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.atmosphereViolet.withValues(
                              alpha: 0.15,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.image,
                            size: 16,
                            color: AppColors.atmosphereViolet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$assetsCount / $maxAssets',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.inkOf(context),
                              ),
                            ),
                            Text(
                              'assets_stat_assets'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Storage quota progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.hardDrive,
                      size: 14,
                      color: AppColors.inkMutedOf(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'assets_stat_storage_used'.tr,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$storageText ${'assets_of'.tr} ${MediaAssetService.maxStorageMb} MB',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: storagePercent,
                minHeight: 6,
                backgroundColor: AppColors.surfaceMutedOf(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  storagePercent > 0.85
                      ? const Color(0xFFEF4444)
                      : AppColors.atmosphereViolet,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Upload button
            GestureDetector(
              onTap: controller.uploadAsset,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0F172A))
                              .withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.uploadCloud,
                      size: 17,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'assets_upload_from_device'.tr,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
