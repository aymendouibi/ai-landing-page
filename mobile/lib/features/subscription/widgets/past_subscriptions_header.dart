import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';

class PastSubscriptionsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final bool isDark;

  const PastSubscriptionsHeader({
    super.key,
    required this.onBack,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular back button
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.2 : 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              key: const Key('past_subscriptions_back_button'),
              tooltip: 'common_back'.tr,
              padding: EdgeInsets.zero,
              icon: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.inkOf(context),
              ),
              onPressed: onBack,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Title
        Text(
          'past_sub_title'.tr,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.inkOf(context),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'past_sub_subtitle'.tr,
          style: TextStyle(
            fontSize: 14.5,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
