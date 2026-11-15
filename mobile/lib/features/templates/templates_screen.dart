import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_screen.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().activeTab.value = 'Templates';
    }
    return const DashboardScreen();
  }
}
