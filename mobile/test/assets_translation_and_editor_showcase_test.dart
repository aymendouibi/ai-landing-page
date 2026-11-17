import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/storage/session_manager.dart';
import 'package:aibuilder/core/widgets/app_showcase.dart';
import 'package:aibuilder/features/dashboard/components/new_website_bottom_sheet.dart';
import 'package:aibuilder/features/editor/editor_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('assets_upload_from_device translations', () {
    final translations = AppTranslations();
    final keys = translations.keys;

    test('All 8 supported locales have assets_upload_from_device key', () {
      const locales = [
        'en_US',
        'es_ES',
        'fr_FR',
        'de_DE',
        'ar_SA',
        'zh_CN',
        'ja_JP',
        'pt_BR',
      ];

      for (final locale in locales) {
        expect(keys.containsKey(locale), isTrue,
            reason: 'Locale $locale should exist');
        final map = keys[locale]!;
        expect(map.containsKey('assets_upload_from_device'), isTrue,
            reason: '$locale should contain assets_upload_from_device');
        expect(map['assets_upload_from_device']!.isNotEmpty, isTrue,
            reason: '$locale assets_upload_from_device should not be empty');
      }
    });

    test('assets_upload_from_device translations match expected values', () {
      expect(keys['en_US']!['assets_upload_from_device'], 'Upload from Device');
      expect(keys['es_ES']!['assets_upload_from_device'], 'Subir desde el dispositivo');
      expect(keys['fr_FR']!['assets_upload_from_device'], "Téléverser depuis l'appareil");
      expect(keys['de_DE']!['assets_upload_from_device'], 'Vom Gerät hochladen');
      expect(keys['ar_SA']!['assets_upload_from_device'], 'التحميل من الجهاز');
      expect(keys['zh_CN']!['assets_upload_from_device'], '从设备上传');
      expect(keys['ja_JP']!['assets_upload_from_device'], 'デバイスからアップロード');
      expect(keys['pt_BR']!['assets_upload_from_device'], 'Carregar do dispositivo');
    });
  });

  group('Editor showcase behavior & panel state', () {
    test('AppShowcase dismiss executes cleanly without throwing', () {
      expect(() => AppShowcase.dismiss(), returnsNormally);
    });

    test('SessionManager manages editor showcase seen state correctly', () async {
      expect(await SessionManager.hasSeenEditorShowcase(), isFalse);

      await SessionManager.setEditorShowcaseSeen(true);
      expect(await SessionManager.hasSeenEditorShowcase(), isTrue);

      await SessionManager.resetShowcases();
      expect(await SessionManager.hasSeenEditorShowcase(), isFalse);
    });

    test('SessionManager manages new website bottom sheet showcase seen state correctly', () async {
      expect(await SessionManager.hasSeenNewWebsiteShowcase(), isFalse);

      await SessionManager.setNewWebsiteShowcaseSeen(true);
      expect(await SessionManager.hasSeenNewWebsiteShowcase(), isTrue);

      await SessionManager.resetShowcases();
      expect(await SessionManager.hasSeenNewWebsiteShowcase(), isFalse);
    });

    test('EditorController keeps panel closed on empty page when showcase is unseen', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_editor_showcase': false,
      });

      final controller = EditorController();
      controller.document.value = {
        'id': 'empty-site',
        'pages': [
          {
            'id': 'p1',
            'sections': [],
          }
        ],
      };

      // Trigger selection logic
      controller.autoSelectInitialElement();
      // Allow any microtasks to run
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // isPanelOpen must remain false so the showcase tour can display the canvas and dock
      expect(controller.isPanelOpen.value, isFalse);
    });

    test('EditorController opens panel on empty page when showcase was already seen', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_editor_showcase': true,
      });

      final controller = EditorController();
      controller.document.value = {
        'id': 'empty-site',
        'pages': [
          {
            'id': 'p1',
            'sections': [],
          }
        ],
      };

      // Set empty site document and trigger auto select
      controller.autoSelectInitialElement();
      // Allow async session check to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.isPanelOpen.value, isTrue);
      expect(controller.selectedTab.value, 0); // Add tab
    });

    testWidgets('NewWebsiteBottomSheet initializes cleanly and dismisses showcase on dispose', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: NewWebsiteBottomSheet(
              onDescribeToAi: () {},
              onStartFromTemplate: () {},
              onBlankWebsite: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New website'), findsOneWidget);
      expect(find.text('Describe it to AI'), findsOneWidget);
      expect(find.text('Start from a template'), findsOneWidget);
      expect(find.text('Blank website'), findsOneWidget);
    });
  });
}
