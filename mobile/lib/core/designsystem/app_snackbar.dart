import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Semantic notification type for [AppSnackbar].
enum AppSnackbarType {
  info,
  success,
  error,
  copied,
}

/// Unified, clean, minimalist, and modern snackbar / toast system.
/// Designed with razor-sharp typography, dark matte obsidian slate surface,
/// subtle micro-border, and crisp monochrome/status accents.
/// Free of any "AI-like" gimmicks (no neon halos, purple gradients, or sparkly glow).
class AppSnackbar {
  /// Shows the unified snackbar. Works seamlessly with or without [BuildContext].
  static void show(
    String message, {
    String? title,
    BuildContext? context,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(milliseconds: 2500),
    Widget? trailing,
  }) {
    final targetContext = context ?? Get.context ?? Get.key.currentContext;
    if (targetContext != null) {
      final messenger = ScaffoldMessenger.maybeOf(targetContext);
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          snackBar(
            message,
            title: title,
            type: type,
            duration: duration,
            trailing: trailing,
          ),
        );
        return;
      }
    }

    // Avoid unhandled async timer animations during headless controller tests
    if (Get.testMode || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    // Fallback via GetX raw snackbar if no ScaffoldMessenger is in the active tree
    try {
      Get.closeCurrentSnackbar();
      Get.rawSnackbar(
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        duration: duration,
        animationDuration: const Duration(milliseconds: 220),
        messageText: AppSnackbarContent(
          message: message,
          title: title,
          type: type,
          trailing: trailing,
        ),
      );
    } catch (_) {}
  }

  /// Convenience for successful actions.
  static void success(
    String message, {
    String? title,
    BuildContext? context,
    Duration duration = const Duration(milliseconds: 2500),
    Widget? trailing,
  }) {
    show(
      message,
      title: title,
      context: context,
      type: AppSnackbarType.success,
      duration: duration,
      trailing: trailing,
    );
  }

  /// Convenience for error / failure alerts.
  static void error(
    String message, {
    String? title,
    BuildContext? context,
    Duration duration = const Duration(milliseconds: 3000),
    Widget? trailing,
  }) {
    show(
      message,
      title: title,
      context: context,
      type: AppSnackbarType.error,
      duration: duration,
      trailing: trailing,
    );
  }

  /// Convenience for clipboard copy feedback.
  static void copied({
    String message = 'Copied to clipboard',
    BuildContext? context,
    Duration duration = const Duration(milliseconds: 2000),
    Widget? trailing,
  }) {
    show(
      message,
      context: context,
      type: AppSnackbarType.copied,
      duration: duration,
      trailing: trailing,
    );
  }

  /// Convenience for informational feedback.
  static void info(
    String message, {
    String? title,
    BuildContext? context,
    Duration duration = const Duration(milliseconds: 2500),
    Widget? trailing,
  }) {
    show(
      message,
      title: title,
      context: context,
      type: AppSnackbarType.info,
      duration: duration,
      trailing: trailing,
    );
  }

  /// Creates a floating [SnackBar] widget with the unified clean design.
  static SnackBar snackBar(
    String message, {
    String? title,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(milliseconds: 2500),
    Widget? trailing,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: EdgeInsets.zero,
      duration: duration,
      content: AppSnackbarContent(
        message: message,
        title: title,
        type: type,
        trailing: trailing,
      ),
    );
  }
}

/// The visual presentation of the minimalist snackbar.
class AppSnackbarContent extends StatelessWidget {
  final String message;
  final String? title;
  final AppSnackbarType type;
  final Widget? trailing;

  const AppSnackbarContent({
    super.key,
    required this.message,
    this.title,
    this.type = AppSnackbarType.info,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final (iconData, iconColor, iconBgColor) = switch (type) {
      AppSnackbarType.success => (
          LucideIcons.check,
          const Color(0xFF10B981), // Emerald
          const Color(0x1F10B981),
        ),
      AppSnackbarType.error => (
          LucideIcons.circleAlert,
          const Color(0xFFEF4444), // Crimson
          const Color(0x1FEF4444),
        ),
      AppSnackbarType.copied => (
          LucideIcons.copy,
          const Color(0xFF38BDF8), // Crisp sky
          const Color(0x1F38BDF8),
        ),
      AppSnackbarType.info => (
          LucideIcons.info,
          const Color(0xFF94A3B8), // Refined slate
          const Color(0x1F94A3B8),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14171F), // Dark obsidian matte slate
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22FFFFFF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              iconData,
              size: 14,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF8FAFC),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: (title != null && title!.isNotEmpty) ? 12 : 13,
                    fontWeight: (title != null && title!.isNotEmpty)
                        ? FontWeight.w400
                        : FontWeight.w500,
                    color: (title != null && title!.isNotEmpty)
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFFF8FAFC),
                    letterSpacing: -0.1,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
