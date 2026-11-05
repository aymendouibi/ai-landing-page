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
}

