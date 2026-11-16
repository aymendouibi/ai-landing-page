import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/typography.dart';
import '../../../core/models/website.dart';
import '../../../core/routes/app_routes.dart';

class ContinueEditingHeroCard extends StatelessWidget {
  final Website? website;
  final VoidCallback onOpenClick;

  const ContinueEditingHeroCard({
    super.key,
    required this.website,
    required this.onOpenClick,
  });

  @override
  Widget build(BuildContext context) {
    if (website == null) {
      return _buildEmptyState(context);
    }
    return _buildHeroWebsiteCard(context, website!);
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onOpenClick,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtleOf(context), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x181E1E50),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1E1B4B),
                          const Color(0xFF0F172A),
                          const Color(0xFF172554),
                        ]
                      : [
                          const Color(0xFFEEF2FF),
                          const Color(0xFFF8FAFC),
                          const Color(0xFFE0E7FF),
                        ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.indigoAccent.withValues(alpha: 0.2)
                            : Colors.indigo.shade50,
                        border: Border.all(
                          color: isDark
                              ? Colors.indigoAccent.withValues(alpha: 0.4)
                              : Colors.indigo.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.sparkles,
                        size: 26,
                        color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready to bring your idea to life?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Build high-converting landing pages with AI in seconds',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No pages generated yet',
                          style: AppTypography.heroCardTitleOf(context).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap here to create your first website',
                          style: AppTypography.helperOf(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : AppColors.ink,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.plus,
                          size: 15,
                          color: isDark ? AppColors.ink : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Create Page',
                          style: TextStyle(
                            color: isDark ? AppColors.ink : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroWebsiteCard(BuildContext context, Website site) {
    final siteName = site.name.isNotEmpty ? site.name : 'Untitled Website';
    final isLive = site.status == 'published' || site.status == 'live';
    final statusText = isLive ? 'published_recently'.tr : 'edited_recently'.tr;

    String headline = 'Crafted for Modern Growth';
    String subheadline = 'Clean architecture and custom layout optimized for conversion.';
    String ctaText = 'Explore work';
    String imageUrl = 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80';
    Color primaryColor = const Color(0xFF1E293B);
    Color canvasBg = const Color(0xFFFAF7F2);

    final doc = site.document;
    if (doc != null) {
      final pages = doc['pages'] as List?;
      if (pages != null && pages.isNotEmpty) {
        final sections = (pages.first as Map)['sections'] as List?;
        if (sections != null) {
          for (final sec in sections) {
            if (sec is Map && (sec['component'] == 'hero' || sec['type'] == 'hero')) {
              final props = sec['props'] as Map?;
              if (props != null) {
                headline = props['headline']?.toString() ?? props['title']?.toString() ?? headline;
                subheadline = props['subheadline']?.toString() ?? props['description']?.toString() ?? subheadline;
                ctaText = props['ctaText']?.toString() ?? props['cta_text']?.toString() ?? ctaText;
                final raw = props['image'] ?? props['imageUrl'] ?? props['url'];
                if (raw is Map) {
                  imageUrl = raw['src']?.toString() ?? raw['url']?.toString() ?? imageUrl;
                } else if (raw is String && raw.startsWith('http')) {
                  imageUrl = raw;
                }
              }
              break;
            }
          }
        }
      }

      final theme = (doc['site'] as Map?)?['theme'] as Map?;
      final colors = theme?['colors'] as Map?;
      if (colors != null) {
        if (colors['primary'] != null) {
          final hex = colors['primary'].toString().replaceAll('#', '');
          if (hex.length == 6) {
            primaryColor = Color(int.parse('FF$hex', radix: 16));
          }
        }
        if (colors['background'] != null) {
          final hex = colors['background'].toString().replaceAll('#', '');
          if (hex.length == 6) {
            canvasBg = Color(int.parse('FF$hex', radix: 16));
          }
        }
      }
    }

    return GestureDetector(
      onTap: onOpenClick,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtleOf(context), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.isDark(context)
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0x181E1E50),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 235,
              width: double.infinity,
              color: const Color(0xFFF5EFE8),
              padding: const EdgeInsets.only(top: 16, left: 14, right: 14),
              child: Stack(
                children: [
                  // Desktop Browser Frame Mockup
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: canvasBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        border: Border.all(color: const Color(0xFFE2DACF), width: 0.75),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  siteName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C241E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  _miniText('demo_shop'.tr),
                                  const SizedBox(width: 6),
                                  _miniText('demo_visit'.tr),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ctaText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 6, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      headline,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        height: 1.15,
                                        color: Color(0xFF2C241E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subheadline,
                                      style: const TextStyle(
                                        fontSize: 6.5,
                                        height: 1.25,
                                        color: Color(0xFF7A6B5D),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ctaText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 6.5, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 60,
                                  height: 90,
                                  color: const Color(0xFFDCC8B4),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => const SizedBox(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlapping Mobile Frame Mockup
                  Positioned(
                    right: 4,
                    bottom: 0,
                    child: Container(
                      width: 135,
                      height: 205,
                      decoration: BoxDecoration(
                        color: canvasBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                        border: Border.all(color: const Color(0xFFDDD2C4), width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x381E1E40),
                            blurRadius: 14,
                            offset: Offset(-3, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  siteName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C241E),
                                  ),
                                ),
                              ),
                              const Icon(LucideIcons.menu, size: 10, color: Color(0xFF2C241E)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            headline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                              color: Color(0xFF2C241E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              ctaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 5.5, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const SizedBox(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'continue_editing'.tr,
                          style: AppTypography.helperOf(context),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          siteName,
                          style: AppTypography.heroCardTitleOf(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          statusText,
                          style: AppTypography.helperOf(context),
                        ),
                        if (isLive) ...[
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              final sub = site.subdomain ?? site.slug;
                              final fullUrl = 'https://www.ai-landing-page.xyz/sites/$sub';
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.globe,
                                  size: 13,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'www.ai-landing-page.xyz/sites/${site.subdomain ?? site.slug}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.inkMutedOf(context),
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  LucideIcons.copy,
                                  size: 12,
                                  color: AppColors.inkMutedOf(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.websiteConfig,
                        arguments: {'websiteId': site.id},
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMutedOf(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtleOf(context)),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.settings,
                        size: 18,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.isDark(context) ? Colors.white : AppColors.ink,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x200C0C14),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'open'.tr,
                          style: TextStyle(
                            color: AppColors.isDark(context) ? AppColors.ink : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          color: AppColors.isDark(context) ? AppColors.ink : Colors.white,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _miniText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 7, color: Color(0xFF7A6B5D)),
    );
  }
}
