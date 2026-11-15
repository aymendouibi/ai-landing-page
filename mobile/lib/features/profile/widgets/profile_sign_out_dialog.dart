import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/designsystem/colors.dart';
import '../../dashboard/dashboard_controller.dart';

class ProfileSignOutDialog {
  static void show(
    BuildContext context,
    DashboardController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'profile_sign_out_title'.tr,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.inkOf(context),
          ),
        ),
        content: Text(
          'profile_sign_out_confirm'.tr,
          style: TextStyle(
            fontSize: 14.5,
            color: AppColors.inkSecondaryOf(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'common_cancel'.tr,
              style: TextStyle(color: AppColors.inkMutedOf(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text('profile_sign_out_title'.tr),
          ),
        ],
      ),
    );
  }
}
