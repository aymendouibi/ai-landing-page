import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/routes/app_routes.dart';

class WebsitePreviewItem {
  final String id;
  final String title;
  final String category;
  final Color? categoryColor;
  final String headline;
  final String body;
  final String ctaText;
  final Color ctaColor;
  final double ctaBorderRadius;
  final String imageUrl;
  final bool isSerif;
  final Color bgCanvasColor;
  final bool isLive;
  final String? domain;
  final String? timeAgo;

  const WebsitePreviewItem({
    required this.id,
    required this.title,
    required this.category,
    this.categoryColor,
    required this.headline,
    required this.body,
    required this.ctaText,
    required this.ctaColor,
    this.ctaBorderRadius = 3.0,
    required this.imageUrl,
    this.isSerif = true,
    this.bgCanvasColor = const Color(0xFFFAF8F5),
    this.isLive = false,
    this.domain,
    this.timeAgo,
  });
}

class RecentProjectCard extends StatelessWidget {
  final WebsitePreviewItem item;
  final VoidCallback onClick;

  const RecentProjectCard({
    super.key,
    required this.item,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: SizedBox(
        width: 215,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Website Mobile Viewport Snapshot Card
            Container(
              width: 215,
              height: 285,
              decoration: BoxDecoration(
                color: item.bgCanvasColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.isDark(context)
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
                  // Top Website Content (Header, Eyebrow, Headline, Body, CTA)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mini Nav Bar (Site Title + 2-bar menu icon)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: item.isSerif ? 'serif' : null,
                                  color: const Color(0xFF1E1E24),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Clean 2-bar modern mobile menu icon
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 14,
                                  height: 1.6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E24),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  width: 14,
                                  height: 1.6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E24),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Eyebrow / Category
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: item.categoryColor ?? const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Headline
                        Text(
                          item.headline,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                            fontFamily: item.isSerif ? 'serif' : null,
                            color: const Color(0xFF1E1E24),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),

                        // Body Paragraph
                        Text(
                          item.body,
                          style: const TextStyle(
                            fontSize: 9.5,
                            height: 1.3,
                            color: Color(0xFF71717A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // CTA Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: item.ctaColor,
                            borderRadius: BorderRadius.circular(item.ctaBorderRadius),
                          ),
                          child: Text(
                            item.ctaText,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Real Image Snapshot filling the bottom of the card
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: const Color(0xFFF1F5F9)),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(LucideIcons.image, size: 24, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Website Name + Config action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.websiteConfig,
                      arguments: {'websiteId': item.id},
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      LucideIcons.settings,
                      size: 15,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 3. Status Line: Live dot + URL, or Draft with edit timestamp
            if (item.isLive)
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'live'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  if (item.domain != null && item.domain!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final fullUrl = item.domain!.startsWith('http')
                              ? item.domain!
                              : 'https://${item.domain}';
                          Clipboard.setData(ClipboardData(text: fullUrl));
                          Get.snackbar(
                            'Copied!',
                            'Website link copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFF0F172A),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.domain!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMutedOf(context),
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.copy,
                              size: 11,
                              color: AppColors.inkMutedOf(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else
              Text(
                item.timeAgo ?? 'edited_recently'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.inkMutedOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
