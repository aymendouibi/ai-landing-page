import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';
import 'package:aibuilder/features/profile/profile_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget buildTestWidget(Widget child) {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('en', 'US'),
    getPages: [
      GetPage(name: '/auth', page: () => const SizedBox()),
    ],
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
    controller.userName.value = 'Morgan Reed';
    controller.userEmail.value = 'morgan.reed@gmail.com';
    controller.userInitials.value = 'MR';
    controller.planSlug.value = 'free';
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileView and Modular Profile Widgets Tests', () {
    testWidgets('ProfileView renders all modular sections correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(const ProfileView()));
      await tester.pumpAndSettle();

      // Verify title & version
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(ProfileUserCard), findsOneWidget);
      expect(find.byType(ProfileSubscriptionCard), findsOneWidget);
      expect(find.byType(ProfilePreferencesCard), findsOneWidget);
      expect(find.byType(ProfileSupportCard), findsOneWidget);
      expect(find.byType(ProfilePrivacyCard), findsOneWidget);
      expect(find.byType(ProfileSectionTitle), findsNWidgets(3));
    });

    testWidgets('ProfileUserCard renders user details and Free/Premium badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProfileUserCard(controller: controller, isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Morgan Reed'), findsOneWidget);
      expect(find.text('morgan.reed@gmail.com'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);

      // Now switch to Premium
      controller.planSlug.value = 'pro';
      await tester.pumpAndSettle();

      expect(find.text('PREMIUM MEMBER'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
    });

    testWidgets('ProfileSubscriptionCard renders promotional view on Free tier', (tester) async {
      controller.planSlug.value = 'free';
      await tester.pumpWidget(
        buildTestWidget(
          ProfileSubscriptionCard(controller: controller, isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('€4.99'), findsOneWidget);
      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(find.text('Past subscriptions & receipts'), findsOneWidget);
      expect(find.text('60 landing page generations'), findsOneWidget);
    });

    testWidgets('ProfileSubscriptionCard renders active view on Premium tier', (tester) async {
      controller.planSlug.value = 'pro';
      controller.subscriptionPeriodEnd.value = '31 Dec 2026';

      await tester.pumpWidget(
        buildTestWidget(
          ProfileSubscriptionCard(controller: controller, isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('€4.99 / month'), findsOneWidget);
      expect(find.text('Your Premium membership is active until 31 Dec 2026.'), findsOneWidget);
      expect(find.text('Manage subscription'), findsOneWidget);
    });

    testWidgets('ProfilePreferencesCard toggles theme mode switch', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProfilePreferencesCard(controller: controller, isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Dark theme'), findsOneWidget);

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(controller.themeMode.value, equals(ThemeMode.dark));
    });

    testWidgets('ProfileSupportCard renders Help Guide and Send Feedback', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileSupportCard(isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Help & prompt guide'), findsOneWidget);
      expect(find.text('Send feedback'), findsOneWidget);
    });

    testWidgets('ProfilePrivacyCard renders legal rows and opens sign out dialog', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ProfilePrivacyCard(controller: controller, isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Terms of service'), findsOneWidget);
      expect(find.text('Billing history'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      // Tap Sign out
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Sign out dialog should appear
      expect(find.text('Are you sure you want to sign out of your account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to sign out of your account?'), findsNothing);
    });

    testWidgets('ProfileIconBadge renders with custom icon and colors', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileIconBadge(
            icon: LucideIcons.star,
            isDark: false,
            accentColor: Colors.amber,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.star), findsOneWidget);
    });

    testWidgets('ProfileSectionTitle renders title text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileSectionTitle(title: 'Account Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
    });

    testWidgets('ProfileSignOutDialog executes logout when confirmed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ProfileSignOutDialog.show(ctx, controller),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to sign out of your account?'), findsOneWidget);

      // Confirm sign out (tap second Sign out button which is in the dialog actions)
      final signOutButtons = find.text('Sign out');
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.text('Are you sure you want to sign out of your account?'), findsNothing);
    });
  });
}
