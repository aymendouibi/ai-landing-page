import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../dashboard/dashboard_controller.dart';
import '../subscription/subscription_view.dart';

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

  bool get isLimitReached {
    if (Get.isRegistered<DashboardController>()) {
      final dc = Get.find<DashboardController>();
      return dc.aiGenerationsMonthly.value > 0 &&
          dc.aiGenerationsUsed.value >= dc.aiGenerationsMonthly.value;
    }
    return false;
  }

  void setIndustry(String industry) {
    selectedIndustry.value = industry;
  }

  Future<void> generateWebsite() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      errorMessage.value = 'Please describe your website or business idea.';
      return;
    }

    if (isLimitReached) {
      SubscriptionView.open();
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
        final dc = Get.find<DashboardController>();
        dc.aiGenerationsUsed.value++;
        dc.loadData();
      }

      AppSnackbar.success('ai_creator_generated_success'.tr);

      Get.offNamed(AppRoutes.editor, arguments: {'websiteId': websiteId});
    } catch (e) {
      if (ApiClient.isSubscriptionLimitError(e)) {
        SubscriptionView.open();
        return;
      }
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

