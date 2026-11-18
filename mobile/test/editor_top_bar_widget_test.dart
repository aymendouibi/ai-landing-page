import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/features/editor/editor_controller.dart';
import 'package:aibuilder/features/editor/widgets/editor_top_bar.dart';

Widget buildTestApp(Widget child, {Locale locale = const Locale('en', 'US')}) {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: locale,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EditorController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    controller = EditorController();
    controller.websiteName.value = 'My Awesome Coffee Shop';
    Get.put<EditorController>(controller);
  });

  testWidgets('EditorTopBar renders without overflow on 360 width', (tester) async {
    FlutterErrorDetails? caughtDetails;
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      caughtDetails = details;
    };

    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(buildTestApp(EditorTopBar(controller: controller)));
    await tester.pumpAndSettle();

    FlutterError.onError = oldHandler;
    tester.view.resetPhysicalSize();

    expect(caughtDetails, isNull);
  });

  testWidgets('EditorLandscapeTopBar renders without overflow on 667 width', (tester) async {
    FlutterErrorDetails? caughtDetails;
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      caughtDetails = details;
    };

    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(buildTestApp(EditorLandscapeTopBar(controller: controller)));
    await tester.pumpAndSettle();

    FlutterError.onError = oldHandler;
    tester.view.resetPhysicalSize();

    expect(caughtDetails, isNull);
  });

  testWidgets('EditorTopBar renders without overflow on ultra-narrow 320 width', (tester) async {
    FlutterErrorDetails? caughtDetails;
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      caughtDetails = details;
    };

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(buildTestApp(EditorTopBar(controller: controller)));
    await tester.pumpAndSettle();

    FlutterError.onError = oldHandler;
    tester.view.resetPhysicalSize();

    expect(caughtDetails, isNull);
  });

  testWidgets('EditorTopBar renders without overflow across multiple locales (de, fr, es, pt)', (tester) async {
    for (final loc in [
      const Locale('de', 'DE'),
      const Locale('fr', 'FR'),
      const Locale('es', 'ES'),
      const Locale('pt', 'BR'),
    ]) {
      FlutterErrorDetails? caughtDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };

      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestApp(EditorTopBar(controller: controller), locale: loc));
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;
      tester.view.resetPhysicalSize();

      expect(caughtDetails, isNull, reason: 'Failed in locale: $loc');
    }
  });

  testWidgets('EditorLandscapeTopBar renders without overflow on 640 width across locales', (tester) async {
    for (final loc in [
      const Locale('de', 'DE'),
      const Locale('fr', 'FR'),
      const Locale('es', 'ES'),
      const Locale('pt', 'BR'),
    ]) {
      FlutterErrorDetails? caughtDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };

      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestApp(EditorLandscapeTopBar(controller: controller), locale: loc));
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;
      tester.view.resetPhysicalSize();

      expect(caughtDetails, isNull, reason: 'Landscape failed in locale: $loc');
    }
  });
}
