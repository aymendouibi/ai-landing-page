import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/localization/supported_locales.dart';
import '../../../core/localization/widgets/language_flag_icon.dart';
import '../../dashboard/dashboard_controller.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final DashboardController controller;

  const LanguageSelectorSheet({super.key, required this.controller});

  static void show(BuildContext context, DashboardController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => LanguageSelectorSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'language'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      LucideIcons.x,
                      size: 20,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Languages List
            Flexible(
              child: Obx(() {
                final selectedLocale = controller.currentLocale.value;
                final isSystem = controller.isUsingSystemLocale.value;

                return ListView(
                  shrinkWrap: true,
                  children: [
                    // System Default (Follows Phone)
                    ListTile(
                      dense: true,
                      leading: Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.smartphone,
                          size: 14,
                          color: isSystem
                              ? AppColors.atmosphereViolet
                              : AppColors.inkMutedOf(context),
                        ),
                      ),
                      title: Text(
                        'system_default_language'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSystem
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      subtitle: Text(
                        'system_default_language_desc'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                      trailing: isSystem
                          ? const Icon(
                              LucideIcons.check,
                              color: AppColors.atmosphereViolet,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        controller.setUseSystemLocale();
                        Navigator.pop(context);
                      },
                    ),

                    Divider(
                      height: 1,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
                    ),

                    ...AppLocales.languages.map((lang) {
                      final isSelected =
                          !isSystem &&
                          selectedLocale.languageCode == lang.languageCode;
                      return ListTile(
                        dense: true,
                        leading: LanguageFlagIcon(
                          languageCode: lang.languageCode,
                          countryCode: lang.countryCode,
                          size: 22,
                        ),
                        title: Text(
                          lang.nativeName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        subtitle: Text(
                          lang.englishName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMutedOf(context),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                LucideIcons.check,
                                color: AppColors.atmosphereViolet,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          controller.setLocale(lang.locale);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
