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

  // Dynamic context-aware typography
  static TextStyle largePageTitleOf(BuildContext context) =>
      largePageTitle.copyWith(color: AppColors.inkOf(context));

  static TextStyle sectionHeadingOf(BuildContext context) =>
      sectionHeading.copyWith(color: AppColors.inkOf(context));

  static TextStyle heroCardTitleOf(BuildContext context) =>
      heroCardTitle.copyWith(color: AppColors.inkOf(context));

  static TextStyle itemTitleOf(BuildContext context) =>
      itemTitle.copyWith(color: AppColors.inkOf(context));

  static TextStyle bodyOf(BuildContext context) =>
      body.copyWith(color: AppColors.inkSecondaryOf(context));

  static TextStyle helperOf(BuildContext context) =>
      helper.copyWith(color: AppColors.inkMutedOf(context));

  static TextStyle microOf(BuildContext context) =>
      micro.copyWith(color: AppColors.inkOf(context));
}

