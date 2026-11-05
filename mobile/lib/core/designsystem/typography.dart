import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const largePageTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.05,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );

  static const sectionHeading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.ink,
    letterSpacing: -0.3,
  );

  static const heroCardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.ink,
  );

  static const itemTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.inkSecondary,
  );

  static const helper = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.inkMuted,
  );

  static const micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink,
  );
}

