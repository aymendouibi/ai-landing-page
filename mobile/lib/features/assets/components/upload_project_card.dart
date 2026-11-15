import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/uploaded_image.dart';
import '../assets_controller.dart';
import 'asset_detail_dialog.dart';

class UploadProjectCard extends StatelessWidget {
  final UploadedImage asset;
  final AssetsController controller;

  const UploadProjectCard({
    super.key,
    required this.asset,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: () => AssetDetailDialog.show(context, asset, controller),
      child: SizedBox(
        width: 215,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Upload Card Container (Matching RecentProjectCard 215x270 size and radius)
            Container(
              width: 215,
              height: 270,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161E2E)
                    : const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0x26FFFFFF)
                      : const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar inside card: Extension Pill + File Size
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFF1E1E24),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            asset.fileExtension,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          asset.formattedSize,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Real Image filling bottom part of card
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          child: asset.url.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: asset.url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: const Color(0xFFF1F5F9)),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: const Color(0xFFE2E8F0),
                                        child: const Center(
                                          child: Icon(
                                            LucideIcons.image,
                                            size: 28,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                )
                              : Image.network(
                                  asset.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: const Color(0xFFE2E8F0),
                                        child: const Center(
                                          child: Icon(
                                            LucideIcons.image,
                                            size: 28,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                ),
                        ),

                        // Resolution pill (bottom-left overlay)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              asset.dimensions,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Asset Filename (Below Card, same typography as RecentProjectCard)
            Text(
              asset.filename,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.inkOf(context),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // 3. Subtitle / Site / Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    asset.siteName ?? 'Uploaded media',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.inkMutedOf(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => controller.copyAssetUrl(asset),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          LucideIcons.copy,
                          size: 14,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          LucideIcons.trash2,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('assets_delete_asset_title'.tr),
        content: Text(
          'assets_remove_confirm'.tr,
          style: TextStyle(color: AppColors.inkSecondaryOf(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'common_cancel'.tr,
              style: TextStyle(color: AppColors.inkMutedOf(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteAsset(asset.id, filename: asset.filename);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
  }
}

class UploadNewCard extends StatelessWidget {
  final VoidCallback onTap;

  const UploadNewCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 215,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 215,
              height: 270,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161E2E)
                    : const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0x33FFFFFF)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFF0F172A),
                        ),
                        child: Icon(
                          LucideIcons.plus,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'assets_upload_asset'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'assets_upload_specs'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'assets_add_new_media'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.inkOf(context),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'assets_tap_to_upload'.tr,
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
}
