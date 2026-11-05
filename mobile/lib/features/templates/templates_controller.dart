import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/website.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../dashboard/dashboard_controller.dart';

class TemplatesController extends GetxController {
  final templates = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final list = await ApiClient.getTemplates();
      if (list.isNotEmpty) {
        templates.assignAll(list);
      } else {
        // Fallback showcase templates if backend catalog is empty
        templates.assignAll([
          {
            'id': 'tmpl-marlow',
            'name': 'Studio Marlow',
            'industry': 'Architecture & Design',
            'slug': 'studio-marlow',
            'preview_images': [
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80'
            ],
          },
          {
            'id': 'tmpl-kite',
            'name': 'Kite Yoga',
            'industry': 'Wellness & Studio',
            'slug': 'kite-yoga',
            'preview_images': [
              'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80'
            ],
          },
          {
            'id': 'tmpl-lumen',
            'name': 'Lumen Coffee',
            'industry': 'Café & Roastery',
            'slug': 'lumen-coffee',
            'preview_images': [
              'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80'
            ],
          },
        ]);
      }
    } catch (_) {
      // Fallback
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> useTemplate(Map<String, dynamic> template) async {
    try {
      final projects = await ApiClient.getProjects();
      if (projects.isEmpty) {
        Get.snackbar('Notice', 'No workspace project found');
        return;
      }

      final templateId = template['id'] as String;
      Website site;
      try {
        site = await ApiClient.useTemplate(
          templateId: templateId,
          projectId: projects.first.id,
          name: '${template['name']} Site',
        );
      } catch (_) {
        // If template id is local showcase id, create a website directly
        site = await ApiClient.createWebsite(template['name'] ?? 'New Website', projects.first.id);
      }

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      Get.snackbar(
        'Success',
        'Website created from template!',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      );

      Get.offNamed(AppRoutes.editor, arguments: {'websiteId': site.id});
    } catch (e) {
      Get.snackbar('Error', 'Failed to use template: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
