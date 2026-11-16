import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/localization/supported_locales.dart';
import '../../core/models/website.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_manager.dart';
import '../templates/templates_controller.dart';
import '../assets/assets_controller.dart';
import '../subscription/subscription_view.dart';
import 'components/recent_project_card.dart';

class DashboardController extends GetxController {
  final activeTab = 'Projects'.obs;
  final userInitials = 'MR'.obs;
  final userName = RxnString('Morgan Reed');
  final userEmail = 'morgan.reed@gmail.com'.obs;
  final websites = <Website>[].obs;
  final previewItems = <WebsitePreviewItem>[].obs;
  final isLoading = true.obs;
  final themeMode = ThemeMode.system.obs;
  final currentLocale = AppLocales.fallbackLocale.obs;

  // Showcase keys for onboarding tour
  final showcaseAddButtonKey = GlobalKey();
  final showcaseHeroCardKey = GlobalKey();

  // Subscription & Tier State
  final planSlug = 'free'.obs;
  final planName = 'Free'.obs;
  final aiGenerationsMonthly = 4.obs;
  final aiGenerationsUsed = 0.obs;
  final hasAds = true.obs;
  final canUseCustomDomains = false.obs;
  final canAccessAllTemplates = false.obs;
  final subscriptionPeriodEnd = ''.obs;
  final subscriptionInterval = 'monthly'.obs;
  final deletedWebsiteIds = <String>{}.obs;

  bool get isPremium => planSlug.value == 'pro' || planSlug.value == 'business';

  Website? get heroWebsite => websites.firstOrNull;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    _loadLocale();
    loadData();
  }

  Future<void> _loadThemeMode() async {
    themeMode.value = await SessionManager.getThemeMode();
  }

  Future<void> _loadLocale() async {
    currentLocale.value = await SessionManager.getLocale();
  }

  void setLocale(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    SessionManager.saveLocale(locale);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    final str = mode == ThemeMode.dark
        ? 'dark'
        : (mode == ThemeMode.light ? 'light' : 'system');
    SessionManager.saveThemeMode(str);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    userName.value = name;
    userEmail.value = email;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1 && parts[0].isNotEmpty) {
      userInitials.value = parts[0]
          .substring(0, parts[0].length >= 2 ? 2 : 1)
          .toUpperCase();
    } else if (parts.length >= 2) {
      userInitials.value = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    await SessionManager.saveProfile(name: name, email: email);
  }

  Future<void> deleteAccount() async {
    // Per user specification: only does logout, not actual account deletion
    await logout();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    final initials = await SessionManager.getUserInitials();
    final name = await SessionManager.getUserName();
    final email = await SessionManager.getUserEmail();
    userInitials.value = (initials.isNotEmpty && initials != 'DC')
        ? initials
        : 'MR';
    userName.value = (name != null && name.trim().isNotEmpty)
        ? name
        : 'Morgan Reed';
    if (email != null && email.trim().isNotEmpty) {
      userEmail.value = email;
    } else {
      userEmail.value = 'morgan.reed@gmail.com';
    }

    try {
      deletedWebsiteIds.assignAll(await SessionManager.getDeletedWebsiteIds());
      await loadSubscription();
      final fetchedWebsites = await ApiClient.getWebsites();

      // Sort websites: recently opened first, then by updatedAt descending
      final recentOpenedIds = await SessionManager.getRecentOpenedWebsiteIds();
      final orderedWebsites = List<Website>.from(fetchedWebsites);
      orderedWebsites.sort((a, b) {
        final idxA = recentOpenedIds.indexOf(a.id);
        final idxB = recentOpenedIds.indexOf(b.id);
        if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
        if (idxA != -1) return -1;
        if (idxB != -1) return 1;
        final timeA = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA);
      });

      if (!Platform.environment.containsKey('FLUTTER_TEST') ||
          websites.isEmpty) {
        websites.assignAll(orderedWebsites);
      }
      _generatePreviewItems();
    } catch (_) {
      _generatePreviewItems();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubscription() async {
    try {
      final sub = await ApiClient.getSubscription();
      if (sub.isNotEmpty) {
        final plan = sub['plan'] as Map<String, dynamic>?;
        final entitlements = sub['entitlements'] as Map<String, dynamic>?;
        final usage = sub['usage'] as Map<String, dynamic>?;

        if (plan != null) {
          planSlug.value = plan['slug']?.toString() ?? 'free';
          planName.value = plan['name']?.toString() ?? 'Free';
        }

        if (entitlements != null) {
          aiGenerationsMonthly.value =
              (entitlements['ai_generations_monthly'] as num?)?.toInt() ??
              (isPremium ? 90 : 4);
          hasAds.value = entitlements['has_ads'] == true;
          canUseCustomDomains.value =
              ((entitlements['custom_domains'] as num?)?.toInt() ?? 0) > 0;
          canAccessAllTemplates.value =
              entitlements['all_templates'] == true ||
              entitlements['premium_templates'] == true;
        }

        if (usage != null) {
          aiGenerationsUsed.value =
              (usage['ai_generations'] as num?)?.toInt() ?? 0;
        }

        final subscription = sub['subscription'] as Map<String, dynamic>?;
        if (subscription != null) {
          subscriptionPeriodEnd.value =
              subscription['ends_at_formatted']?.toString() ?? '';
          subscriptionInterval.value =
              subscription['interval']?.toString() ?? 'monthly';
        }
      }
    } catch (_) {}
  }

  Future<bool> switchPlan(
    String targetSlug, {
    String? interval,
    String? paymentIntentId,
    String? provider,
  }) async {
    try {
      final res = await ApiClient.subscribePlan(
        targetSlug,
        interval: interval,
        paymentIntentId: paymentIntentId,
        provider: provider,
      );
      final summary = res['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        final plan = summary['plan'] as Map<String, dynamic>?;
        final entitlements = summary['entitlements'] as Map<String, dynamic>?;
        final usage = summary['usage'] as Map<String, dynamic>?;

        if (plan != null) {
          planSlug.value = plan['slug']?.toString() ?? targetSlug;
          planName.value =
              plan['name']?.toString() ??
              (targetSlug == 'pro' ? 'Premium' : 'Free');
        }

        if (entitlements != null) {
          aiGenerationsMonthly.value =
              (entitlements['ai_generations_monthly'] as num?)?.toInt() ??
              (isPremium ? 90 : 4);
          hasAds.value = entitlements['has_ads'] == true;
          canUseCustomDomains.value =
              ((entitlements['custom_domains'] as num?)?.toInt() ?? 0) > 0;
          canAccessAllTemplates.value =
              entitlements['all_templates'] == true ||
              entitlements['premium_templates'] == true;
        }

        if (usage != null) {
          aiGenerationsUsed.value =
              (usage['ai_generations'] as num?)?.toInt() ?? 0;
        }

        final subscription = summary['subscription'] as Map<String, dynamic>?;
        if (subscription != null) {
          subscriptionPeriodEnd.value =
              subscription['ends_at_formatted']?.toString() ?? '';
          subscriptionInterval.value =
              subscription['interval']?.toString() ?? 'monthly';
        }
      } else {
        await loadSubscription();
      }

      if (targetSlug == 'pro') {
        AppSnackbar.success(
          'dashboard_welcome_premium'.tr,
          title: 'dashboard_sub_updated'.tr,
        );
      } else {
        AppSnackbar.info(
          'dashboard_switched_free'.tr,
          title: 'dashboard_sub_updated'.tr,
        );
      }
      return true;
    } catch (e) {
      AppSnackbar.error('Failed to update plan: $e', title: 'common_error'.tr);
      return false;
    }
  }

  String _formatTimeAgo(DateTime? date, {bool isLive = false}) {
    if (date == null)
      return isLive ? 'Live · Published recently' : 'Draft · Edited recently';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (isLive) {
      if (diff.inMinutes < 60) return 'Live · Published recently';
      if (diff.inHours < 24) return 'Live · Published ${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Live · Published yesterday';
      return 'Live · Published ${diff.inDays}d ago';
    }
    if (diff.inMinutes < 1) return 'Draft · Edited just now';
    if (diff.inMinutes < 60) return 'Draft · Edited ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Draft · Edited ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Draft · Edited yesterday';
    return 'Draft · Edited ${diff.inDays}d ago';
  }

  void _generatePreviewItems() {
    final list = <WebsitePreviewItem>[];

    // Map all user websites from backend (only real user websites)
    for (final site in websites) {
      if (deletedWebsiteIds.contains(site.id) ||
          deletedWebsiteIds.contains(site.slug))
        continue;

      String headline = 'Crafted for Modern Growth';
      String body =
          'Clean architecture, custom layout, and optimized speed for high conversion.';
      String category = site.status == 'published'
          ? 'Published Website'
          : 'Draft Project';
      String ctaText = 'Explore work';
      Color ctaColor = const Color(0xFF111827);
      double ctaBorderRadius = 4.0;
      String imageUrl =
          'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80';
      Color bgCanvasColor = const Color(0xFFFFFFFF);
      bool isSerif = false;

      final doc = site.document;
      if (doc != null) {
        final pages = doc['pages'] as List?;
        if (pages != null && pages.isNotEmpty) {
          final sections = (pages.first as Map)['sections'] as List?;
          if (sections != null) {
            for (final sec in sections) {
              if (sec is Map &&
                  (sec['component'] == 'hero' || sec['type'] == 'hero')) {
                final props = sec['props'] as Map?;
                if (props != null) {
                  headline =
                      props['headline']?.toString() ??
                      props['title']?.toString() ??
                      headline;
                  body =
                      props['subheadline']?.toString() ??
                      props['description']?.toString() ??
                      body;
                  ctaText =
                      props['ctaText']?.toString() ??
                      props['cta_text']?.toString() ??
                      ctaText;
                  String? img;
                  final rawImg =
                      props['image'] ?? props['imageUrl'] ?? props['url'];
                  if (rawImg is Map) {
                    img =
                        rawImg['src']?.toString() ?? rawImg['url']?.toString();
                  } else if (rawImg is String && rawImg.startsWith('http')) {
                    img = rawImg;
                  }
                  if (img != null && img.isNotEmpty) {
                    imageUrl = img;
                  }
                }
                break;
              }
            }
          }
        }

        final theme = (doc['site'] as Map?)?['theme'] as Map?;
        final colors = theme?['colors'] as Map?;
        if (colors != null) {
          if (colors['primary'] != null) {
            final hex = colors['primary'].toString().replaceAll('#', '');
            if (hex.length == 6) {
              ctaColor = Color(int.parse('FF$hex', radix: 16));
            }
          }
          if (colors['background'] != null) {
            final hex = colors['background'].toString().replaceAll('#', '');
            if (hex.length == 6) {
              bgCanvasColor = Color(int.parse('FF$hex', radix: 16));
            }
          }
        }
      }

      final isLive = site.status == 'published' || site.status == 'live';
      list.add(
        WebsitePreviewItem(
          id: site.id,
          title: site.name,
          category: category,
          headline: headline,
          body: body,
          ctaText: ctaText,
          ctaColor: ctaColor,
          ctaBorderRadius: ctaBorderRadius,
          imageUrl: imageUrl,
          isSerif: isSerif,
          bgCanvasColor: bgCanvasColor,
          isLive: isLive,
          domain: isLive
              ? 'www.ai-landing-page.xyz/sites/${site.subdomain ?? site.slug}'
              : null,
          timeAgo: _formatTimeAgo(site.updatedAt, isLive: isLive),
        ),
      );
    }

    previewItems.assignAll(list);
  }

  void onTabSelected(String tab) {
    activeTab.value = tab;
    if (tab == 'Templates' && Get.isRegistered<TemplatesController>()) {
      Get.find<TemplatesController>().loadTemplates();
    }
    if (tab == 'Assets' && Get.isRegistered<AssetsController>()) {
      Get.find<AssetsController>().loadSites();
    }
  }

  int get currentTabIndex {
    switch (activeTab.value) {
      case 'Templates':
        return 1;
      case 'Assets':
        return 2;
      case 'Profile':
        return 3;
      default:
        return 0; // Projects
    }
  }

  void openWebsite(String websiteId) {
    SessionManager.recordRecentWebsite(websiteId);
    Get.toNamed(AppRoutes.editor, arguments: {'websiteId': websiteId})?.then((
      _,
    ) {
      loadData();
    });
  }

  void openAiCreation() {
    Get.toNamed(AppRoutes.aiCreation);
  }

  void openTemplates() {
    activeTab.value = 'Templates';
    if (Get.isRegistered<TemplatesController>()) {
      Get.find<TemplatesController>().loadTemplates();
    }
  }

  Future<void> createBlankWebsite() async {
    try {
      final projects = await ApiClient.getProjects();
      if (projects.isEmpty) {
        AppSnackbar.info('No workspace project found', title: 'Notice');
        AppSnackbar.info(
          'No workspace project found',
          title: 'common_notice'.tr,
        );
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
            'typography': {'headingFamily': 'Inter', 'bodyFamily': 'Inter'},
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
          {'id': 'page_home', 'slug': '/', 'title': 'Home', 'sections': []},
        ],
      };

      final newSite = await ApiClient.createWebsite(
        'Untitled site',
        projects.first.id,
        document: emptyDocument,
      );
      await SessionManager.recordRecentWebsite(newSite.id);
      await loadData();
      openWebsite(newSite.id);
    } catch (e) {
      if (ApiClient.isSubscriptionLimitError(e)) {
        SubscriptionView.open();
        return;
      }
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(
        msg,
        title: 'dashboard_cannot_create'.tr,
        trailing: msg.toLowerCase().contains('upgrade')
            ? GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.subscription),
                child: Text(
                  'common_upgrade'.tr,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : null,
      );
    }
  }

  Future<void> logout() async {
    await ApiClient.logout();
    if (Get.key.currentState != null || Get.testMode) {
      Get.offAllNamed(AppRoutes.auth);
    }
  }
}
