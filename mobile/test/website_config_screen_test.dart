import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/models/website.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';
import 'package:aibuilder/features/website_config/website_config_controller.dart';
import 'package:aibuilder/features/website_config/website_config_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget buildTestWidget(Widget child) {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('en', 'US'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WebsiteConfigController controller;
  late DashboardController dashboardController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    dashboardController = DashboardController();
    dashboardController.planSlug.value = 'pro';
    Get.put<DashboardController>(dashboardController);

    controller = WebsiteConfigController();
    controller.isLoading.value = false;
    controller.websiteId.value = 'site_1';
    controller.websiteName.value = "Morgan's portfolio";
    controller.nameController.text = "Morgan's portfolio";
    controller.status.value = 'published';
    controller.liveUrl.value = 'https://morgan.design';
    controller.domains.assignAll([
      {
        'id': 'dom_1',
        'domain': 'morgan.design',
        'status': 'active',
      }
    ]);

    Get.put<WebsiteConfigController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('WebsiteConfigScreen and Modular Widgets Tests', () {
    testWidgets('WebsiteConfigTopNav renders return button and handles tap', (tester) async {
      var backTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigTopNav(
            controller: controller,
            isDark: false,
            onBack: () => backTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backBtn = find.byKey(const Key('website_config_back_button'));
      expect(backBtn, findsOneWidget);
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);

      await tester.tap(backBtn);
      await tester.pumpAndSettle();
      expect(backTapped, isTrue);
    });

    testWidgets('WebsiteConfigTopNav renders website switcher when multiple websites exist', (tester) async {
      controller.allWebsites.assignAll([
        Website(
          id: 'site_1',
          projectId: 'p1',
          name: 'Site One',
          slug: 'site-one',
          status: 'published',
          revisionNumber: 1,
        ),
        Website(
          id: 'site_2',
          projectId: 'p1',
          name: 'Site Two',
          slug: 'site-two',
          status: 'draft',
          revisionNumber: 1,
        ),
      ]);

      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigTopNav(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Site One'), findsOneWidget);
    });

    testWidgets('WebsiteConfigPageHeader renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const WebsiteConfigPageHeader(isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Site settings'), findsOneWidget);
      expect(find.text('Your page, ready for the world.'), findsOneWidget);
    });

    testWidgets('WebsiteConfigGeneralCard renders site name input with controller text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigGeneralCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('General'), findsOneWidget);
      expect(find.text('Site name'), findsOneWidget);
      expect(find.text("Morgan's portfolio"), findsOneWidget);
      expect(find.text('Only visible to you in your projects.'), findsOneWidget);

      // Enter new site name
      await tester.enterText(find.byType(TextField).first, 'Updated Studio');
      await tester.pumpAndSettle();
      expect(controller.nameController.text, equals('Updated Studio'));

      // Enter new favicon
      await tester.enterText(find.byType(TextField).last, 'https://example.com/fav.png');
      await tester.pumpAndSettle();
      expect(controller.faviconController.text, equals('https://example.com/fav.png'));
    });

    testWidgets('WebsiteConfigPublishingCard displays Live badge and opens unpublish dialog', (tester) async {
      controller.status.value = 'published';

      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigPublishingCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Publishing'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Unpublished'), findsOneWidget);
      expect(find.text('Live at https://morgan.design'), findsOneWidget);

      // Tap Unpublished while live -> confirmation dialog appears
      await tester.tap(find.text('Unpublished'));
      await tester.pumpAndSettle();

      expect(find.text('Unpublish website?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Unpublish'), findsOneWidget);
    });

    testWidgets('WebsiteConfigPublishingCard displays Draft badge when not published', (tester) async {
      controller.status.value = 'draft';

      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigPublishingCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('WebsiteConfigDomainSecurityCard renders custom domain and toggles HTTPS', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigDomainSecurityCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Domain & security'), findsOneWidget);
      expect(find.text('Custom domain'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Manage DNS'), findsOneWidget);
      expect(find.text('SSL certificate'), findsOneWidget);
      expect(find.text('Force HTTPS'), findsOneWidget);

      // Verify switch exists and can be tapped
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(controller.forceHttps.value, isFalse);
    });

    testWidgets('WebsiteConfigDomainSecurityCard displays premium banner when free tier', (tester) async {
      dashboardController.planSlug.value = 'free';

      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigDomainSecurityCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Premium Feature'), findsOneWidget);
      expect(find.text('FREE TIER'), findsOneWidget);
      expect(find.text('Upgrade to Premium · €4.99/mo'), findsOneWidget);
    });

    testWidgets('ManageDnsSheet renders DNS records and actions', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ManageDnsSheet(
            controller: controller,
            isDark: false,
            domainEntry: const {
              'domain': 'example.com',
              'verification_token': 'aibuilder-site-verify',
              'ssl_status': {'cname_target': 'sites.aibuilder.app'},
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage DNS & Domain'), findsOneWidget);
      expect(find.text('CNAME'), findsOneWidget);
      expect(find.text('TXT'), findsOneWidget);
      expect(find.text('sites.aibuilder.app'), findsOneWidget);
      expect(find.text('aibuilder-site-verify'), findsOneWidget);
      expect(find.text('Copy Records'), findsOneWidget);
      expect(find.text('Verify DNS'), findsOneWidget);

      final verifyBtn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Verify DNS'),
      );
      expect(
        verifyBtn.style?.backgroundColor?.resolve({}),
        equals(const Color(0xFF7C5CFF)),
      );
    });

    test('sub_premium is translated in all supported locales', () {
      final translations = AppTranslations().keys;
      expect(translations.keys, isNotEmpty);
      for (final locale in translations.keys) {
        final val = translations[locale]?['sub_premium'];
        expect(val, isNotNull, reason: 'Missing sub_premium in $locale');
        expect(val, isNotEmpty, reason: 'Empty sub_premium in $locale');
      }
    });

    testWidgets('WebsiteConfigLandingFilesCard renders import and export options', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigLandingFilesCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Landing page files'), findsOneWidget);
      expect(find.text('Import your own page'), findsOneWidget);
      expect(find.text('portfolio.zip'), findsOneWidget);
      expect(find.text('2.4 MB · Imported 15 Nov 2026'), findsOneWidget);
      expect(find.text('Choose ZIP file'), findsOneWidget);
      expect(find.text('Export Project (ZIP)'), findsOneWidget);
      expect(find.text('Download Project (ZIP)'), findsOneWidget);
      expect(find.text('Copy code to clipboard'), findsOneWidget);
    });

    testWidgets('WebsiteConfigDeleteCard renders delete action and opens confirm dialog', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigDeleteCard(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete landing page'), findsNWidgets(2)); // heading + button
      expect(
        find.text('Permanently delete this page and its files. This cannot be undone.'),
        findsOneWidget,
      );

      // Tap delete button -> opens dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete landing page'));
      await tester.pumpAndSettle();

      expect(find.text('Delete landing page?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('WebsiteConfigSaveBar renders save button and note', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          WebsiteConfigSaveBar(
            controller: controller,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Changes go live after you save.'), findsOneWidget);
    });

    testWidgets('WebsiteConfigScreen renders complete screen with all modular parts', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      controller.isLoading.value = false;

      await tester.pumpWidget(buildTestWidget(const WebsiteConfigScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WebsiteConfigTopNav), findsOneWidget);
      expect(find.byType(WebsiteConfigPageHeader), findsOneWidget);
      expect(find.byType(WebsiteConfigGeneralCard), findsOneWidget);
      expect(find.byType(WebsiteConfigPublishingCard), findsOneWidget);
      expect(find.byType(WebsiteConfigDomainSecurityCard), findsOneWidget);
      expect(find.byType(WebsiteConfigLandingFilesCard), findsOneWidget);
      expect(find.byType(WebsiteConfigDeleteCard), findsOneWidget);
      expect(find.byType(WebsiteConfigSaveBar), findsOneWidget);
    });
  });
}
