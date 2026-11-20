import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';
import 'package:aibuilder/features/templates/templates_controller.dart';
import 'package:aibuilder/features/templates/templates_view.dart';
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

  late TemplatesController templatesController;
  late DashboardController dashboardController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    dashboardController = DashboardController();
    Get.put<DashboardController>(dashboardController);

    templatesController = TemplatesController();
    templatesController.isLoading.value = false;
    Get.put<TemplatesController>(templatesController);
  });

  tearDown(() {
    Get.reset();
  });

  group('TemplatesView and Modular Widgets Tests', () {
    final sampleTemplate = {
      'id': 'template_lumen_coffee',
      'name': 'Lumen Coffee',
      'industry': 'Food & drink',
      'badge': "EDITOR'S PICK",
      'headline': 'Good coffee.\nBetter mornings.',
      'description': 'Warm minimalist roastery with subscription-ready structure.',
      'ctaText': 'Explore our coffee',
      'primaryColor': '#B85028',
      'bgColor': '#FAF7F2',
      'category': 'Business',
      'is_pro': false,
    };

    final sampleProTemplate = {
      'id': 'template_studio_marlow',
      'name': 'Studio Marlow',
      'industry': 'Design & architecture',
      'badge': 'QUIETLY BOLD',
      'headline': 'Architecture that endures.',
      'description': 'Editorial portfolio for modern studios.',
      'ctaText': 'View projects',
      'primaryColor': '#18181B',
      'bgColor': '#FAF8F5',
      'category': 'Creative',
      'is_pro': true,
    };

    testWidgets('TemplatesCategoryTabs translation helper returns translated tab strings', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SizedBox()));
      expect(TemplatesCategoryTabs.getTabTranslation('For you'), equals('For you'));
      expect(TemplatesCategoryTabs.getTabTranslation('Startups'), equals('Startups'));
      expect(TemplatesCategoryTabs.getTabTranslation('Business'), equals('Business'));
      expect(TemplatesCategoryTabs.getTabTranslation('Weddings'), equals('Weddings'));
      expect(TemplatesCategoryTabs.getTabTranslation('Creative'), equals('Creative'));
      expect(TemplatesCategoryTabs.getTabTranslation('Personal'), equals('Personal'));
      expect(TemplatesCategoryTabs.getTabTranslation('Community'), equals('Community'));
      expect(TemplatesCategoryTabs.getTabTranslation('Other'), equals('Other'));
    });

    testWidgets('TemplatesHeader renders titles, headline, subtitle, and avatar pill', (tester) async {
      var avatarTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          TemplatesHeader(
            isDark: false,
            onAvatarTap: () => avatarTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Templates'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
      expect(find.text('Your next idea, beautifully started.'), findsOneWidget);
      expect(
        find.text('Distinctive designs. Ready to make your own.'),
        findsOneWidget,
      );

      await tester.tap(find.text('MR'));
      await tester.pumpAndSettle();

      expect(avatarTapped, isTrue);
    });

    testWidgets('TemplatesSearchBar handles input and clear query', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          TemplatesSearchBar(
            controller: templatesController,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      expect(find.text('Find your starting point.'), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pumpAndSettle();

      expect(templatesController.searchQuery.value, equals('Coffee'));
      expect(find.byIcon(LucideIcons.x), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();

      expect(templatesController.searchQuery.value, isEmpty);
      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets('TemplatesCategoryTabs switches active tab on tap', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          TemplatesCategoryTabs(
            controller: templatesController,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('For you'), findsOneWidget);
      expect(find.text('Startups'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Weddings'), findsOneWidget);
      expect(find.text('Creative'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);

      await tester.tap(find.text('Weddings'));
      await tester.pumpAndSettle();

      expect(templatesController.activeTab.value, equals('Weddings'));

      await tester.tap(find.text('Startups'));
      await tester.pumpAndSettle();

      expect(templatesController.activeTab.value, equals('Startups'));
    });

    testWidgets('TemplatesController filters templates accurately across all requested categories', (tester) async {
      final templates = TemplatesController.fallbackTemplates;
      templatesController.templates.assignAll(templates);

      // 1. Weddings tab
      templatesController.setTab('Weddings');
      final weddingTemplates = templatesController.filteredTemplates;
      expect(weddingTemplates, isNotEmpty);
      expect(weddingTemplates.any((t) => t['name'] == 'Ana & Teo'), isTrue);
      expect(weddingTemplates.any((t) => t['name'] == 'Elysian Vows'), isFalse);
      expect(weddingTemplates.any((t) => t['name'] == 'Botanical Romance'), isFalse);

      // 2. Startups tab
      templatesController.setTab('Startups');
      final startupTemplates = templatesController.filteredTemplates;
      expect(startupTemplates, isNotEmpty);
      expect(startupTemplates.any((t) => t['name'] == 'Nexus AI'), isTrue);
      expect(startupTemplates.any((t) => t['name'] == 'DevFlow Cloud'), isTrue);
      expect(startupTemplates.any((t) => t['name'] == 'Pulse Health AI'), isTrue);
      expect(startupTemplates.any((t) => t['name'] == 'VaultPay'), isTrue);
      expect(startupTemplates.any((t) => t['name'] == 'Ora Mindful'), isTrue);

      // 3. Personal tab
      templatesController.setTab('Personal');
      final personalTemplates = templatesController.filteredTemplates;
      expect(personalTemplates, isNotEmpty);
      expect(personalTemplates.any((t) => t['name'] == 'Dr. Marcus Vance'), isTrue);
      expect(personalTemplates.any((t) => t['name'] == 'Elena Rostova'), isFalse);
      expect(personalTemplates.any((t) => t['name'] == 'Kai Thorne'), isTrue);
      expect(personalTemplates.any((t) => t['name'] == 'Kite Yoga'), isTrue);

      // 4. Business tab
      templatesController.setTab('Business');
      final businessTemplates = templatesController.filteredTemplates;
      expect(businessTemplates, isNotEmpty);
      expect(businessTemplates.any((t) => t['name'] == 'Apex Capital Partners'), isTrue);
      expect(businessTemplates.any((t) => t['name'] == 'Nordic Craft Roasters'), isFalse);
      expect(businessTemplates.any((t) => t['name'] == 'Lumen Coffee'), isTrue);
      expect(businessTemplates.any((t) => t['name'] == 'Aura Botanicals'), isTrue);
      expect(businessTemplates.any((t) => t['name'] == 'Solstice Fine Dining'), isTrue);
      expect(businessTemplates.any((t) => t['name'] == 'Terrain Outdoors'), isTrue);
      expect(businessTemplates.any((t) => t['name'] == 'Noor Atelier'), isTrue);
      expect(businessTemplates.any((t) => t['name'] == 'Vela Sailing Co.'), isTrue);

      // 5. Creative tab
      templatesController.setTab('Creative');
      final creativeTemplates = templatesController.filteredTemplates;
      expect(creativeTemplates, isNotEmpty);
      expect(creativeTemplates.any((t) => t['name'] == 'Studio Marlow'), isTrue);
      expect(creativeTemplates.any((t) => t['name'] == 'Mono Studio'), isTrue);
      expect(creativeTemplates.any((t) => t['name'] == 'Lumière Cinema'), isTrue);
    });

    testWidgets('TemplatesSectionHeader renders curated edit title and count text', (tester) async {
      templatesController.templates.assignAll([sampleTemplate, sampleProTemplate]);

      await tester.pumpWidget(
        buildTestWidget(
          TemplatesSectionHeader(
            controller: templatesController,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The curated edit'), findsOneWidget);
      expect(find.text('2 designs to make yours'), findsOneWidget);
    });

    testWidgets('TemplatesEmptyState renders layout grid icon and no search results message', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TemplatesEmptyState(isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.layoutGrid), findsOneWidget);
      expect(find.text('No templates match your search.'), findsOneWidget);
    });

    testWidgets('TemplatesFooterQuote renders quote text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TemplatesFooterQuote(isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('A beautiful starting point. An entirely yours finish.'),
        findsOneWidget,
      );
    });

    testWidgets('TemplateCard renders template details, headline, CTA button, and Preview trigger', (tester) async {
      var previewTapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          TemplateCard(
            template: sampleTemplate,
            isLocked: false,
            onPreview: () => previewTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("EDITOR'S PICK"), findsOneWidget);
      expect(find.text('Lumen Coffee'), findsWidgets);
      expect(find.text('Good coffee.\nBetter mornings.'), findsOneWidget);
      expect(find.text('Explore our coffee'), findsOneWidget);
      expect(find.text('Food & drink'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(
        find.text('Warm minimalist roastery with subscription-ready structure.'),
        findsOneWidget,
      );

      // Tap Preview button
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(previewTapped, isTrue);
    });

    testWidgets('TemplateCard displays PRO lock badge when isLocked is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          TemplateCard(
            template: sampleProTemplate,
            isLocked: true,
            onPreview: () {},
            onUse: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsOneWidget);
    });

    testWidgets('TemplatesView renders complete view with all modular parts', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      templatesController.isLoading.value = false;
      templatesController.templates.assignAll([sampleTemplate, sampleProTemplate]);

      await tester.pumpWidget(buildTestWidget(const TemplatesView()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TemplatesHeader), findsOneWidget);
      expect(find.byType(TemplatesSearchBar), findsOneWidget);
      expect(find.byType(TemplatesCategoryTabs), findsOneWidget);
      expect(find.byType(TemplatesSectionHeader), findsOneWidget);
      expect(find.byType(TemplateCard), findsWidgets);
      expect(find.byType(TemplatesFooterQuote), findsOneWidget);
    });
  });
}
