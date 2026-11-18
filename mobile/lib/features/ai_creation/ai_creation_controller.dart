import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/session_manager.dart';
import '../dashboard/dashboard_controller.dart';
import '../subscription/subscription_view.dart';

enum AiCreationStyle { clean, bold, soft }

class AiCreationController extends GetxController {
  final titleController = TextEditingController();
  final promptController = TextEditingController();
  final promptLength = 0.obs;

  final selectedStyle = AiCreationStyle.clean.obs;
  final selectedLanguage = 'English'.obs;

  final selectedIndustry = 'Technology'.obs;
  final isLoading = false.obs;
  final progressStage = RxnString();
  final errorMessage = RxnString();

  final List<String> availableLanguages = [
    'English',
    'Español',
    'Français',
    'Deutsch',
    'العربية',
    '简体中文',
    '日本語',
    'Português',
  ];

  static const defaultPlaceholderPrompt =
      'A landing page for a mindful productivity app. Help freelancers find their focus, show the key features, and invite visitors to join the waitlist.';

  bool get isLimitReached {
    if (Get.isRegistered<DashboardController>()) {
      final dc = Get.find<DashboardController>();
      return dc.aiGenerationsMonthly.value > 0 &&
          dc.aiGenerationsUsed.value >= dc.aiGenerationsMonthly.value;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    promptController.addListener(() {
      promptLength.value = promptController.text.length;
    });
    AdService.instance.preloadVideoAd(adTag: 'ai_website_created');
  }

  void setStyle(AiCreationStyle style) {
    selectedStyle.value = style;
  }

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  void applyIdeaPrompt(String ideaType) {
    switch (ideaType.toLowerCase()) {
      case 'portfolio':
        promptController.text =
            'A minimalist portfolio website for a senior product designer. Highlight recent case studies, client logos, design philosophy, and a contact form.';
        break;
      case 'online store':
      case 'online_store':
      case 'store':
        promptController.text =
            'An elegant e-commerce landing page for an artisanal organic matcha brand. Showcase single-origin tins, brewing accessories, customer reviews, and newsletter signup.';
        break;
      case 'saas product':
      case 'saas':
        promptController.text =
            'A high-conversion landing page for a B2B AI analytics tool. Feature interactive pricing calculator, live metrics demo, enterprise security badges, and CTA for a 14-day free trial.';
        break;
      default:
        promptController.text = defaultPlaceholderPrompt;
        break;
    }
    promptLength.value = promptController.text.length;
  }

  Future<void> generateWebsite() async {
    var prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      prompt = defaultPlaceholderPrompt;
    }

    if (isLimitReached) {
      SubscriptionView.open();
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    progressStage.value = 'Extracting brand identity and tokens...';

    // Enrich prompt with chosen style, title/brand, and output language
    final customTitle = titleController.text.trim();
    final enrichedPrompt = StringBuffer(prompt);
    if (customTitle.isNotEmpty) {
      enrichedPrompt.write(' Website name / Brand: "$customTitle".');
    }
    enrichedPrompt.write(' Style preference: ${selectedStyle.value.name}.');
    enrichedPrompt.write(' Target language: ${selectedLanguage.value}.');

    try {
      final projects = await ApiClient.getProjects();
      if (projects.isEmpty) {
        throw Exception(
          'No project workspace available. Please create a project first.',
        );
      }

      progressStage.value = 'Generating sections and conversion copy...';

      final res = await ApiClient.generateWebsite(
        prompt: enrichedPrompt.toString(),
        projectId: projects.first.id,
        industry: selectedStyle.value == AiCreationStyle.bold
            ? 'Technology'
            : selectedStyle.value == AiCreationStyle.soft
            ? 'Beauty & Wellness'
            : 'SaaS',
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

      try {
        final siteName = res['website']?['name']?.toString() ?? 'Your website';
        NotificationService.instance.showAiModificationNotification(
          siteName: siteName,
          summary: 'New website generated with AI',
        );
      } catch (_) {}

      await SessionManager.recordRecentWebsite(websiteId);
      AdService.instance.showVideoAd(adTag: 'ai_website_created');
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
    titleController.dispose();
    promptController.dispose();
    super.onClose();
  }
}
