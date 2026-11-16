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

  testWidgets('AuthScreen renders Google and Apple sign-in options correctly', (
    WidgetTester tester,
  ) async {
    SocialAuthService.mockAppleSignInSupported = true;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Header & Fields
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Or continue with'), findsOneWidget);

    // Social sign-in buttons
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // Apple Icon
    expect(find.byIcon(Icons.apple), findsOneWidget);
  });

  testWidgets('AuthScreen hides Apple button when not supported', (
    WidgetTester tester,
  ) async {
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
}
