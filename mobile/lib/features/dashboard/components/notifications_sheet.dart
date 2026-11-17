import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/app_notification.dart';
import '../dashboard_controller.dart';

class NotificationsSheet extends StatelessWidget {
  final DashboardController controller;

  const NotificationsSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, DashboardController controller) {
    controller.loadNotifications();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => NotificationsSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        padding: const EdgeInsets.only(top: 14, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'notifications'.tr,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Unread Count Badge
                  Obx(() {
                    final unread = controller.unreadNotificationsCount.value;
                    if (unread <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),

                  const Spacer(),

                  // Mark All as Read Button
                  Obx(() {
                    final unread = controller.unreadNotificationsCount.value;
                    if (unread <= 0) return const SizedBox.shrink();
                    return TextButton(
                      onPressed: controller.markAllNotificationsAsRead,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'notifications_mark_all_read'.tr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }),

                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
            ),

            // Content List / Empty State
            Flexible(
              child: Obx(() {
                final list = controller.notifications;

                if (list.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 64,
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final notif = list[index];
                    return _buildNotificationTile(context, notif, isDark);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bellOff,
              size: 28,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'notifications_empty'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.inkOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'notifications_empty_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.inkMutedOf(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    AppNotification notif,
    bool isDark,
  ) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (notif.type) {
      case 'ai_modification':
        icon = LucideIcons.sparkles;
        iconColor = const Color(0xFFA855F7); // Purple
        iconBg = iconColor.withValues(alpha: 0.15);
        break;
      case 'site_live':
        icon = LucideIcons.rocket;
        iconColor = const Color(0xFF10B981); // Emerald
        iconBg = iconColor.withValues(alpha: 0.15);
        break;
      case 'draft_reminder':
        icon = LucideIcons.fileText;
        iconColor = const Color(0xFF06B6D4); // Cyan
        iconBg = iconColor.withValues(alpha: 0.15);
        break;
      default:
        icon = LucideIcons.bell;
        iconColor = const Color(0xFF6366F1); // Indigo
        iconBg = iconColor.withValues(alpha: 0.15);
        break;
    }

    return InkWell(
      onTap: () {
        controller.onNotificationTapped(notif);
        Navigator.pop(context);
      },
      child: Container(
        color: !notif.isRead
            ? (isDark
                ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                : const Color(0xFF6366F1).withValues(alpha: 0.04))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.inkOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatRelativeTime(notif.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkMutedOf(context),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread Dot
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}';
  }
}
