import 'package:flutter/material.dart';

class AppColors {
  // Light mode colors
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFECEEF4);
  static const surfaceNeutral = Color(0xFFF1F1F1);

  static const ink = Color(0xFF0C0C14);
  static const inkSecondary = Color(0xFF3D3D4A);
  static const inkMuted = Color(0xFF62626F);

  static const borderSubtle = Color(0x140C0C14); // rgba(12,12,20, 0.08)
  static const borderStrong = Color(0x240C0C14); // rgba(12,12,20, 0.14)

  static const primary = atmosphereViolet;
  static const atmosphereViolet = Color(0xFF7C5CFF);
  static const atmosphereCyan = Color(0xFF2BC8E8);
  static const atmospherePink = Color(0xFFE46BFF);
  static const atmosphereBlue = Color(0xFF4F6BFF);

  static const aiCardWashStart = Color(0xFFF6F4FF);
  static const aiCardWashEnd = Color(0xFFEFF8FF);

  // Dark mode colors
  static const darkBackground = Color(0xFF090D16);
  static const darkSurface = Color(0xFF161E2E);
  static const darkSurfaceMuted = Color(0xFF1E293B);
  static const darkSurfaceNeutral = Color(0xFF243046);

  static const darkInk = Color(0xFFF8FAFC);
  static const darkInkSecondary = Color(0xFFCBD5E1);
  static const darkInkMuted = Color(0xFF94A3B8);

  static const darkBorderSubtle = Color(0x1AFFFFFF);
  static const darkBorderStrong = Color(0x33FFFFFF);

  static const darkAiCardWashStart = Color(0xFF1E1B4B);
  static const darkAiCardWashEnd = Color(0xFF0F172A);

  // Dynamic context-aware helpers
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext context) => isDark(context) ? darkBackground : background;
  static Color surfaceOf(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color surfaceMutedOf(BuildContext context) => isDark(context) ? darkSurfaceMuted : surfaceMuted;
  static Color surfaceNeutralOf(BuildContext context) => isDark(context) ? darkSurfaceNeutral : surfaceNeutral;
  static Color inkOf(BuildContext context) => isDark(context) ? darkInk : ink;
  static Color inkSecondaryOf(BuildContext context) => isDark(context) ? darkInkSecondary : inkSecondary;
  static Color inkMutedOf(BuildContext context) => isDark(context) ? darkInkMuted : inkMuted;
  static Color borderSubtleOf(BuildContext context) => isDark(context) ? darkBorderSubtle : borderSubtle;
  static Color borderStrongOf(BuildContext context) => isDark(context) ? darkBorderStrong : borderStrong;
}

