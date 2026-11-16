import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../features/editor/editor_controller.dart';
import 'app_routes.dart';

/// Ensures that only the Editor screen can be displayed in landscape orientation.
/// Any navigation entering or returning to any other route immediately locks
/// the device orientation to portraitUp.
class OrientationRouteObserver extends NavigatorObserver {
  static void lockPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  static void setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _enforceOrientationForRoute(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _enforceOrientationForRoute(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _enforceOrientationForRoute(newRoute?.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _enforceOrientationForRoute(previousRoute?.settings.name);
  }

  static void _enforceOrientationForRoute(String? routeName) {
    if (routeName == null) return;

    if (routeName != AppRoutes.editor) {
      lockPortrait();
    } else {
      // If we are on editor and controller is in landscape, retain landscape
      if (Get.isRegistered<EditorController>()) {
        final controller = Get.find<EditorController>();
        if (controller.isLandscape.value) {
          setLandscape();
          return;
        }
      }
    }
  }
}
