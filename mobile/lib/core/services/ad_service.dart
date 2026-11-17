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

  StartAppRewardedVideoAd? _cachedRewardedVideoAd;
  StartAppInterstitialAd? _cachedVideoInterstitialAd;
  bool _isLoadingVideo = false;

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
    if (Get.isRegistered<DashboardController>()) {
      final controller = Get.find<DashboardController>();
      return controller.hasAds.value && !controller.isPremium;
    }
    return true;
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

  /// Preload both interstitial and video ads simultaneously.
  Future<void> preloadAll({String adTag = 'general'}) async {
    if (!shouldShowAds) return;
    init();
    await Future.wait([
      preloadInterstitialAd(adTag: adTag),
      preloadVideoAd(adTag: '${adTag}_video'),
    ]);
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
          _cachedInterstitialAd = null;
        },
        onAdNotDisplayed: () {
          debugPrint('ℹ️ [AD SERVICE]: Interstitial not displayed ($adTag)');
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

  /// Preload a video ad (rewarded video or video interstitial).
  Future<void> preloadVideoAd({String adTag = 'video_general'}) async {
    if (!shouldShowAds || _isLoadingVideo || _cachedRewardedVideoAd != null || _cachedVideoInterstitialAd != null) return;
    init();

    if (_sdk == null) return;
    _isLoadingVideo = true;

    try {
      // 1. Try loading a rewarded video ad
      try {
        final videoAd = await _sdk!.loadRewardedVideoAd(
          prefs: StartAppAdPreferences(adTag: adTag),
          onAdDisplayed: () => debugPrint('ℹ️ [AD SERVICE]: Rewarded video displayed ($adTag)'),
          onAdHidden: () {
            debugPrint('ℹ️ [AD SERVICE]: Rewarded video hidden ($adTag)');
            _cachedRewardedVideoAd = null;
          },
          onAdNotDisplayed: () {
            debugPrint('ℹ️ [AD SERVICE]: Rewarded video not displayed ($adTag)');
            _cachedRewardedVideoAd = null;
          },
          onAdClicked: () => debugPrint('ℹ️ [AD SERVICE]: Rewarded video clicked ($adTag)'),
          onVideoCompleted: () => debugPrint('ℹ️ [AD SERVICE]: Rewarded video completed ($adTag)'),
        );
        _cachedRewardedVideoAd = videoAd;
        return;
      } catch (e) {
        debugPrint('ℹ️ [AD SERVICE]: Rewarded video load fallback: $e');
      }

      // 2. Fallback to interstitial video ad
      final interVideo = await _sdk!.loadInterstitialAd(
        mode: StartAppInterstitialAdMode.video,
        prefs: StartAppAdPreferences(adTag: adTag),
        onAdDisplayed: () => debugPrint('ℹ️ [AD SERVICE]: Video interstitial displayed ($adTag)'),
        onAdHidden: () {
          debugPrint('ℹ️ [AD SERVICE]: Video interstitial hidden ($adTag)');
          _cachedVideoInterstitialAd = null;
        },
        onAdNotDisplayed: () {
          debugPrint('ℹ️ [AD SERVICE]: Video interstitial not displayed ($adTag)');
          _cachedVideoInterstitialAd = null;
        },
        onAdClicked: () => debugPrint('ℹ️ [AD SERVICE]: Video interstitial clicked ($adTag)'),
      );
      _cachedVideoInterstitialAd = interVideo;
    } catch (e) {
      debugPrint('⚠️ [AD SERVICE]: Error preloading video ad: $e');
    } finally {
      _isLoadingVideo = false;
    }
  }

  /// Show a video ad for high-value actions (e.g. creating a new website, publishing).
  /// Falls back to an interstitial ad if video ad is unavailable.
  Future<bool> showVideoAd({
    String adTag = 'video_action',
    VoidCallback? onVideoCompleted,
  }) async {
    if (!shouldShowAds) return false;
    init();

    try {
      // 1. Check cached Rewarded Video
      if (_cachedRewardedVideoAd != null) {
        final ad = _cachedRewardedVideoAd!;
        _cachedRewardedVideoAd = null;
        final shown = await ad.show();
        preloadVideoAd(adTag: adTag);
        return shown;
      }

      // 2. Check cached Video Interstitial
      if (_cachedVideoInterstitialAd != null) {
        final ad = _cachedVideoInterstitialAd!;
        _cachedVideoInterstitialAd = null;
        final shown = await ad.show();
        preloadVideoAd(adTag: adTag);
        return shown;
      }

      // 3. Attempt on-the-fly video ad load
      if (_sdk != null) {
        try {
          final ad = await _sdk!.loadRewardedVideoAd(
            prefs: StartAppAdPreferences(adTag: adTag),
            onVideoCompleted: onVideoCompleted,
          );
          final shown = await ad.show();
          preloadVideoAd(adTag: adTag);
          return shown;
        } catch (_) {
          final interVideo = await _sdk!.loadInterstitialAd(
            mode: StartAppInterstitialAdMode.video,
            prefs: StartAppAdPreferences(adTag: adTag),
          );
          final shown = await interVideo.show();
          preloadVideoAd(adTag: adTag);
          return shown;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [AD SERVICE]: Video ad show failed, falling back to interstitial: $e');
    }

    // 4. Fallback to regular interstitial so user is guaranteed to see an ad
    return showInterstitialAd(adTag: '${adTag}_fallback');
  }

  /// Show an interstitial ad (e.g. after asset uploads, AI proposal apply, project exports).
  /// Strictly shown to free tier users only.
  Future<bool> showInterstitialAd({String adTag = 'action_complete'}) async {
    if (!shouldShowAds) return false;
    init();

    try {
      if (_cachedInterstitialAd != null) {
        final ad = _cachedInterstitialAd!;
        _cachedInterstitialAd = null;
        final shown = await ad.show();
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
