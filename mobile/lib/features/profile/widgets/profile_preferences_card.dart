import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/localization/supported_locales.dart';
import '../../dashboard/dashboard_controller.dart';
import '../components/language_selector_sheet.dart';
import 'profile_icon_badge.dart';

class ProfilePreferencesCard extends StatelessWidget {
  final DashboardController controller;
  final bool isDark;

  const ProfilePreferencesCard({
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
          // Row 1: Language
          InkWell(
            onTap: () => LanguageSelectorSheet.show(context, controller),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ProfileIconBadge(
                    icon: LucideIcons.globe,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'language'.tr,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                      ),
                    ),
                  ),
                  Obx(() {
                    final current = AppLocales.fromLocale(
                      controller.currentLocale.value,
                    );
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          current.englishName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.inkMutedOf(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ],
                    );
                  }),
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

          // Row 2: Dark theme
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ProfileIconBadge(
                  icon: LucideIcons.moon,
                  isDark: isDark,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile_dark_theme'.tr,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'profile_dark_theme_desc'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final isThemeDark =
                      controller.themeMode.value == ThemeMode.dark ||
                      (controller.themeMode.value == ThemeMode.system &&
                          isDark);
                  return Switch.adaptive(
                    value: isThemeDark,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF1E293B),
                    onChanged: (val) {
                      controller.setThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
