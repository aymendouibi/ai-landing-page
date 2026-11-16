import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/core/routes/app_routes.dart';
import 'package:aibuilder/core/routes/orientation_route_observer.dart';
import 'package:aibuilder/features/editor/editor_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> methodCalls = [];

  setUp(() {
    Get.reset();
    methodCalls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          methodCalls.add(methodCall);
          return null;
        });
  });

  tearDown(() {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('OrientationRouteObserver.lockPortrait sets portraitUp', () async {
    OrientationRouteObserver.lockPortrait();

    expect(methodCalls, isNotEmpty);
    final lastCall = methodCalls.last;
    expect(lastCall.method, 'SystemChrome.setPreferredOrientations');
    expect(lastCall.arguments, contains('DeviceOrientation.portraitUp'));
  });

  test('OrientationRouteObserver enforces portrait when entering non-editor route', () async {
    methodCalls.clear();

    final observer = OrientationRouteObserver();
    final route = MaterialPageRoute(
      builder: (_) => const SizedBox(),
      settings: const RouteSettings(name: AppRoutes.dashboard),
    );

    observer.didPush(route, null);

    expect(methodCalls, isNotEmpty);
    final lastCall = methodCalls.last;
    expect(lastCall.method, 'SystemChrome.setPreferredOrientations');
    expect(lastCall.arguments, contains('DeviceOrientation.portraitUp'));
  });

  test('OrientationRouteObserver enforces portrait when returning from editor to previous non-editor route', () async {
    final observer = OrientationRouteObserver();
    final editorRoute = MaterialPageRoute(
      builder: (_) => const SizedBox(),
      settings: const RouteSettings(name: AppRoutes.editor),
    );
    final dashboardRoute = MaterialPageRoute(
      builder: (_) => const SizedBox(),
      settings: const RouteSettings(name: AppRoutes.dashboard),
    );

    methodCalls.clear();
    observer.didPop(editorRoute, dashboardRoute);

    expect(methodCalls, isNotEmpty);
    final lastCall = methodCalls.last;
    expect(lastCall.method, 'SystemChrome.setPreferredOrientations');
    expect(lastCall.arguments, contains('DeviceOrientation.portraitUp'));
  });

  test('EditorController toggleLandscape and setPortrait invoke platform orientation channels', () async {
    final controller = EditorController();
    methodCalls.clear();

    controller.setLandscape();
    expect(controller.isLandscape.value, true);
    expect(
      methodCalls.any(
        (c) =>
            c.method == 'SystemChrome.setPreferredOrientations' &&
            (c.arguments as List).contains('DeviceOrientation.landscapeLeft'),
      ),
      true,
    );

    methodCalls.clear();
    controller.setPortrait();
    expect(controller.isLandscape.value, false);
    expect(
      methodCalls.any(
        (c) =>
            c.method == 'SystemChrome.setPreferredOrientations' &&
            (c.arguments as List).contains('DeviceOrientation.portraitUp'),
      ),
      true,
    );
  });
}
