import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _themeModeKey = 'app_theme_mode';
  static const _localeKey = 'app_locale';
  static const _dashboardShowcaseKey = 'has_seen_dashboard_showcase';
  static const _editorShowcaseKey = 'has_seen_editor_showcase';

  static Future<void> saveSession({
    required String token,
    required String userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String> getUserInitials() async {
    final name = await getUserName();
    if (name == null || name.trim().isEmpty) return 'MR';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static Future<void> saveProfile({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeModeKey);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode ?? ''}');
  }

  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_localeKey);
    if (str == null || str.isEmpty) {
      return const Locale('en', 'US');
    }
    final parts = str.split('_');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  static Future<bool> hasSeenDashboardShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dashboardShowcaseKey) ?? false;
  }

  static Future<void> setDashboardShowcaseSeen([bool seen = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dashboardShowcaseKey, seen);
  }

  static Future<bool> hasSeenEditorShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_editorShowcaseKey) ?? false;
  }

  static Future<void> setEditorShowcaseSeen([bool seen = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_editorShowcaseKey, seen);
  }

  static Future<void> resetShowcases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dashboardShowcaseKey);
    await prefs.remove(_editorShowcaseKey);
  }

  static const _keyDeletedWebsites = 'deleted_website_ids';
  static const _recentOpenedWebsitesKey = 'recent_opened_website_ids';

  static Future<List<String>> getRecentOpenedWebsiteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentOpenedWebsitesKey) ?? [];
  }

  static Future<void> recordRecentWebsite(String id) async {
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentOpenedWebsitesKey) ?? [];
    list.remove(id);
    list.insert(0, id);
    if (list.length > 30) {
      list.removeRange(30, list.length);
    }
    await prefs.setStringList(_recentOpenedWebsitesKey, list);
  }

  static Future<void> clearRecentWebsites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentOpenedWebsitesKey);
  }

  static Future<Set<String>> getDeletedWebsiteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyDeletedWebsites) ?? [];
    return list.toSet();
  }

  static Future<void> markWebsiteDeleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_keyDeletedWebsites) ?? []).toSet();
    set.add(id);
    await prefs.setStringList(_keyDeletedWebsites, set.toList());
  }

  static Future<void> clearDeletedWebsites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeletedWebsites);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_keyDeletedWebsites);
    await prefs.remove(_recentOpenedWebsitesKey);
  }
}
