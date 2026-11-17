import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import '../storage/session_manager.dart';

/// Minimalist, non-AI styling for the app's guided tours using [ShowcaseView].
class AppShowcase {
  static bool _registered = false;

  /// Ensures a [ShowcaseView] manager is registered for the app.
  static void register() {
    if (_registered) return;
    try {
      ShowcaseView.register();
      _registered = true;
    } catch (_) {}
  }

  /// Builds a cleanly styled Showcase item for a target widget.
  static Widget item({
    required GlobalKey key,
    required String title,
    required String description,
    required Widget child,
    ShapeBorder? targetShapeBorder,
    EdgeInsets? targetPadding,
    VoidCallback? onTargetClick,
    bool disposeOnTap = false,
  }) {
    register();
    return Showcase(
      key: key,
      title: title,
      description: description,
      tooltipBackgroundColor: const Color(0xFF14171F),
      textColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF8FAFC),
        letterSpacing: -0.2,
      ),
      descTextStyle: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: Color(0xFF94A3B8),
        letterSpacing: -0.1,
        height: 1.35,
      ),
      tooltipBorderRadius: BorderRadius.circular(12),
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      targetShapeBorder: targetShapeBorder ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      targetPadding: targetPadding ?? const EdgeInsets.all(4),
      overlayColor: Colors.black,
      overlayOpacity: 0.72,
      showArrow: true,
      onTargetClick: onTargetClick,
      disposeOnTap: onTargetClick != null ? disposeOnTap : null,
      child: child,
    );
  }

  /// Triggers a showcase tour safely across the provided keys.
  static void start(
    BuildContext context,
    List<GlobalKey> keys, {
    VoidCallback? onFinish,
  }) {
    if (Get.testMode || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    if (keys.isEmpty) return;

    register();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (onFinish != null) {
          late final VoidCallback finishCb;
          late final OnDismissCallback dismissCb;

          void cleanup() {
            try {
              ShowcaseView.get().removeOnFinishCallback(finishCb);
              ShowcaseView.get().removeOnDismissCallback(dismissCb);
            } catch (_) {}
          }

          finishCb = () {
            cleanup();
            onFinish();
          };

          dismissCb = (key) {
            cleanup();
            onFinish();
          };

          ShowcaseView.get().addOnFinishCallback(finishCb);
          ShowcaseView.get().addOnDismissCallback(dismissCb);
        }
        ShowcaseView.get().startShowCase(keys);
      } catch (e) {
        debugPrint('Showcase start notice: $e');
      }
    });
  }

  /// Safely dismisses any active showcase tour.
  static void dismiss() {
    try {
      ShowcaseView.get().dismiss();
    } catch (_) {}
  }

  /// Checks if dashboard showcase has been seen, and starts it if not.
  static Future<void> checkAndStartDashboardShowcase(
    BuildContext context,
    List<GlobalKey> keys, {
    VoidCallback? onFinish,
  }) async {
    if (Get.testMode || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    final seen = await SessionManager.hasSeenDashboardShowcase();
    if (!seen) {
      await SessionManager.setDashboardShowcaseSeen(true);
      if (!context.mounted) return;
      start(context, keys, onFinish: onFinish);
    }
  }

  /// Checks if editor showcase has been seen, and starts it if not.
  static Future<void> checkAndStartEditorShowcase(
    BuildContext context,
    List<GlobalKey> keys, {
    VoidCallback? onFinish,
  }) async {
    if (Get.testMode || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    final seen = await SessionManager.hasSeenEditorShowcase();
    if (!seen) {
      await SessionManager.setEditorShowcaseSeen(true);
      if (!context.mounted) return;
      start(context, keys, onFinish: onFinish);
    }
  }

  /// Checks if new website bottom sheet showcase has been seen, and starts it if not.
  static Future<void> checkAndStartNewWebsiteShowcase(
    BuildContext context,
    List<GlobalKey> keys, {
    VoidCallback? onFinish,
  }) async {
    if (Get.testMode || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    final seen = await SessionManager.hasSeenNewWebsiteShowcase();
    if (!seen) {
      await SessionManager.setNewWebsiteShowcaseSeen(true);
      if (!context.mounted) return;
      start(context, keys, onFinish: onFinish);
    }
  }
}
