import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/models/website.dart';
import 'package:aibuilder/features/editor/editor_controller.dart';
import 'package:aibuilder/features/dashboard/components/recent_project_card.dart';
import 'package:aibuilder/features/dashboard/components/continue_editing_hero_card.dart';
import 'package:aibuilder/features/website_config/website_config_controller.dart';
import 'package:aibuilder/features/website_config/widgets/website_config_publishing_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget buildTestApp(Widget child) {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('en', 'US'),
    fallbackLocale: const Locale('en', 'US'),
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Site Link & Mobile App Display Tests', () {
    test('EditorController.rendererUrl points to production renderer with ?editor=true', () {
      expect(
        EditorController.rendererUrl,
        'https://www.ai-landing-page.xyz/?editor=true',
      );
    });

    testWidgets('RecentProjectCard displays live website URL and copy button when published', (tester) async {
      const liveItem = WebsitePreviewItem(
        id: 'site-123',
        title: 'Lumen Specialty Coffee',
        category: 'Food & Beverage',
        headline: 'Good coffee. Better mornings.',
        body: 'Single-origin beans roasted in small batches.',
        ctaText: 'Explore',
        ctaColor: Color(0xFF9E4B28),
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd',
        isLive: true,
        domain: 'www.ai-landing-page.xyz/sites/lumen-specialty',
      );

      await tester.pumpWidget(
        buildTestApp(
          RecentProjectCard(
            item: liveItem,
            onClick: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Confirms title and live status
      expect(find.text('Lumen Specialty Coffee'), findsWidgets);
      expect(find.text('Live'), findsOneWidget);

      // Confirms live site URL is visible
      expect(find.text('www.ai-landing-page.xyz/sites/lumen-specialty'), findsOneWidget);

      // Confirms copy icon is present
      expect(find.byIcon(LucideIcons.copy), findsOneWidget);

      // Tap on the copy link and drain snackbar timer
      await tester.tap(find.text('www.ai-landing-page.xyz/sites/lumen-specialty'));
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('WebsiteConfigPublishingCard renders copyable live site link container', (tester) async {
      final controller = WebsiteConfigController();
      controller.subdomain.value = 'lumen-specialty';
      controller.liveUrl.value = 'https://www.ai-landing-page.xyz/sites/lumen-specialty';
      controller.status.value = 'published';

      await tester.pumpWidget(
        buildTestApp(
          WebsiteConfigPublishingCard(
            controller: controller,
            isDark: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Confirms the live link is rendered in the copyable container
      expect(find.text('https://www.ai-landing-page.xyz/sites/lumen-specialty'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.byIcon(LucideIcons.globe), findsOneWidget);

      // Tap Copy button and drain snackbar timer
      await tester.tap(find.text('Copy'));
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('ContinueEditingHeroCard displays live link and copy action when published', (tester) async {
      final publishedSite = Website(
        id: 'hero-site-1',
        projectId: 'proj-1',
        name: 'Lumen Coffee',
        slug: 'lumen-coffee',
        status: 'published',
        subdomain: 'lumen-coffee',
        revisionNumber: 1,
      );

      await tester.pumpWidget(
        buildTestApp(
          ContinueEditingHeroCard(
            website: publishedSite,
            onOpenClick: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify site title and live status
      expect(find.text('Lumen Coffee'), findsWidgets);
      expect(find.text('Live · Published recently'), findsOneWidget);

      // Verify live domain and globe icon
      expect(find.text('www.ai-landing-page.xyz/sites/lumen-coffee'), findsOneWidget);
      expect(find.byIcon(LucideIcons.globe), findsOneWidget);

      // Tap on the copy link and drain snackbar timer
      await tester.tap(find.text('www.ai-landing-page.xyz/sites/lumen-coffee'));
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
