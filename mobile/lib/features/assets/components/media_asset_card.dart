import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/uploaded_image.dart';
import '../assets_controller.dart';
import 'asset_detail_dialog.dart';

class MediaAssetCard extends StatelessWidget {
  final UploadedImage asset;
  final AssetsController controller;

  const MediaAssetCard({
    super.key,
    required this.asset,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: () => AssetDetailDialog.show(context, asset, controller),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderSubtleOf(context),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Thumbnail
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    child: asset.url.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: asset.url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceMutedOf(context),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                LucideIcons.imageOff,
                                size: 24,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          )
                        : Image.network(
                            asset.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 24,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          ),
                  ),

                  // Format Extension Pill (Top-Left)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        asset.fileExtension,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                  // Associated Site Pill (Bottom-Left)
                  if (asset.siteName != null)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.atmosphereViolet.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          asset.siteName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${asset.dimensions} · ${asset.formattedSize}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.inkMutedOf(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Action icons: Copy & Delete
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => controller.copyAssetUrl(asset),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                LucideIcons.copy,
                                size: 13,
                                color: AppColors.inkMutedOf(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _confirmDelete(context),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                LucideIcons.trash2,
                                size: 13,
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
            child: Text('common_cancel'.tr, style: TextStyle(color: AppColors.inkMutedOf(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteAsset(asset.id, filename: asset.filename);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
  }
}
