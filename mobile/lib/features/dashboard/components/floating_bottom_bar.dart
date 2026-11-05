import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/gradients.dart';

class FloatingBottomBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;
  final VoidCallback onAddClick;

  const FloatingBottomBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onAddClick,
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
                        colors: [
                          Colors.white.withValues(alpha: 0.55),
                          Colors.white.withValues(alpha: 0.30),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(33),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
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
                            _NavTabItem(
                              label: 'Projects',
                              iconPath: 'assets/icons/ic_nav_projects.png',
                              isSelected: activeTab == 'Projects',
                              onTap: () => onTabSelected('Projects'),
                            ),
                            _NavTabItem(
                              label: 'Templates',
                              iconPath: 'assets/icons/ic_nav_templates.png',
                              isSelected: activeTab == 'Templates',
                              onTap: () => onTabSelected('Templates'),
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
                            _NavTabItem(
                              label: 'Assets',
                              iconPath: 'assets/icons/ic_nav_assets.png',
                              isSelected: activeTab == 'Assets',
                              onTap: () => onTabSelected('Assets'),
                            ),
                            _NavTabItem(
                              label: 'Profile',
                              iconPath: 'assets/icons/ic_nav_profile.png',
                              isSelected: activeTab == 'Profile',
                              onTap: () => onTabSelected('Profile'),
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
            child: GestureDetector(
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ink,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    final color = isSelected ? AppColors.ink : const Color(0xFF71717A);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
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

