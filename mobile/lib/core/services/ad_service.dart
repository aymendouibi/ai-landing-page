import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:startapp_sdk/startapp.dart';
import '../../features/dashboard/dashboard_controller.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  StartAppSdk? _sdk;
  bool _initialized = false;
  StartAppInterstitialAd? _cachedInterstitialAd;
  bool _isLoadingInterstitial = false;

  /// Whether ads are supported on this platform and runtime environment.
  static bool get isSupported {
    if (kIsWeb) return false;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Whether ads should be displayed for the current user.
  /// Strictly for FREE users only (hasAds == true and not pro).
  static bool get shouldShowAds {
    if (!isSupported) return false;
    if (!Get.isRegistered<DashboardController>()) return false;
    final controller = Get.find<DashboardController>();
    return controller.hasAds.value && !controller.isPremium;
  }

  /// Initialize the Start.io SDK if running on supported platform and user is free.
  void init() {
    if (!isSupported || _initialized) return;

    try {
      _sdk = StartAppSdk();
      if (kDebugMode) {
        _sdk?.setTestAdsEnabled(true);
        debugPrint('ℹ️ [AD SERVICE]: Start.io test ads enabled.');
      }
      _initialized = true;
      debugPrint('✅ [AD SERVICE]: Start.io SDK initialized.');
    } catch (e) {
      debugPrint('⚠️ [AD SERVICE]: Failed to initialize Start.io SDK: $e');
    }
  }

  /// Load a Start.io banner ad safely.
  Future<StartAppBannerAd?> loadBannerAd({
    StartAppBannerType type = StartAppBannerType.BANNER,
    String adTag = 'dashboard_banner',
  }) async {
    if (!shouldShowAds) return null;
    init();

    if (_sdk == null) return null;

    try {
      final bannerAd = await _sdk!.loadBannerAd(
        type,
        prefs: StartAppAdPreferences(adTag: adTag),
        onAdImpression: () => debugPrint('ℹ️ [AD SERVICE]: Banner impression ($adTag)'),
        onAdClicked: () => debugPrint('ℹ️ [AD SERVICE]: Banner clicked ($adTag)'),
      );
      return bannerAd;
    } on StartAppException catch (e) {
      debugPrint('⚠️ [AD SERVICE]: StartAppException loading banner: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('⚠️ [AD SERVICE]: Error loading banner ad: $e');
      return null;
    }
  }

  /// Preload an interstitial ad so it displays instantly when triggered.
  Future<void> preloadInterstitialAd({String adTag = 'general'}) async {
    if (!shouldShowAds || _isLoadingInterstitial || _cachedInterstitialAd != null) return;
    init();

    if (_sdk == null) return;
    _isLoadingInterstitial = true;

    try {
      final ad = await _sdk!.loadInterstitialAd(
        prefs: StartAppAdPreferences(adTag: adTag),
        onAdDisplayed: () => debugPrint('ℹ️ [AD SERVICE]: Interstitial displayed ($adTag)'),
        onAdHidden: () {
          debugPrint('ℹ️ [AD SERVICE]: Interstitial hidden ($adTag)');
          _cachedInterstitialAd?.dispose();
          _cachedInterstitialAd = null;
        },
        onAdNotDisplayed: () {
          debugPrint('ℹ️ [AD SERVICE]: Interstitial not displayed ($adTag)');
          _cachedInterstitialAd?.dispose();
          _cachedInterstitialAd = null;
        },
        onAdClicked: () => debugPrint('ℹ️ [AD SERVICE]: Interstitial clicked ($adTag)'),
      );
      _cachedInterstitialAd = ad;
    } catch (e) {
      debugPrint('⚠️ [AD SERVICE]: Error preloading interstitial ad: $e');
    } finally {
      _isLoadingInterstitial = false;
    }
  }

  /// Show an interstitial ad (e.g. after AI site generation or project export).
  /// Strictly shown to free tier users only.
  Future<bool> showInterstitialAd({String adTag = 'action_complete'}) async {
    if (!shouldShowAds) return false;
    init();

    try {
      if (_cachedInterstitialAd != null) {
        final shown = await _cachedInterstitialAd!.show();
        _cachedInterstitialAd = null;
        preloadInterstitialAd(adTag: adTag);
        return shown;
      }

      // If no preloaded ad, load and show on the fly
      final ad = await _sdk?.loadInterstitialAd(
        prefs: StartAppAdPreferences(adTag: adTag),
      );
      if (ad != null) {
        final shown = await ad.show();
        preloadInterstitialAd(adTag: adTag);
        return shown;
      }
    } catch (e) {
      debugPrint('⚠️ [AD SERVICE]: Failed to show interstitial: $e');
    }
    return false;
  }
}
