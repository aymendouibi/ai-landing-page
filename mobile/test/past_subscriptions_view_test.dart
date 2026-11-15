import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';
import 'package:aibuilder/features/subscription/past_subscriptions_view.dart';
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

  late DashboardController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    controller = DashboardController();
    Get.put<DashboardController>(controller);
    controller.planSlug.value = 'pro';
    controller.subscriptionPeriodEnd.value = '31 Dec 2026';
  });

  tearDown(() {
    Get.reset();
  });

  group('PastSubscriptionsView and Modular Widgets Tests', () {
    final sampleItemActive = {
      'title': 'Premium · Monthly',
      'plan': 'Premium',
      'interval': 'monthly',
      'amount': '4.99',
      'formatted_amount': '€4.99',
      'date': '1 Nov – 1 Dec 2026',
      'time': '14:32',
      'status': 'Active',
      'provider': 'stripe',
      'reference': 'sub_test_123456',
    };

    final sampleItemExpired = {
      'title': 'Premium · Yearly',
      'plan': 'Premium',
      'interval': 'yearly',
      'amount': '49.99',
      'formatted_amount': '€49.99',
      'date': '1 Nov 2024 – 1 Nov 2025',
      'time': '10:15',
      'status': 'Expired',
      'provider': 'stripe',
      'reference': 'sub_test_654321',
    };

    test('PastSubscriptionHelper formats items and groups by year correctly', () {
      expect(
        PastSubscriptionHelper.getItemTitle(sampleItemActive),
        equals('Premium · Monthly'),
      );
      expect(
        PastSubscriptionHelper.getItemTitle({'plan': 'Pro', 'interval': 'yearly'}),
        equals('Pro · Yearly'),
      );
      expect(
        PastSubscriptionHelper.getItemDate(sampleItemActive),
        equals('1 Nov – 1 Dec 2026'),
      );
      expect(
        PastSubscriptionHelper.getItemTime(sampleItemActive),
        equals('14:32'),
      );
      expect(
        PastSubscriptionHelper.getItemYear(sampleItemActive),
        equals('2026'),
      );
      expect(
        PastSubscriptionHelper.getItemYear(sampleItemExpired),
        equals('2024'),
      );

      final grouped = PastSubscriptionHelper.groupByYear([
        sampleItemActive,
        sampleItemExpired,
      ]);
      expect(grouped.containsKey('2026'), isTrue);
      expect(grouped.containsKey('2024'), isTrue);
      expect(grouped['2026']!.length, equals(1));
    });

    testWidgets('PastCurrentPlanCard renders Active Premium info when Pro', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PastCurrentPlanCard(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your current plan'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Active Premium subscription until 31 Dec 2026.'), findsOneWidget);
    });

    testWidgets('PastCurrentPlanCard renders Free info when on Free tier', (tester) async {
      controller.planSlug.value = 'free';

      await tester.pumpWidget(
        buildTestWidget(
          PastCurrentPlanCard(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your current plan'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('No active subscription. No upcoming charges.'), findsOneWidget);
    });

    testWidgets('PastSubscriptionItemCard renders details and triggers tap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          PastSubscriptionItemCard(
            item: sampleItemActive,
            isDark: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Premium · Monthly'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('1 Nov – 1 Dec 2026'), findsOneWidget);
      expect(find.text('14:32'), findsOneWidget);
      expect(find.text('€4.99'), findsOneWidget);
      expect(find.text('View receipt'), findsOneWidget);
      expect(find.byIcon(LucideIcons.clock), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('ReceiptDetailsSheet renders all breakdown fields and can close', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ReceiptDetailsSheet(item: sampleItemActive),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Receipt Details'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Billing cycle'), findsOneWidget);
      expect(find.text('Period'), findsOneWidget);
      expect(find.text('Payment time'), findsOneWidget);
      expect(find.text('Payment processor'), findsOneWidget);
      expect(find.text('STRIPE'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Total amount paid'), findsOneWidget);
      expect(find.text('€4.99'), findsOneWidget);
      expect(find.text('sub_test_123456'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('PastSubscriptionsHeader renders title, subtitle, and back button', (tester) async {
      var backTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          PastSubscriptionsHeader(
            onBack: () => backTapped = true,
            isDark: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Past subscriptions'), findsOneWidget);
      expect(find.text('View your previous plans and billing periods.'), findsOneWidget);
      final backBtn = find.byKey(const Key('past_subscriptions_back_button'));
      expect(backBtn, findsOneWidget);

      await tester.tap(backBtn);
      await tester.pumpAndSettle();
      expect(backTapped, isTrue);
    });

    testWidgets('PastSubscriptionsPromoCard renders explore button', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const PastSubscriptionsPromoCard(isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ready to create more?'), findsOneWidget);
      expect(find.text('Explore Premium'), findsOneWidget);
    });

    testWidgets('PastSubscriptionsView renders complete page with back button and structure', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(const PastSubscriptionsView()));
      await tester.pumpAndSettle();

      expect(find.text('Past subscriptions'), findsOneWidget);
      expect(find.byKey(const Key('past_subscriptions_back_button')), findsOneWidget);
      expect(find.byType(PastSubscriptionsHeader), findsOneWidget);
      expect(find.text('View your previous plans and billing periods.'), findsOneWidget);
      expect(find.byType(PastCurrentPlanCard), findsOneWidget);
      expect(find.byType(PastSubscriptionsPromoCard), findsOneWidget);
      expect(find.text('Past plans won’t renew automatically.'), findsOneWidget);
    });
  });
}
