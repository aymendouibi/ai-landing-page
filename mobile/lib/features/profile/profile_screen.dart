import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().activeTab.value = 'Profile';
    }
    return const DashboardScreen();
  }
}

