import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';

class ProfileIconBadge extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color? accentColor;

  const ProfileIconBadge({
    super.key,
    required this.icon,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accentColor != null
            ? accentColor!.withValues(alpha: 0.12)
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: accentColor ?? AppColors.inkOf(context),
      ),
    );
  }
}
