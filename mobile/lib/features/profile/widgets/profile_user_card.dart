import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/widgets/user_avatar_circle.dart';
import '../../dashboard/dashboard_controller.dart';
import '../components/edit_profile_sheet.dart';

class ProfileUserCard extends StatelessWidget {
  final DashboardController controller;
  final bool isDark;

  const ProfileUserCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPro = controller.isPremium;
      final isCardDark = isPro || isDark;
      final cardBg = isPro
          ? const Color(0xFF181726)
          : (isDark ? const Color(0xFF1E293B) : Colors.white);

      return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCardDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPro
                  ? const Color(0xFF7C5CFF).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // User Identity Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  // Avatar Circle
                  UserAvatarCircle(
                    size: 54,
                    isDark: isCardDark,
                    isPro: isPro,
                    fontSize: 18,
                  ),
                  const SizedBox(width: 16),

                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPro) ...[
                          Text(
                            'profile_premium_member'.tr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFA78BFA),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        Text(
                          (controller.userName.value != null &&
                                  controller.userName.value!.isNotEmpty)
                              ? controller.userName.value!
                              : 'Morgan Reed',
                          style: TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            color: isCardDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.userEmail.value.isNotEmpty
                              ? controller.userEmail.value
                              : 'morgan.reed@gmail.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: isCardDark
                                ? const Color(0xFF94A3B8)
                                : AppColors.inkMutedOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isCardDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
            ),

            // "Edit profile" row
            InkWell(
              onTap: () => EditProfileSheet.show(context, controller),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'profile_edit_profile'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCardDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: isCardDark
                          ? Colors.white54
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isCardDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
            ),

            // "Account type" row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'profile_account_type'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCardDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPro
                          ? const Color(0xFFC4B5FD)
                          : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPro ? 'profile_premium'.tr : 'profile_free'.tr,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isPro ? FontWeight.w700 : FontWeight.w600,
                        color: isPro
                            ? const Color(0xFF1E1B4B)
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
