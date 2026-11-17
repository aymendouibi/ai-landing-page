import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/dashboard/dashboard_controller.dart';

/// Unified user profile avatar circle across Projects, Templates, Assets, and Profile screens.
/// Displays user's Google/social avatar image if present; if image loading fails or is absent,
/// gracefully falls back to the user's capital letter initials with sleek styling.
class UserAvatarCircle extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final String? avatarUrl;
  final String? initials;
  final bool isDark;
  final bool isPro;
  final double? fontSize;

  const UserAvatarCircle({
    super.key,
    this.size = 38,
    this.onTap,
    this.avatarUrl,
    this.initials,
    this.isDark = false,
    this.isPro = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    DashboardController? controller;
    if (Get.isRegistered<DashboardController>()) {
      controller = Get.find<DashboardController>();
    }

    Widget content = Obx(() {
      final effectiveAvatarUrl = avatarUrl ?? controller?.userAvatarUrl.value;
      final effectiveInitials = (initials ?? controller?.userInitials.value ?? 'MR')
          .toUpperCase()
          .trim();
      final effectivePro = isPro || (controller?.isPremium ?? false);

      final hasValidImage = effectiveAvatarUrl != null && effectiveAvatarUrl.isNotEmpty;

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? (effectivePro ? const Color(0xFF262338) : const Color(0xFF334155))
              : (effectivePro ? const Color(0xFF181726) : const Color(0xFF18181B)),
          border: effectivePro
              ? Border.all(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.85),
                  width: size >= 50 ? 2.0 : 1.5,
                )
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
          boxShadow: [
            BoxShadow(
              color: effectivePro
                  ? const Color(0xFF7C5CFF).withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
              blurRadius: size >= 50 ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: hasValidImage
              ? Image.network(
                  effectiveAvatarUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitialsFallback(effectiveInitials, effectivePro);
                  },
                )
              : _buildInitialsFallback(effectiveInitials, effectivePro),
        ),
      );
    });

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }

  Widget _buildInitialsFallback(String initialsText, bool proActive) {
    final effectiveFontSize = fontSize ?? (size * 0.38).clamp(11.0, 22.0);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: isDark
          ? (proActive ? const Color(0xFF262338) : const Color(0xFF334155))
          : (proActive ? const Color(0xFF181726) : const Color(0xFF18181B)),
      child: Text(
        initialsText.isNotEmpty ? initialsText : 'MR',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: effectiveFontSize,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
