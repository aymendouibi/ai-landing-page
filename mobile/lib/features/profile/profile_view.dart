import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/designsystem/gradients.dart';
import '../dashboard/dashboard_controller.dart';
import 'widgets/profile_preferences_card.dart';
import 'widgets/profile_privacy_card.dart';
import 'widgets/profile_section_title.dart';
import 'widgets/profile_support_card.dart';
import 'widgets/profile_subscription_card.dart';
import 'widgets/profile_user_card.dart';

export 'widgets/profile_icon_badge.dart';
export 'widgets/profile_preferences_card.dart';
export 'widgets/profile_privacy_card.dart';
export 'widgets/profile_section_title.dart';
export 'widgets/profile_sign_out_dialog.dart';
export 'widgets/profile_support_card.dart';
export 'widgets/profile_subscription_card.dart';
export 'widgets/profile_user_card.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final isDark = AppColors.isDark(context);

    return Stack(
      children: [
        // Soft iridescent gradient wash background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.profileBackgroundGradient(isDark),
            ),
          ),
        ),

        // Main Scrollable Content
        SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: 140,
            ),
            children: [
              // Page Title: "Profile"
              Text(
                'profile_title'.tr,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkOf(context),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 18),

              // 1. User Profile Card
              ProfileUserCard(
                controller: controller,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 2. Subscription Card (matching user mockup)
              ProfileSubscriptionCard(
                controller: controller,
                isDark: isDark,
              ),
              const SizedBox(height: 28),

              // 3. Preferences Section
              ProfileSectionTitle(title: 'profile_preferences'.tr),
              ProfilePreferencesCard(
                controller: controller,
                isDark: isDark,
              ),
              const SizedBox(height: 26),

              // 4. Support & Community (Feature 5)
              ProfileSectionTitle(title: 'profile_support_community'.tr),
              ProfileSupportCard(isDark: isDark),
              const SizedBox(height: 26),

              // 5. Privacy & Account Section (includes Terms of Service)
              ProfileSectionTitle(title: 'profile_privacy_account'.tr),
              ProfilePrivacyCard(
                controller: controller,
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // Footer: "AI Landing Page · Version 1.0.0"
              Center(
                child: Text(
                  'profile_app_version'.tr,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMutedOf(context).withValues(alpha: 0.8),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
