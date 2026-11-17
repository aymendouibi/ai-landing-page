import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/localization/supported_locales.dart';
import 'package:aibuilder/core/models/app_notification.dart';
import 'package:aibuilder/core/services/notification_service.dart';
import 'package:aibuilder/core/storage/session_manager.dart';
import 'package:aibuilder/features/dashboard/components/notifications_sheet.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  test('All 8 supported locales have complete notification keys', () {
    final translations = AppTranslations().keys;
    final requiredKeys = [
      'notifications',
      'notifications_empty',
      'notifications_empty_desc',
      'notifications_mark_all_read',
      'notifications_ai_edit_title',
      'notifications_ai_edit_body',
      'notifications_site_live_title',
      'notifications_site_live_body',
      'notifications_draft_reminder_title',
      'notifications_draft_reminder_body',
      'system_default_language',
      'theme_system',
      'theme_light',
      'theme_dark',
    ];

    for (final lang in AppLocales.languages) {
      final key = lang.key;
      expect(translations.containsKey(key), isTrue,
          reason: 'Missing locale key $key in AppTranslations');

      final map = translations[key]!;
      for (final requiredKey in requiredKeys) {
        expect(
          map.containsKey(requiredKey),
          isTrue,
          reason: 'Locale $key is missing translation key "$requiredKey"',
        );
        expect(
          map[requiredKey],
          isNotEmpty,
          reason: 'Locale $key has empty translation for "$requiredKey"',
        );
      }
    }
  });

  test('AppNotification model serialization and getters work correctly', () {
    final now = DateTime.now();
    final json = {
      'id': 'notif-123',
      'user_id': 'user-456',
      'type': 'ai_modification',
      'title': 'AI Modification Finished ✨',
      'body': 'Your changes for Bakery were applied.',
      'data': {
        'website_id': 'site-789',
        'site_name': 'Bakery',
        'action': 'open_editor',
      },
      'locale': 'en',
      'read_at': null,
      'created_at': now.toIso8601String(),
    };

    final notif = AppNotification.fromJson(json);
    expect(notif.id, 'notif-123');
    expect(notif.userId, 'user-456');
    expect(notif.type, 'ai_modification');
    expect(notif.title, 'AI Modification Finished ✨');
    expect(notif.isRead, isFalse);
    expect(notif.websiteId, 'site-789');
    expect(notif.siteName, 'Bakery');
    expect(notif.action, 'open_editor');

    final copied = notif.copyWith(readAt: DateTime.now());
    expect(copied.isRead, isTrue);

    final encoded = notif.toJson();
    expect(encoded['id'], 'notif-123');
    expect(encoded['type'], 'ai_modification');
  });

  test('SessionManager adapts to phone system locale and theme mode', () async {
    // When no preference set: defaults to system
    final isSystemLocaleInitial = await SessionManager.isUsingSystemLocale();
    expect(isSystemLocaleInitial, isTrue);

    final isSystemThemeInitial = await SessionManager.isUsingSystemTheme();
    expect(isSystemThemeInitial, isTrue);

    final initialThemeMode = await SessionManager.getThemeMode();
    expect(initialThemeMode, ThemeMode.system);

    // Save manual locale
    await SessionManager.saveLocale(const Locale('fr', 'FR'));
    final isSystemLocaleAfterManual = await SessionManager.isUsingSystemLocale();
    expect(isSystemLocaleAfterManual, isFalse);

    final manualLocale = await SessionManager.getLocale();
    expect(manualLocale.languageCode, 'fr');

    // Switch back to system locale
    await SessionManager.setUseSystemLocale();
    final isSystemAgain = await SessionManager.isUsingSystemLocale();
    expect(isSystemAgain, isTrue);
  });

  test('DashboardController manages notifications state and mark read actions', () async {
    final controller = Get.put(DashboardController());

    final notif1 = AppNotification(
      id: 'n1',
      type: 'ai_modification',
      title: 'AI Edit Done',
      body: 'Your changes were saved',
      createdAt: DateTime.now(),
      data: {'website_id': 'site_1'},
    );

    final notif2 = AppNotification(
      id: 'n2',
      type: 'site_live',
      title: 'Site Live',
      body: 'Site is published',
      createdAt: DateTime.now(),
      data: {'url': 'https://live.site'},
    );

    controller.notifications.assignAll([notif1, notif2]);
    controller.unreadNotificationsCount.value = 2;

    expect(controller.notifications.length, 2);
    expect(controller.unreadNotificationsCount.value, 2);

    // Mark single as read
    await controller.markNotificationAsRead('n1');
    expect(controller.notifications.first.isRead, isTrue);
    expect(controller.unreadNotificationsCount.value, 1);

    // Mark all as read
    await controller.markAllNotificationsAsRead();
    expect(controller.notifications.every((n) => n.isRead), isTrue);
    expect(controller.unreadNotificationsCount.value, 0);
  });

  testWidgets('NotificationsSheet renders list of notifications with icons and title', (tester) async {
    final controller = Get.put(DashboardController());

    final notif = AppNotification(
      id: 'n1',
      type: 'ai_modification',
      title: 'AI Modification Finished ✨',
      body: 'Your changes have been applied',
      createdAt: DateTime.now(),
      data: {'website_id': 'site_1'},
    );
    controller.notifications.assignAll([notif]);
    controller.unreadNotificationsCount.value = 1;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: Scaffold(
          body: NotificationsSheet(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('AI Modification Finished ✨'), findsOneWidget);
    expect(find.text('Your changes have been applied'), findsOneWidget);
  });

  testWidgets('NotificationsSheet renders empty state when no notifications exist', (tester) async {
    final controller = Get.put(DashboardController());
    controller.notifications.clear();
    controller.unreadNotificationsCount.value = 0;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: Scaffold(
          body: NotificationsSheet(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
