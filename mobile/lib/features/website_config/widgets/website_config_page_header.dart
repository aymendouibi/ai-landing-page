import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/designsystem/colors.dart';

class WebsiteConfigPageHeader extends StatelessWidget {
  final bool isDark;

  const WebsiteConfigPageHeader({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'site_settings_title'.tr,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.inkOf(context),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'site_settings_subtitle'.tr,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
