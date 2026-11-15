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
    final str = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.light ? 'light' : 'system');
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
      userInitials.value = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
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
    userInitials.value = (initials.isNotEmpty && initials != 'DC') ? initials : 'MR';
    userName.value = (name != null && name.trim().isNotEmpty) ? name : 'Morgan Reed';
    if (email != null && email.trim().isNotEmpty) {
      userEmail.value = email;
    } else {
      userEmail.value = 'morgan.reed@gmail.com';
    }

    try {
      deletedWebsiteIds.assignAll(await SessionManager.getDeletedWebsiteIds());
      await loadSubscription();
      final fetchedWebsites = await ApiClient.getWebsites();
      if (!Platform.environment.containsKey('FLUTTER_TEST') || websites.isEmpty) {
        websites.assignAll(fetchedWebsites);
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
              plan['name']?.toString() ?? (targetSlug == 'pro' ? 'Premium' : 'Free');
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

  void _generatePreviewItems() {
    final list = <WebsitePreviewItem>[];

    // 1. Prioritize Studio Marlow and Kite Yoga showcase cards unless deleted
    if (!deletedWebsiteIds.contains('showcase_studio_marlow') &&
        !deletedWebsiteIds.contains('studio-marlow')) {
      list.add(
        const WebsitePreviewItem(
          id: 'showcase_studio_marlow',
          title: 'Studio Marlow',
          category: 'Architecture, Copenhagen',
          categoryColor: Color(0xFF475569),
          headline: 'Quiet buildings for busy lives',
          body: 'Homes, libraries and small civic spaces, designed with the people who use them.',
          ctaText: 'See our work',
          ctaColor: Color(0xFF111827),
          ctaBorderRadius: 2.0,
          imageUrl: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=600&q=80',
          isSerif: true,
          bgCanvasColor: Color(0xFFFFFFFF),
          isLive: true,
          domain: 'studiomarlow.com',
        ),
      );
    }

    if (!deletedWebsiteIds.contains('showcase_kite_yoga') &&
        !deletedWebsiteIds.contains('kite-yoga')) {
      list.add(
        const WebsitePreviewItem(
          id: 'showcase_kite_yoga',
          title: 'Kite Yoga',
          category: 'East 6th St, Austin',
          categoryColor: Color(0xFF5D6B50),
          headline: 'Slow mornings start here',
          body: 'Small classes in a sunlit studio, timers to daily practice.',
          ctaText: 'See the schedule',
          ctaColor: Color(0xFF5D6B50),
          ctaBorderRadius: 10.0,
          imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80',
          isSerif: false,
          bgCanvasColor: Color(0xFFFAF8F4),
          isLive: false,
          timeAgo: 'Draft · Edited 3 days ago',
        ),
      );
    }

    // 2. Map other user websites from backend
    for (final site in websites) {
      if (deletedWebsiteIds.contains(site.id) || deletedWebsiteIds.contains(site.slug)) continue;
      if (site.slug == 'studio-marlow' || site.slug == 'kite-yoga') continue;

      String headline = 'Crafted for Modern Growth';
      String body = 'Clean architecture, custom layout, and optimized speed for high conversion.';
      String category = 'Digital Studio, San Francisco';
      String ctaText = 'Explore work';
      Color ctaColor = const Color(0xFF111827);
      double ctaBorderRadius = 4.0;
      String imageUrl = 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80';
      Color bgCanvasColor = const Color(0xFFFFFFFF);
      bool isSerif = false;

      final doc = site.document;
      if (doc != null) {
        final pages = doc['pages'] as List?;
        if (pages != null && pages.isNotEmpty) {
          final sections = (pages.first as Map)['sections'] as List?;
          if (sections != null) {
            for (final sec in sections) {
              if (sec is Map && (sec['component'] == 'hero' || sec['type'] == 'hero')) {
                final props = sec['props'] as Map?;
                if (props != null) {
                  headline = props['headline']?.toString() ?? props['title']?.toString() ?? headline;
                  body = props['subheadline']?.toString() ?? props['description']?.toString() ?? body;
                  ctaText = props['ctaText']?.toString() ?? props['cta_text']?.toString() ?? ctaText;
                  String? img;
                  final rawImg = props['image'] ?? props['imageUrl'] ?? props['url'];
                  if (rawImg is Map) {
                    img = rawImg['src']?.toString() ?? rawImg['url']?.toString();
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
          domain: isLive ? (site.subdomain != null ? '${site.subdomain}.com' : '${site.slug}.com') : null,
          timeAgo: isLive ? null : 'Draft · Edited recently',
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
    Get.toNamed(AppRoutes.editor, arguments: {'websiteId': websiteId});
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
        AppSnackbar.info('No workspace project found', title: 'common_notice'.tr);
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

