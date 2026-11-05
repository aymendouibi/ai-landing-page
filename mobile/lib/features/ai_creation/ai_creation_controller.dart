import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../dashboard/dashboard_controller.dart';

class AiCreationController extends GetxController {
  final promptController = TextEditingController();
  final selectedIndustry = 'Technology'.obs;
  final isLoading = false.obs;
  final progressStage = RxnString();
  final errorMessage = RxnString();

  final List<String> industries = [
    'Technology',
    'SaaS',
    'Restaurant',
    'Beauty & Wellness',
    'Retail',
  ];

  void setIndustry(String industry) {
    selectedIndustry.value = industry;
  }

  Future<void> generateWebsite() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      errorMessage.value = 'Please describe your website or business idea.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    progressStage.value = 'Extracting brand identity and tokens...';

    try {
      final projects = await ApiClient.getProjects();
      if (projects.isEmpty) {
        throw Exception('No project workspace available. Please create a project first.');
      }

      progressStage.value = 'Generating sections and conversion copy...';

      final res = await ApiClient.generateWebsite(
        prompt: prompt,
        projectId: projects.first.id,
        industry: selectedIndustry.value,
      );

      final website = res['website'] as Map<String, dynamic>?;
      final websiteId = (res['website_id'] ?? website?['id']) as String?;

      if (websiteId == null) {
        throw Exception('No website ID returned from generation service');
      }

      // Refresh dashboard if it exists
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      Get.snackbar(
        'Success',
        'Website generated successfully!',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: const Color(0xFF0C0C14),
        snackPosition: SnackPosition.TOP,
      );

      Get.offNamed(AppRoutes.editor, arguments: {'websiteId': websiteId});
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
      progressStage.value = null;
    }
  }

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }
}

