import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TemplatesEmptyState extends StatelessWidget {
  final bool isDark;

  const TemplatesEmptyState({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.layoutGrid,
              size: 48,
              color: isDark
                  ? const Color(0xFF475569)
                  : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              'templates_no_search_results'.tr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
