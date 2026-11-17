import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/user_avatar_circle.dart';

class TemplatesHeader extends StatelessWidget {
  final VoidCallback? onAvatarTap;
  final bool isDark;

  const TemplatesHeader({
    super.key,
    this.onAvatarTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header: Title + User Avatar Pill
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'templates_title'.tr,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: isDark ? Colors.white : const Color(0xFF090D16),
                ),
              ),
              // Circular Avatar Pill
              UserAvatarCircle(
                size: 40,
                isDark: isDark,
                onTap: onAvatarTap,
              ),
            ],
          ),
        ),

        // Subtitle & Tagline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'templates_headline'.tr,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'templates_subtitle'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
