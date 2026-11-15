import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../dashboard/dashboard_controller.dart';
import '../../subscription/past_subscriptions_view.dart';
import '../components/privacy_policy_sheet.dart';
import '../components/terms_of_service_sheet.dart';
import 'profile_icon_badge.dart';
import 'profile_sign_out_dialog.dart';

class ProfilePrivacyCard extends StatelessWidget {
  final DashboardController controller;
  final bool isDark;

  const ProfilePrivacyCard({
    super.key,
    required this.controller,
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
          // Row 1: Privacy policy
          InkWell(
            onTap: () => PrivacyPolicySheet.show(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ProfileIconBadge(
                    icon: LucideIcons.shieldCheck,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'profile_privacy_policy'.tr,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                      ),
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

          // Row 2: Terms of service
          InkWell(
            onTap: () => TermsOfServiceSheet.show(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ProfileIconBadge(
                    icon: LucideIcons.fileText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'profile_terms_service'.tr,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                      ),
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

          // Row 3: Past subscriptions & billing history
          InkWell(
            onTap: () => PastSubscriptionsView.open(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ProfileIconBadge(
                    icon: LucideIcons.receipt,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_billing_history'.tr,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'profile_past_sub_subtitle'.tr,
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

          // Row 4: Sign out
          InkWell(
            onTap: () => ProfileSignOutDialog.show(context, controller),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFDC2626).withValues(alpha: 0.2)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.logOut,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'profile_sign_out_title'.tr,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
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
