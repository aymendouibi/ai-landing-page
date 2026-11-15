import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_screen.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().activeTab.value = 'Assets';
    }
    return const DashboardScreen();
  }
}

