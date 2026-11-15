import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../components/feedback_sheet.dart';
import '../components/help_and_guide_sheet.dart';
import 'profile_icon_badge.dart';

class ProfileSupportCard extends StatelessWidget {
  final bool isDark;

  const ProfileSupportCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Help & Prompt guide
          InkWell(
            onTap: () => HelpAndGuideSheet.show(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ProfileIconBadge(
                    icon: LucideIcons.bookOpen,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_help_guide'.tr,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'profile_help_guide_desc'.tr,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkMutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.inkMutedOf(context),
                  ),
                ],
              ),
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF1F5F9),
          ),

          // Row 2: Send feedback
          InkWell(
            onTap: () => FeedbackSheet.show(context),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ProfileIconBadge(
                    icon: LucideIcons.messageSquare,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_send_feedback'.tr,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'profile_send_feedback_desc'.tr,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkMutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.inkMutedOf(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
