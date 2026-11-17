import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../templates_controller.dart';

class TemplatesCategoryTabs extends StatelessWidget {
  final TemplatesController controller;
  final bool isDark;

  const TemplatesCategoryTabs({
    super.key,
    required this.controller,
    required this.isDark,
  });

  static String getTabTranslation(String tab) {
    switch (tab) {
      case 'For you':
        return 'tab_for_you'.tr;
      case 'Startups':
        return 'tab_startups'.tr;
      case 'Business':
        return 'tab_business'.tr;
      case 'Weddings':
        return 'tab_weddings'.tr;
      case 'Creative':
        return 'tab_creative'.tr;
      case 'Personal':
        return 'tab_personal'.tr;
      case 'Community':
        return 'tab_community'.tr;
      default:
        return tab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Obx(() {
        final currentTab = controller.activeTab.value;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.tabs.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final tab = controller.tabs[index];
            final isSelected = currentTab == tab;
            return GestureDetector(
              onTap: () => controller.setTab(tab),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getTabTranslation(tab),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: isSelected ? 28 : 0,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
