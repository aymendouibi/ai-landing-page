import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/uploaded_image.dart';
import '../assets_controller.dart';

class AssetDetailDialog extends StatelessWidget {
  final UploadedImage asset;
  final AssetsController controller;

  const AssetDetailDialog({
    super.key,
    required this.asset,
    required this.controller,
  });

  static void show(BuildContext context, UploadedImage asset, AssetsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AssetDetailDialog(asset: asset, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag handle & close button
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.atmosphereViolet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          asset.fileExtension,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.atmosphereViolet,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          asset.filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceMutedOf(context),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Large Image Preview
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 260),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  border: Border.all(color: AppColors.borderSubtleOf(context)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: asset.url.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: asset.url,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceMutedOf(context),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              LucideIcons.imageOff,
                              size: 40,
                              color: AppColors.inkMutedOf(context),
                            ),
                          ),
                        )
                      : Image.network(
                          asset.url,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              LucideIcons.image,
                              size: 40,
                              color: AppColors.inkMutedOf(context),
                            ),
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Metadata grid
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedOf(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildMetaRow(context, 'Dimensions', asset.dimensions, LucideIcons.maximize2),
                  const Divider(height: 14),
                  _buildMetaRow(context, 'File Size', asset.formattedSize, LucideIcons.hardDrive),
                  const Divider(height: 14),
                  _buildMetaRow(context, 'Associated Site', asset.siteName ?? 'Global / Unassigned', LucideIcons.globe),
                  if (asset.alt.isNotEmpty) ...[
                    const Divider(height: 14),
                    _buildMetaRow(context, 'Alt Text', asset.alt, LucideIcons.alignLeft),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                // Copy Link Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.copyAssetUrl(asset);
                      Navigator.pop(context);
                    },
                    icon: const Icon(LucideIcons.copy, size: 14),
                    label: Text('assets_copy_link'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Delete Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                  icon: const Icon(LucideIcons.trash2, size: 14),
                  label: Text('common_delete'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    foregroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.inkMutedOf(context)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.inkMutedOf(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkOf(context),
            ),
          ),
        ),
      ],
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
          'assets_delete_confirm_desc'.tr,
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
