import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import 'website_config_controller.dart';
import 'widgets/website_config_delete_card.dart';
import 'widgets/website_config_domain_security_card.dart';
import 'widgets/website_config_general_card.dart';
import 'widgets/website_config_landing_files_card.dart';
import 'widgets/website_config_page_header.dart';
import 'widgets/website_config_publishing_card.dart';
import 'widgets/website_config_save_bar.dart';
import 'widgets/website_config_top_nav.dart';
import 'widgets/website_config_shimmer_view.dart';

export 'widgets/manage_dns_sheet.dart';
export 'widgets/website_config_delete_card.dart';
export 'widgets/website_config_domain_security_card.dart';
export 'widgets/website_config_general_card.dart';
export 'widgets/website_config_landing_files_card.dart';
export 'widgets/website_config_page_header.dart';
export 'widgets/website_config_publishing_card.dart';
export 'widgets/website_config_save_bar.dart';
export 'widgets/website_config_top_nav.dart';

class WebsiteConfigScreen extends StatelessWidget {
  const WebsiteConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<WebsiteConfigController>()
        ? Get.find<WebsiteConfigController>()
        : Get.put(WebsiteConfigController());
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const WebsiteConfigShimmerView();
        }

        return Stack(
          children: [
            // Soft atmospheric pastel ambient glow at the top matching mockup
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 280,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E1B4B).withValues(alpha: 0.35),
                            const Color(0xFF1E293B).withValues(alpha: 0.20),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFBAE6FD).withValues(alpha: 0.50),
                            const Color(0xFFE9D5FF).withValues(alpha: 0.45),
                            const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                          ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                children: [
                  // Top Row: Return button & Website switcher
                  WebsiteConfigTopNav(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 18),

                  // Header: Site settings
                  WebsiteConfigPageHeader(isDark: isDark),
                  const SizedBox(height: 24),

                  // 1. General Section
                  WebsiteConfigGeneralCard(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // 2. Publishing Section (Dark obsidian card)
                  WebsiteConfigPublishingCard(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // 3. Domain & Security Section
                  WebsiteConfigDomainSecurityCard(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // 4. Landing Page Files Section (Import & Export ZIP)
                  WebsiteConfigLandingFilesCard(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // 5. Delete Landing Page Section
                  WebsiteConfigDeleteCard(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),

                  // 6. Save Changes Bottom Action
                  WebsiteConfigSaveBar(
                    controller: controller,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
