import 'package:flutter/material.dart';

class AppLocaleInfo {
  final String languageCode;
  final String countryCode;
  final String englishName;
  final String nativeName;
  final String flag;
  final bool isRTL;

  const AppLocaleInfo({
    required this.languageCode,
    required this.countryCode,
    required this.englishName,
    required this.nativeName,
    required this.flag,
    this.isRTL = false,
  });

  Locale get locale => Locale(languageCode, countryCode);
  String get key => '${languageCode}_$countryCode';
}

class AppLocales {
  static const fallbackLocale = Locale('en', 'US');

  static const List<AppLocaleInfo> languages = [
    AppLocaleInfo(
      languageCode: 'en',
      countryCode: 'US',
      englishName: 'English',
      nativeName: 'English (US)',
      flag: '🇺🇸',
    ),
    AppLocaleInfo(
      languageCode: 'es',
      countryCode: 'ES',
      englishName: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    AppLocaleInfo(
      languageCode: 'fr',
      countryCode: 'FR',
      englishName: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    AppLocaleInfo(
      languageCode: 'de',
      countryCode: 'DE',
      englishName: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    AppLocaleInfo(
      languageCode: 'ar',
      countryCode: 'SA',
      englishName: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      isRTL: true,
    ),
    AppLocaleInfo(
      languageCode: 'zh',
      countryCode: 'CN',
      englishName: 'Chinese (Simplified)',
      nativeName: '简体中文',
      flag: '🇨🇳',
    ),
    AppLocaleInfo(
      languageCode: 'ja',
      countryCode: 'JP',
      englishName: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
    ),
    AppLocaleInfo(
      languageCode: 'pt',
      countryCode: 'BR',
      englishName: 'Portuguese (Brazil)',
      nativeName: 'Português',
      flag: '🇧🇷',
    ),
  ];

  static List<Locale> get supportedLocales =>
      languages.map((l) => l.locale).toList();

  static AppLocaleInfo fromLocale(Locale? locale) {
    if (locale == null) return languages.first;
    return languages.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => languages.first,
    );
  }
}
