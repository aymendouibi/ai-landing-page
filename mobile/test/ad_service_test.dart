import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/core/services/ad_service.dart';
import 'package:aibuilder/core/widgets/ad_banner_widget.dart';
import 'package:aibuilder/features/dashboard/dashboard_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('AdService is disabled in test environment', () {
    expect(AdService.isSupported, isFalse);
    expect(AdService.shouldShowAds, isFalse);
  });

  testWidgets('AdBannerWidget hides when user has no ads (Pro user)', (
    WidgetTester tester,
  ) async {
    final controller = DashboardController();
    Get.put(controller);
    controller.hasAds.value = false;
    controller.planSlug.value = 'pro';

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const Scaffold(
          body: AdBannerWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AdBannerWidget), findsOneWidget);
    expect(find.text('AD · SPONSORED'), findsNothing);
  });

  testWidgets('AdBannerWidget displays sponsored banner when user is free tier', (
    WidgetTester tester,
  ) async {
    final controller = DashboardController();
    Get.put(controller);
    controller.hasAds.value = true;
    controller.planSlug.value = 'free';

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const Scaffold(
          body: AdBannerWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SPONSORED'), findsOneWidget);
    expect(find.text('No Ads'), findsOneWidget);
  });

  test('AdService methods execute safely without throwing in test environment', () async {
    expect(await AdService.instance.showVideoAd(adTag: 'test_create_website'), isFalse);
    expect(await AdService.instance.showInterstitialAd(adTag: 'test_action'), isFalse);
    expect(() => AdService.instance.preloadVideoAd(adTag: 'test_video'), returnsNormally);
    expect(() => AdService.instance.preloadInterstitialAd(adTag: 'test_interstitial'), returnsNormally);
    expect(() => AdService.instance.preloadAll(adTag: 'test_all'), returnsNormally);
  });
}
