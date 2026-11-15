import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.inkOf(context),
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
