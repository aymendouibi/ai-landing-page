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
    final siteName = website?.name ?? 'Lumen Coffee';
    final statusText = website?.status == 'published'
        ? 'published_recently'.tr
        : 'edited_recently'.tr;

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
            // Mockup Canvas Preview Area
            Container(
              height: 235,
              width: double.infinity,
              color: const Color(0xFFF5EFE8),
              padding: const EdgeInsets.only(top: 16, left: 14, right: 14),
              child: Stack(
                children: [
                  // Desktop Browser Frame Mockup (Left / Center)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
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
                          // Desktop Nav
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
                                    fontFamily: 'serif',
                                    color: Color(0xFF2C241E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  _miniText('demo_shop'.tr),
                                  const SizedBox(width: 6),
                                  _miniText('demo_subscriptions'.tr),
                                  const SizedBox(width: 6),
                                  _miniText('demo_visit'.tr),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9E4B28),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'demo_order'.tr,
                                      style: const TextStyle(fontSize: 6, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Desktop Hero Copy & Image
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Roastery and café in Portland',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9E4B28),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Small-batch coffee, roasted every Friday',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'serif',
                                        height: 1.15,
                                        color: Color(0xFF2C241E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Single-origin beans from farms we visit, roasted in our shop and shipped same day.',
                                      style: TextStyle(
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
                                        color: const Color(0xFF9E4B28),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'demo_order_beans'.tr,
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
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
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

                  // Overlapping Mobile Frame Mockup (Right)
                  Positioned(
                    right: 4,
                    bottom: 0,
                    child: Container(
                      width: 135,
                      height: 205,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
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
                          // Mobile Nav
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                siteName,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                  color: Color(0xFF2C241E),
                                ),
                              ),
                              const Icon(LucideIcons.menu, size: 10, color: Color(0xFF2C241E)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Roastery and café in Portland',
                            style: TextStyle(
                              fontSize: 5.5,
                              color: Color(0xFF9E4B28),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Small-batch coffee, roasted every Friday',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              height: 1.15,
                              color: Color(0xFF2C241E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9E4B28),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'demo_order_beans'.tr,
                              style: const TextStyle(fontSize: 5.5, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                width: double.infinity,
                                color: const Color(0xFFDCC8B4),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => const SizedBox(),
                                ),
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

            // Bottom Content Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        if (website != null && (website!.status == 'published' || website!.status == 'live')) ...[
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              final sub = website!.subdomain ?? website!.slug;
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
                                    'www.ai-landing-page.xyz/sites/${website!.subdomain ?? website!.slug}',
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

                  // Website Configuration Button
                  GestureDetector(
                    onTap: () {
                      if (website != null) {
                        Get.toNamed(
                          AppRoutes.websiteConfig,
                          arguments: {'websiteId': website!.id},
                        );
                      } else {
                        Get.toNamed(AppRoutes.websiteConfig);
                      }
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

                  // Near-black Primary Pill Action: "Open >"
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
