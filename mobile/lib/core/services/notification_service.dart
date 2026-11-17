import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../network/api_client.dart';
import '../storage/session_manager.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  /// Show an in-app banner for a notification event
  void showNotificationBanner({
    required String title,
    required String body,
    IconData icon = LucideIcons.bell,
    Color accentColor = const Color(0xFF6366F1),
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (Get.context == null) return;

    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.rawSnackbar(
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text(
          body,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      duration: duration,
      onTap: (_) {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }

  /// Trigger notification when AI finishes modification
  void showAiModificationNotification({
    required String siteName,
    String? summary,
    VoidCallback? onTap,
  }) {
    final title = 'notifications_ai_edit_title'.tr;
    var body = 'notifications_ai_edit_body'.trParams({'site': siteName});
    if (summary != null && summary.isNotEmpty && !summary.startsWith('AI Edit:')) {
      body += ' ($summary)';
    }

    showNotificationBanner(
      title: title,
      body: body,
      icon: LucideIcons.sparkles,
      accentColor: const Color(0xFFA855F7), // Purple
      onTap: onTap,
    );
  }

  /// Trigger notification when website is live
  void showSiteLiveNotification({
    required String siteName,
    required String url,
    VoidCallback? onTap,
  }) {
    final title = 'notifications_site_live_title'.tr;
    final body = 'notifications_site_live_body'.trParams({'site': siteName});

    showNotificationBanner(
      title: title,
      body: body,
      icon: LucideIcons.rocket,
      accentColor: const Color(0xFF10B981), // Emerald
      onTap: onTap,
    );
  }

  /// Trigger draft reminder notification
  void showDraftReminderNotification({
    required String siteName,
    VoidCallback? onTap,
  }) {
    final title = 'notifications_draft_reminder_title'.tr;
    final body = 'notifications_draft_reminder_body'.trParams({'site': siteName});

    showNotificationBanner(
      title: title,
      body: body,
      icon: LucideIcons.fileText,
      accentColor: const Color(0xFF06B6D4), // Cyan
      onTap: onTap,
    );
  }

  /// Sync user language & theme preferences with backend
  Future<void> syncPreferences({Locale? locale, ThemeMode? themeMode}) async {
    try {
      final isLoggedIn = await SessionManager.isLoggedIn();
      if (!isLoggedIn) return;

      final loc = locale ?? await SessionManager.getLocale();
      final theme = themeMode ?? await SessionManager.getThemeMode();

      final themeStr = theme == ThemeMode.dark
          ? 'dark'
          : (theme == ThemeMode.light ? 'light' : 'system');

      await ApiClient.syncNotificationPreferences(
        locale: loc.languageCode,
        themeMode: themeStr,
      );
    } catch (_) {
      // Non-blocking sync
    }
  }
}
