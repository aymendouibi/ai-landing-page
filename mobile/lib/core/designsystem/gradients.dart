import 'package:flutter/material.dart';
import 'colors.dart';

class AppGradients {
  static const backdropAura = RadialGradient(
    colors: [
      Color(0x1F7C5CFF),
      Color(0x102BC8E8),
      Colors.transparent,
    ],
    center: Alignment(0.6, -1.2),
    radius: 1.4,
  );

  static const fabAuraSweep = SweepGradient(
    colors: [
      AppColors.atmosphereViolet,
      AppColors.atmospherePink,
      AppColors.atmosphereCyan,
      AppColors.atmosphereBlue,
      AppColors.atmosphereViolet,
    ],
  );

  static const aiCardGradient = LinearGradient(
    colors: [
      AppColors.aiCardWashStart,
      AppColors.aiCardWashEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkAiCardGradient = LinearGradient(
    colors: [
      AppColors.darkAiCardWashStart,
      AppColors.darkAiCardWashEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient aiCardGradientOf(BuildContext context) =>
      AppColors.isDark(context) ? darkAiCardGradient : aiCardGradient;

  static LinearGradient profileBackgroundGradient(bool isDark) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF090D16),
                const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                const Color(0xFF1E293B).withValues(alpha: 0.4),
                const Color(0xFF090D16),
              ]
            : [
                const Color(0xFFE0F2FE).withValues(alpha: 0.8),
                const Color(0xFFEDE9FE).withValues(alpha: 0.6),
                const Color(0xFFFCE7F3).withValues(alpha: 0.4),
                const Color(0xFFF8FAFC),
              ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      );
}

