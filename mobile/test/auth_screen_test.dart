import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/services/social_auth_service.dart';
import 'package:aibuilder/features/auth/auth_screen.dart';

void main() {
  setUp(() {
    Get.reset();
    SocialAuthService.mockAppleSignInSupported = null;
  });

  tearDown(() {
    Get.reset();
    SocialAuthService.mockAppleSignInSupported = null;
  });

  testWidgets('AuthScreen renders login layout matching design mockup', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SocialAuthService.mockAppleSignInSupported = true;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Overline, Title, Subtitle
    expect(find.text('AI LANDING PAGE'), findsOneWidget);
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('Sign in to bring your next idea to life.'), findsOneWidget);

    // Form Labels
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);

    // Primary Button & Divider
    expect(find.text('Log in'), findsWidgets);
    expect(find.text('or continue with'), findsOneWidget);

    // Social Buttons
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.byIcon(Icons.apple), findsOneWidget);

    // Footer
    expect(find.text('By continuing, you agree to our'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('AuthScreen toggles to Register mode and shows Full Name field', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SocialAuthService.mockAppleSignInSupported = true;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on "Create an account"
    final toggleFinder = find.byKey(const Key('auth_mode_toggle'));
    await tester.ensureVisible(toggleFinder);
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    // Title should change
    expect(find.text('Create account.'), findsWidgets);
    expect(find.text('Sign up to bring your next idea to life.'), findsOneWidget);

    // Full name field should now appear
    expect(find.text('Full name'), findsOneWidget);

    // Forgot password should not appear in register mode
    expect(find.text('Forgot password?'), findsNothing);
  });

  testWidgets('AuthScreen hides Apple button when not supported', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SocialAuthService.mockAppleSignInSupported = false;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue with Apple'), findsNothing);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('AuthScreen terms button opens TermsOfServiceSheet on tap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final termsBtn = find.byKey(const Key('auth_terms_button'));
    expect(termsBtn, findsOneWidget);
    await tester.tap(termsBtn);
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);
  });

  testWidgets('AuthScreen privacy button opens PrivacyPolicySheet on tap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final privacyBtn = find.byKey(const Key('auth_privacy_button'));
    expect(privacyBtn, findsOneWidget);
    await tester.tap(privacyBtn);
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('1. Information We Collect'), findsOneWidget);
  });

  testWidgets('AuthScreen renders correctly in dark theme (Login mode)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SocialAuthService.mockAppleSignInSupported = true;

    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData.dark(),
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify dark Scaffold
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF090D16));

    // Verify content rendered in dark theme
    expect(find.text('AI LANDING PAGE'), findsOneWidget);
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('Sign in to bring your next idea to life.'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });

  testWidgets('AuthScreen renders correctly in dark theme (Register mode)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData.dark(),
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on "Create an account"
    final toggleFinder = find.byKey(const Key('auth_mode_toggle'));
    await tester.ensureVisible(toggleFinder);
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    // Title should change
    expect(find.text('Create account.'), findsWidgets);
    expect(find.text('Sign up to bring your next idea to life.'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF090D16));
  });
}
