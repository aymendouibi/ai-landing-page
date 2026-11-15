import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/gradients.dart';
import '../../../core/widgets/app_showcase.dart';

class FloatingBottomBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;
  final VoidCallback onAddClick;
  final GlobalKey? addShowcaseKey;

  const FloatingBottomBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onAddClick,
    this.addShowcaseKey,
  });

  @override
  Widget build(BuildContext context) {
    // Total height 92dp allows the 64dp plus button to protrude 24dp above the 66dp bar
    return SizedBox(
      height: 94,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. iOS Frosted Glass Pill Dock Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(33),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                    blurRadius: 28,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(33),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppColors.isDark(context)
                            ? [
                                const Color(0xFF1E293B).withValues(alpha: 0.85),
                                const Color(0xFF0F172A).withValues(alpha: 0.90),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.55),
                                Colors.white.withValues(alpha: 0.30),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(33),
                      border: Border.all(
                        color: AppColors.isDark(context)
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left 2 items (Projects & Templates)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _NavTabItem(
                                  label: 'nav_projects'.tr,
                                  iconPath: 'assets/icons/ic_nav_projects.png',
                                  isSelected: activeTab == 'Projects',
                                  onTap: () => onTabSelected('Projects'),
                                ),
                              ),
                              Expanded(
                                child: _NavTabItem(
                                  label: 'nav_templates'.tr,
                                  iconPath: 'assets/icons/ic_nav_templates.png',
                                  isSelected: activeTab == 'Templates',
                                  onTap: () => onTabSelected('Templates'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Gap in center for clipping Plus button
                        const SizedBox(width: 68),

                        // Right 2 items (Assets & Profile)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _NavTabItem(
                                  label: 'nav_assets'.tr,
                                  iconPath: 'assets/icons/ic_nav_assets.png',
                                  isSelected: activeTab == 'Assets',
                                  onTap: () => onTabSelected('Assets'),
                                ),
                              ),
                              Expanded(
                                child: _NavTabItem(
                                  label: 'nav_profile'.tr,
                                  iconPath: 'assets/icons/ic_nav_profile.png',
                                  isSelected: activeTab == 'Profile',
                                  onTap: () => onTabSelected('Profile'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. The Plus Button clipping / protruding from the top
          Positioned(
            top: 2,
            child: addShowcaseKey != null
                ? AppShowcase.item(
                    key: addShowcaseKey!,
                    title: 'showcase_create_landing_page_title'.tr,
                    description: 'showcase_add_btn_desc'.tr,
                    targetShapeBorder: const CircleBorder(),
                    child: _buildPlusButton(context),
                  )
                : _buildPlusButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPlusButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddClick,
      child: SizedBox(
        width: 66,
        height: 66,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Radiant Luminous Aura Glow Ring
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x997C5CFF),
                    Color(0x66E46BFF),
                    Color(0x332BC8E8),
                    Colors.transparent,
                  ],
                  radius: 0.95,
                ),
              ),
            ),

            // Outer Sweep Gradient Rim
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.fabAuraSweep,
              ),
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.isDark(context)
                      ? const Color(0xFF38BDF8)
                      : AppColors.ink,
                ),
                child: Icon(
                  LucideIcons.plus,
                  color: AppColors.isDark(context)
                      ? const Color(0xFF0F172A)
                      : Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final color = isSelected
        ? (isDark ? Colors.white : AppColors.ink)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF71717A));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 24, height: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
