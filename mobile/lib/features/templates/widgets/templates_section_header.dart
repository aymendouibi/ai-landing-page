import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../templates_controller.dart';

class TemplatesSectionHeader extends StatelessWidget {
  final TemplatesController controller;
  final bool isDark;

  const TemplatesSectionHeader({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              'templates_curated_edit'.tr,
              style: TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final count = controller.filteredTemplates.length;
            final isForYou = controller.activeTab.value == 'For you';
            final countText =
                isForYou && controller.searchQuery.value.isEmpty
                    ? (count == 1
                          ? '1 design to make yours'
                          : '$count designs to make yours')
                    : (count == 1
                          ? '1 design found'
                          : 'templates_designs_count'.trParams({
                              'count': count.toString(),
                            }));
            return Text(
              countText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            );
          }),
        ],
      ),
    );
  }
}
