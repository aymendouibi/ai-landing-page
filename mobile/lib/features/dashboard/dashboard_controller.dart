import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/website.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_manager.dart';
import 'components/recent_project_card.dart';

class DashboardController extends GetxController {
  final activeTab = 'Projects'.obs;
  final userInitials = 'DC'.obs;
  final userName = RxnString();
  final websites = <Website>[].obs;
  final previewItems = <WebsitePreviewItem>[].obs;
  final isLoading = true.obs;

  Website? get heroWebsite => websites.firstOrNull;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    final initials = await SessionManager.getUserInitials();
    final name = await SessionManager.getUserName();
    userInitials.value = initials;
    userName.value = name;

    try {
      final fetchedWebsites = await ApiClient.getWebsites();
      websites.assignAll(fetchedWebsites);
      _generatePreviewItems();
    } catch (_) {
      _generatePreviewItems();
    } finally {
      isLoading.value = false;
    }
  }

  void _generatePreviewItems() {
    final list = <WebsitePreviewItem>[];

    // Map backend websites
    for (final site in websites.skip(1)) {
      if (site.slug == 'studio-marlow') {
        list.add(
          WebsitePreviewItem(
            id: site.id,
            title: 'Studio Marlow',
            category: 'Architecture, Copenhagen',
            headline: 'Quiet buildings for busy lives',
            body: 'Homes, libraries and small civic spaces, designed with the people who use them.',
            ctaText: 'See our work',
            ctaColor: const Color(0xFF0C0C14),
            imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80',
            isSerif: true,
            bgCanvasColor: const Color(0xFFFAF8F5),
          ),
        );
      } else if (site.slug == 'kite-yoga') {
        list.add(
          WebsitePreviewItem(
            id: site.id,
            title: 'Kite Yoga',
            category: 'East 6th St, Austin',
            headline: 'Slow mornings start here',
            body: 'Small classes in a sunlit studio, timers to daily practice.',
            ctaText: 'See the schedule',
            ctaColor: const Color(0xFF5D6B50),
            imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80',
            isSerif: false,
            bgCanvasColor: const Color(0xFFFAF8F4),
          ),
        );
      } else {
        final isBakery = site.name.toLowerCase().contains('boulangerie');
        final isApex = site.name.toLowerCase().contains('apex');
        list.add(
          WebsitePreviewItem(
            id: site.id,
            title: site.name,
            category: isBakery ? 'Artisanal Bakery, Paris' : (isApex ? 'Architecture & Design' : 'Digital Studio'),
            headline: isBakery
                ? 'Fresh Croissants, Crafted with Tech-Precision'
                : (isApex ? "Designing Tomorrow's Landmarks" : 'Crafted for Modern Growth'),
            body: isBakery
                ? 'Experience the perfect blend of traditional French baking and modern digital quality.'
                : (isApex ? 'We blend cutting-edge design, sustainable practices, and flawless execution.' : 'Clean architecture, custom layout, and optimized speed for high conversion.'),
            ctaText: isBakery ? 'Explore Menu' : (isApex ? 'Explore Projects' : 'Open Editor'),
            ctaColor: (isBakery || isApex) ? const Color(0xFF2563EB) : const Color(0xFF0C0C14),
            imageUrl: isBakery
                ? 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=400&q=80'
                : (isApex
                    ? 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=400&q=80'
                    : 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=400&q=80'),
            isSerif: isApex,
            bgCanvasColor: const Color(0xFFFAF8F5),
          ),
        );
      }
    }

    // Always ensure Studio Marlow and Kite Yoga exist as high-fidelity showcase cards
    if (list.every((e) => e.title != 'Studio Marlow')) {
      list.add(
        const WebsitePreviewItem(
          id: 'showcase_studio_marlow',
          title: 'Studio Marlow',
          category: 'Architecture, Copenhagen',
          headline: 'Quiet buildings for busy lives',
          body: 'Homes, libraries and small civic spaces, designed with the people who use them.',
          ctaText: 'See our work',
          ctaColor: Color(0xFF0C0C14),
          imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80',
          isSerif: true,
          bgCanvasColor: Color(0xFFFAF8F5),
        ),
      );
    }
    if (list.every((e) => e.title != 'Kite Yoga')) {
      list.add(
        const WebsitePreviewItem(
          id: 'showcase_kite_yoga',
          title: 'Kite Yoga',
          category: 'East 6th St, Austin',
          headline: 'Slow mornings start here',
          body: 'Small classes in a sunlit studio, timers to daily practice.',
          ctaText: 'See the schedule',
          ctaColor: Color(0xFF5D6B50),
          imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80',
          isSerif: false,
          bgCanvasColor: Color(0xFFFAF8F4),
        ),
      );
    }

    previewItems.assignAll(list);
  }

  void onTabSelected(String tab) {
    activeTab.value = tab;
    if (tab == 'Templates') {
      openTemplates();
    }
  }

  void openWebsite(String websiteId) {
    Get.toNamed(AppRoutes.editor, arguments: {'websiteId': websiteId});
  }

  void openAiCreation() {
    Get.toNamed(AppRoutes.aiCreation);
  }

  void openTemplates() {
    Get.toNamed(AppRoutes.templates);
  }

  Future<void> createBlankWebsite() async {
    try {
      final projects = await ApiClient.getProjects();
      if (projects.isEmpty) {
        Get.snackbar('Notice', 'No workspace project found');
        return;
      }
      final emptyDocument = {
        'schema_version': 1,
        'site': {
          'name': 'Untitled site',
          'theme': {
            'colors': {
              'primary': '#0F172A',
              'secondary': '#64748B',
              'accent': '#B85028',
              'background': '#FFFFFF',
              'surface': '#F8FAFC',
              'text': {
                'primary': '#0F172A',
                'secondary': '#475569',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {
              'headingFamily': 'Inter',
              'bodyFamily': 'Inter',
            },
          },
          'settings': {
            'language': 'en',
            'googleFonts': ['Inter'],
          },
        },
        'navigation': {
          'logo': {'text': 'Untitled site'},
          'items': [],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [],
          },
        ],
      };

      final newSite = await ApiClient.createWebsite(
        'Untitled site',
        projects.first.id,
        document: emptyDocument,
      );
      await loadData();
      openWebsite(newSite.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create blank website: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    await ApiClient.logout();
    Get.offAllNamed(AppRoutes.auth);
  }
}

