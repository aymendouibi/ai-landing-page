import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/models/website.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';
import 'package:aibuilder/features/dashboard/dashboard_screen.dart';

Widget buildDashboardTestApp() {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('en', 'US'),
    fallbackLocale: const Locale('en', 'US'),
    home: const Scaffold(body: DashboardScreen()),
  );
}

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Dashboard Fresh Account & Real Data Tests', () {
    testWidgets('Fresh account with zero websites displays no mock projects and shows empty state', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = Get.put(DashboardController());
      controller.websites.clear();
      controller.previewItems.clear();
      controller.isLoading.value = false;

      await tester.pumpWidget(buildDashboardTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Confirms NO mock/showcase projects appear
      expect(find.text('Lumen Coffee'), findsNothing);
      expect(find.text('Studio Marlow'), findsNothing);
      expect(find.text('Kite Yoga'), findsNothing);

      // Confirms empty state cards for both Hero and Recent
      expect(find.text('No pages generated yet'), findsOneWidget);
      expect(find.text('Create Page'), findsOneWidget);
      expect(find.text('No recent projects'), findsOneWidget);
      expect(find.text('Websites you create or edit will appear here.'), findsOneWidget);
    });

    testWidgets('Account with real websites displays real project data in hero and recent', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final realWebsite = Website(
        id: 'real-site-1',
        projectId: 'proj-1',
        name: 'Quantum Analytics',
        slug: 'quantum-analytics',
        status: 'published',
        subdomain: 'quantum-analytics',
        revisionNumber: 2,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        document: {
          'pages': [
            {
              'sections': [
                {
                  'type': 'hero',
                  'props': {
                    'headline': 'Next-Gen Analytics for Enterprise',
                    'subheadline': 'Harness AI-driven real-time analytics at scale.',
                    'ctaText': 'Get Started Free',
                  },
                }
              ]
            }
          ],
          'site': {
            'theme': {
              'colors': {
                'primary': '#4F46E5',
              }
            }
          }
        },
      );

      final controller = Get.put(DashboardController());
      controller.websites.assignAll([realWebsite]);
      controller.isLoading.value = false;

      await tester.pumpWidget(buildDashboardTestApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Confirms real project name and headline appear
      expect(find.text('Quantum Analytics'), findsWidgets);
      expect(find.text('Next-Gen Analytics for Enterprise'), findsWidgets);
      expect(find.text('Get Started Free'), findsWidgets);

      // Confirms mock names are absent
      expect(find.text('Lumen Coffee'), findsNothing);
      expect(find.text('Studio Marlow'), findsNothing);
      expect(find.text('Kite Yoga'), findsNothing);
    });
  });
}
