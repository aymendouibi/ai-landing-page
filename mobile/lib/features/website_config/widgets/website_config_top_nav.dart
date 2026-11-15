import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/website.dart';
import '../website_config_controller.dart';

class WebsiteConfigTopNav extends StatelessWidget {
  final WebsiteConfigController controller;
  final bool isDark;
  final VoidCallback? onBack;

  const WebsiteConfigTopNav({
    super.key,
    required this.controller,
    required this.isDark,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Deduplicate websites by ID for the switcher dropdown
    final seenIds = <String>{};
    final uniqueSites = <Website>[];
    for (final site in controller.allWebsites) {
      if (seenIds.add(site.id)) {
        uniqueSites.add(site);
      }
    }

    final currentId = controller.websiteId.value;
    final hasMatch = uniqueSites.any((site) => site.id == currentId);
    final dropdownValue = hasMatch
        ? currentId
        : (uniqueSites.isNotEmpty ? uniqueSites.first.id : null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Return button without text
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.90),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            key: const Key('website_config_back_button'),
            tooltip: 'site_settings_return_tooltip'.tr,
            padding: EdgeInsets.zero,
            icon: Icon(
              LucideIcons.arrowLeft,
              size: 18,
              color: AppColors.inkOf(context),
            ),
            onPressed: onBack ?? () => Get.back(),
          ),
        ),

        // Website switcher if user has multiple websites
        if (uniqueSites.length > 1)
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 130),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  isDense: true,
                  isExpanded: true,
                  icon: Icon(
                    LucideIcons.chevronDown,
                    size: 14,
                    color: AppColors.inkMutedOf(context),
                  ),
                  dropdownColor: AppColors.surfaceOf(context),
                  items: uniqueSites.map((site) {
                    return DropdownMenuItem(
                      value: site.id,
                      child: Text(
                        site.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) controller.selectWebsite(id);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
