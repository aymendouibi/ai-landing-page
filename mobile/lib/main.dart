import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/designsystem/theme.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/supported_locales.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/stripe_service.dart';
import 'core/storage/session_manager.dart';
import 'core/widgets/app_showcase.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      debugPrint('Firebase initialization notice: $e');
    }

    try {
      StripeService.instance.initStripe();
    } catch (e) {
      debugPrint('Stripe initialization notice: $e');
    }
  }

  final isLoggedIn = await SessionManager.isLoggedIn();
  final themeMode = await SessionManager.getThemeMode();
  final locale = await SessionManager.getLocale();

  AppShowcase.register();

  runApp(AiBuilderApp(
    isLoggedIn: isLoggedIn,
    initialThemeMode: themeMode,
    initialLocale: locale,
  ));
}

class AiBuilderApp extends StatelessWidget {
  final bool isLoggedIn;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const AiBuilderApp({
    super.key,
    required this.isLoggedIn,
    this.initialThemeMode = ThemeMode.system,
    this.initialLocale = AppLocales.fallbackLocale,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Website Builder',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? AppRoutes.dashboard : AppRoutes.auth,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: AppLocales.fallbackLocale,
      supportedLocales: AppLocales.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
