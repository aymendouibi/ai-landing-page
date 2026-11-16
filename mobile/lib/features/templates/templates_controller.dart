import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/models/website.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_manager.dart';
import '../dashboard/dashboard_controller.dart';
import '../profile/components/subscription_plan_sheet.dart';
import '../subscription/subscription_view.dart';

class TemplatesController extends GetxController {
  final templates = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  final activeTab = 'For you'.obs;
  final tabs = ['For you', 'Business', 'Creative', 'Personal'];

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final searchQuery = ''.obs;

  bool get canAccessAllTemplates {
    if (Get.isRegistered<DashboardController>()) {
      final dc = Get.find<DashboardController>();
      return dc.canAccessAllTemplates.value || dc.isPremium;
    }
    return true;
  }

  bool isTemplateLocked(Map<String, dynamic> template) {
    if (canAccessAllTemplates) return false;
    final badge = (template['badge'] ?? '').toString().toUpperCase();
    final isPremium = template['is_premium'] == true;
    return isPremium || badge == 'PRO' || badge == 'PREMIUM';
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
    loadTemplates();
  }

  void setTab(String tab) {
    activeTab.value = tab;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final list = await ApiClient.getTemplates();
      if (list.isNotEmpty) {
        templates.assignAll(list);
      } else {
        templates.assignAll(fallbackTemplates);
      }
    } catch (_) {
      templates.assignAll(fallbackTemplates);
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredTemplates {
    var list = templates.toList();

    // 1. Search Query Filter
    final query = searchQuery.value.toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((t) {
        final name = (t['name'] ?? '').toString().toLowerCase();
        final industry = (t['industry'] ?? '').toString().toLowerCase();
        final desc = (t['description'] ?? '').toString().toLowerCase();
        final badge = (t['badge'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            industry.contains(query) ||
            desc.contains(query) ||
            badge.contains(query);
      }).toList();
    }

    // 2. Tab Filter
    final tab = activeTab.value;
    if (tab == 'For you' && query.isEmpty) {
      final curatedSlugs = [
        'nexus-ai',
        'aura-botanicals',
        'lumen-coffee',
        'studio-marlow',
        'vaultpay',
        'mono-studio',
        'solstice-culinary',
        'kite-yoga',
        'ana-teo',
      ];
      final curated = <Map<String, dynamic>>[];
      for (final slug in curatedSlugs) {
        final match = list.firstWhereOrNull(
          (t) =>
              (t['slug'] ?? '').toString() == slug ||
              (t['id'] ?? '').toString() == slug ||
              (t['id'] ?? '').toString() == 'tmpl-$slug' ||
              (t['name'] ?? '').toString().toLowerCase().contains(
                slug.replaceAll('-', ' ').split(' ').first,
              ),
        );
        if (match != null && !curated.any((c) => c['id'] == match['id'])) {
          curated.add(match);
        }
      }
      // Any remaining published/imported templates appear right after the curated edit
      final remaining = list
          .where((t) => !curated.any((c) => c['id'] == t['id']))
          .toList();
      return [...curated, ...remaining];
    } else if (tab == 'Business') {
      list = list.where((t) {
        final ind = (t['industry'] ?? '').toString().toLowerCase();
        final cat = (t['category']?['slug'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        return ind.contains('food') ||
            ind.contains('drink') ||
            ind.contains('café') ||
            ind.contains('restaurant') ||
            ind.contains('hospitality') ||
            ind.contains('business') ||
            ind.contains('saas') ||
            ind.contains('tech') ||
            ind.contains('ai') ||
            ind.contains('app') ||
            ind.contains('fintech') ||
            ind.contains('banking') ||
            ind.contains('beauty') ||
            ind.contains('e-commerce') ||
            ind.contains('landing') ||
            cat.contains('restaurant') ||
            cat.contains('business') ||
            cat.contains('saas') ||
            cat.contains('ecommerce') ||
            name.contains('nexus') ||
            name.contains('vault') ||
            name.contains('aura') ||
            name.contains('badgey') ||
            name.contains('apex') ||
            name.contains('lumen') ||
            name.contains('solstice');
      }).toList();
    } else if (tab == 'Creative') {
      list = list.where((t) {
        final ind = (t['industry'] ?? '').toString().toLowerCase();
        final cat = (t['category']?['slug'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        return ind.contains('architecture') ||
            ind.contains('portfolio') ||
            ind.contains('design') ||
            ind.contains('creative') ||
            ind.contains('agency') ||
            ind.contains('studio') ||
            ind.contains('beauty') ||
            cat.contains('portfolio') ||
            cat.contains('agencies') ||
            cat.contains('beauty') ||
            name.contains('mono') ||
            name.contains('kroma') ||
            name.contains('aura') ||
            name.contains('marlow') ||
            name.contains('solstice');
      }).toList();
    } else if (tab == 'Personal') {
      list = list.where((t) {
        final ind = (t['industry'] ?? '').toString().toLowerCase();
        final cat = (t['category']?['slug'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        return ind.contains('wellness') ||
            ind.contains('weddings') ||
            ind.contains('wedding') ||
            ind.contains('yoga') ||
            ind.contains('personal') ||
            ind.contains('events') ||
            ind.contains('hospitality') ||
            ind.contains('restaurant') ||
            cat.contains('fitness') ||
            cat.contains('events') ||
            name.contains('kite') ||
            name.contains('ana') ||
            name.contains('solstice') ||
            name.contains('marlow');
      }).toList();
    }

    return list;
  }

  Future<void> useTemplate(Map<String, dynamic> template) async {
    if (isTemplateLocked(template)) {
      await SubscriptionView.open(Get.context);
      return;
    }

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

      final templateId = template['id'] as String;
      Website site;
      try {
        site = await ApiClient.useTemplate(
          templateId: templateId,
          projectId: projects.first.id,
          name: '${template['name']} Site',
        );
      } catch (e) {
        if (ApiClient.isSubscriptionLimitError(e)) {
          await SubscriptionView.open(Get.context);
          return;
        }
        site = await ApiClient.createWebsite(
          template['name'] ?? 'New Website',
          projects.first.id,
        );

        final doc =
            (template['active_version']?['document'] ?? template['document'])
                as Map<String, dynamic>?;
        if (doc != null) {
          try {
            await ApiClient.updateWebsiteDocument(site.id, doc);
          } catch (_) {}
        }
      }

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      AppSnackbar.success('Website created from template!');
      AppSnackbar.success('templates_created_success'.tr);

      await SessionManager.recordRecentWebsite(site.id);
      Get.offNamed(AppRoutes.editor, arguments: {'websiteId': site.id});
    } catch (e) {
      if (ApiClient.isSubscriptionLimitError(e)) {
        await SubscriptionView.open(Get.context);
        return;
      }
      AppSnackbar.error('Failed to use template: $e', title: 'Error');
      AppSnackbar.error('Failed to use template: $e', title: 'common_error'.tr);
    }
  }

  static const List<Map<String, dynamic>> fallbackTemplates = [
    {
      'id': 'tmpl-nexus',
      'slug': 'nexus-ai',
      'name': 'Nexus AI',
      'industry': 'SaaS & AI Platform',
      'badge': '✦ TRENDING 2026',
      'is_featured': true,
      'is_public': true,
      'description':
          'High-velocity AI developer platform with sub-10ms edge execution, automated PR diffs, and real-time observability.',
      'headline': 'Linear speed.\nSuperhuman intelligence.',
      'subheadline':
          'The autonomous workspace built for modern product teams. Synthesize specs, automate code reviews, and ship zero-latency software.',
      'ctaText': 'Deploy in 60 Seconds',
      'primaryColor': '#6366F1',
      'bgColor': '#090D16',
      'preview_images': [
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Nexus AI',
          'theme': {
            'colors': {
              'primary': '#6366F1',
              'secondary': '#06B6D4',
              'accent': '#8B5CF6',
              'background': '#090D16',
              'surface': '#111827',
              'text': {
                'primary': '#F8FAFC',
                'secondary': '#94A3B8',
                'inverse': '#090D16',
              },
            },
            'typography': {
              'headingFamily': 'Plus Jakarta Sans',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'Nexus AI'},
          'items': [
            {'label': 'Features', 'href': '#features'},
            {'label': 'Pricing', 'href': '#pricing'},
            {'label': 'Deploy Free', 'href': '#cta', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_nexus_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ INTRODUCING NEXUS 2.0 · AUTONOMOUS AGENTS',
                  'headline': 'Linear speed.\nSuperhuman intelligence.',
                  'subheadline':
                      'The autonomous workspace built for modern product teams. Synthesize specs, automate code reviews, and ship zero-latency software.',
                  'ctaText': 'Deploy in 60 Seconds',
                  'ctaLink': '#cta',
                  'secondaryCtaText': 'Watch Keynote ↗',
                  'secondaryCtaLink': '#features',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Nexus AI Interface',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_nexus_features',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Engineered for Radical Momentum',
                  'subtitle':
                      'Eliminate administrative drag and focus purely on high-leverage software craftsmanship.',
                  'items': [
                    {
                      'icon': '⚡',
                      'title': 'Sub-10ms Global Latency',
                      'description':
                          'Edge runtime replicated across 35 regions worldwide with microsecond state synchronization.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Autonomous Code Diff Engine',
                      'description':
                          'Inspects AST dependencies, writes comprehensive test suites, and proposes clean visual diffs.',
                    },
                    {
                      'icon': '▲',
                      'title': 'Zero-Config Environments',
                      'description':
                          'Instant isolated preview sandboxes created automatically on every pull request.',
                    },
                    {
                      'icon': '🛡️',
                      'title': 'SOC-2 Type II Certified',
                      'description':
                          'Enterprise memory isolation with end-to-end encryption in transit and at rest.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_nexus_stats',
                'component': 'statistics',
                'order': 2,
                'props': {
                  'title': 'Powering World-Class Engineering Teams',
                  'subtitle':
                      'From hyper-growth startups to Fortune 500 digital platforms.',
                  'metrics': [
                    {
                      'value': '99.999%',
                      'label': 'Edge Uptime SLA',
                      'description': 'Sub-minute recovery guarantee',
                    },
                    {
                      'value': '4.2x',
                      'label': 'Sprint Velocity',
                      'description': 'Average delivery acceleration',
                    },
                    {
                      'value': '85,000+',
                      'label': 'Active Engineers',
                      'description': 'Shipping code daily',
                    },
                    {
                      'value': '< 12ms',
                      'label': 'P99 Latency',
                      'description': 'Worldwide average response',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_nexus_pricing',
                'component': 'products',
                'order': 3,
                'props': {
                  'title': 'Predictable, Developer-First Pricing',
                  'subtitle':
                      'Transparent tiers that scale effortlessly with your compute needs.',
                  'items': [
                    {
                      'name': 'Developer Free',
                      'price': '\$0 / mo',
                      'description':
                          'Unlimited public repos, 5 preview sandboxes, and community Discord support.',
                      'image':
                          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Pro Team',
                      'price': '\$29 / user',
                      'description':
                          'Autonomous code diffs, private VPC peering, and priority edge execution.',
                      'image':
                          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Enterprise Scale',
                      'price': 'Custom',
                      'description':
                          'Dedicated single-tenant clusters, custom LLM fine-tuning, and 99.999% SLA.',
                      'image':
                          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_nexus_testimonials',
                'component': 'testimonials',
                'order': 4,
                'props': {
                  'title': 'Loved by Technical Founders & Leaders',
                  'subtitle': 'Read how leading teams ship faster with Nexus.',
                  'items': [
                    {
                      'quote':
                          'Nexus feels like software from 2030. The dark aesthetic, keyboard command bar, and instantaneous feedback loop make it irreplaceable.',
                      'author': 'Elena Rostova',
                      'role': 'VP of Engineering, CloudScale',
                      'avatar':
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                    },
                    {
                      'quote':
                          'We replaced three disconnected CI/CD and project tools with Nexus in an afternoon. Our team ships twice as many features every release.',
                      'author': 'Marcus Vance',
                      'role': 'Co-Founder & CTO, Synthetix',
                      'avatar':
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_nexus_faq',
                'component': 'faq',
                'order': 5,
                'props': {
                  'title': 'Frequently Asked Questions',
                  'subtitle':
                      'Everything you need to know about Nexus infrastructure and security.',
                  'items': [
                    {
                      'question':
                          'Can we deploy Nexus within our private AWS/GCP VPC?',
                      'answer':
                          'Yes. Nexus Enterprise offers single-tenant isolated deployments that run securely behind your own corporate firewall and VPC networks.',
                    },
                    {
                      'question':
                          'How does the Autonomous Code Diff engine work?',
                      'answer':
                          'Nexus analyzes your repository AST, dependency graph, and Git history to draft complete pull requests, accompanied by automated regression tests.',
                    },
                    {
                      'question':
                          'Is proprietary customer code used for AI model training?',
                      'answer':
                          'Never. We maintain a zero-retention policy for customer source code. Context windows are purged from memory immediately upon job completion.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_nexus_cta',
                'component': 'cta',
                'order': 6,
                'props': {
                  'headline': 'Transform your team into a high-output engine.',
                  'description':
                      'Join over 85,000 engineers building next-generation digital products on Nexus.',
                  'buttonText': 'Start Building Free',
                  'buttonLink': '#start',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_nexus_footer',
                'component': 'footer',
                'order': 7,
                'props': {
                  'copyright':
                      '© 2026 Nexus Systems Inc. San Francisco · Zurich.',
                  'links': [
                    {'label': 'Changelog', 'href': '#changelog'},
                    {'label': 'API Docs', 'href': '#api'},
                    {'label': 'Status', 'href': '#status'},
                    {'label': 'Security', 'href': '#security'},
                    {'label': 'Privacy Policy', 'href': '#privacy'},
                  ],
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-aura',
      'slug': 'aura-botanicals',
      'name': 'Aura Botanicals',
      'industry': 'Beauty & Skincare',
      'badge': 'AWARD WINNING',
      'is_featured': true,
      'is_public': true,
      'description':
          'Cold-pressed botanical skincare formulated with biodynamic alpine flora for luminous, restorative skin health.',
      'headline': 'Pure botanical science.\nUnfiltered radiance.',
      'subheadline':
          'Clinical efficacy rooted in biodynamic harvesting. Clean, certified organic formulations that nourish your skin barrier.',
      'ctaText': 'Shop the Collection',
      'primaryColor': '#1E3A2F',
      'bgColor': '#FBF9F5',
      'preview_images': [
        'https://images.unsplash.com/photo-1608248597359-548762f928e0?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Aura Botanicals',
          'theme': {
            'colors': {
              'primary': '#1E3A2F',
              'secondary': '#5F7065',
              'accent': '#C98B50',
              'background': '#FBF9F5',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#1B2A22',
                'secondary': '#5C6B61',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {
              'headingFamily': 'Playfair Display',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'AURA BOTANICALS'},
          'items': [
            {'label': 'Shop', 'href': '#products'},
            {'label': 'Philosophy', 'href': '#story'},
            {'label': 'Order Now', 'href': '#products', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_aura_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'BIODYNAMIC HARVEST · 100% CERTIFIED ORGANIC',
                  'headline': 'Pure botanical science.\nUnfiltered radiance.',
                  'subheadline':
                      'Clinical efficacy rooted in alpine biodynamic harvesting. Clean, certified organic formulations that nourish and restore your natural skin barrier.',
                  'ctaText': 'Shop the Collection',
                  'ctaLink': '#products',
                  'secondaryCtaText': 'Our Sourcing Story',
                  'secondaryCtaLink': '#story',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1608248597359-548762f928e0?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Aura Botanicals Glass Bottles',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_aura_products',
                'component': 'products',
                'order': 1,
                'props': {
                  'title': 'The Essential Botanical Ritual',
                  'subtitle':
                      'Formulated without synthetic fragrance, parabens, sulfates, or artificial fillers.',
                  'items': [
                    {
                      'name': 'Rosehip Celestial Elixir',
                      'price': '\$68.00',
                      'description':
                          'Cold-pressed Rosa Canina, Bakuchiol 2%, and lipid restoration squalane.',
                      'image':
                          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Golden Hibiscus Hydrating Serum',
                      'price': '\$54.00',
                      'description':
                          'Multi-weight hyaluronic acid and alpine edelweiss extract for 48-hour cellular hydration.',
                      'image':
                          'https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Ceramide Barrier Melt Balm',
                      'price': '\$46.00',
                      'description':
                          'Wild-foraged sea buckthorn and oat lipids to soothe and repair stressed, dry skin.',
                      'image':
                          'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Midnight Jasmine Recovery Oil',
                      'price': '\$72.00',
                      'description':
                          'Night cellular rejuvenation oil infused with blue tansy and antioxidant CoQ10.',
                      'image':
                          'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_aura_features',
                'component': 'features',
                'order': 2,
                'props': {
                  'title': 'The Aura Formulation Standard',
                  'subtitle':
                      'Honoring nature\'s biological rhythms through ethical sourcing and cellular science.',
                  'items': [
                    {
                      'icon': '🌿',
                      'title': 'High-Elevation Wildcrafted',
                      'description':
                          'Plants harvested at peak vitality in clean Swiss alpine meadows above 1,500 meters.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Cold-Pressed Extraction',
                      'description':
                          'Zero heat processing to protect fragile antioxidant vitamins, omegas, and enzymes.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Violet Miron Glassware',
                      'description':
                          'Biophotonic glass vessels that block harmful light spectrums to maintain organic potency.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Dermatologist Tested',
                      'description':
                          'Hypoallergenic, non-comedogenic, and clinically certified for reactive, sensitive skin.',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_aura_story',
                'component': 'about',
                'order': 3,
                'props': {
                  'title': 'Rooted in Alpine Reverence',
                  'subtitle':
                      'Where ancient herbal wisdom meets clean cellular biology.',
                  'body':
                      'Founded by holistic biochemist Clara von Berg, Aura was created to replace multi-step synthetic routines with pure, biodynamic plant medicine. We cultivate and harvest flora in rhythm with natural seasons, producing small-batch elixirs that restore balance and radiance to modern skin.',
                  'image':
                      'https://images.unsplash.com/photo-1512290900672-1f02e75e5330?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_aura_testimonials',
                'component': 'testimonials',
                'order': 4,
                'props': {
                  'title': 'Celebrated by Beauty Editors & Dermatologists',
                  'subtitle':
                      'Real experiences from women who made the botanical transition.',
                  'items': [
                    {
                      'quote':
                          'Aura\'s Celestial Elixir has completely transformed my sensitive barrier. The morning radiance is nothing short of miraculous.',
                      'author': 'Sophie Laurent',
                      'role': 'Beauty Editor, Vogue Paris',
                      'avatar':
                          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
                    },
                    {
                      'quote':
                          'The rare skincare line where biological purity and clinical efficacy live in perfect harmony. My highest daily recommendation.',
                      'author': 'Dr. Marianne Brandt',
                      'role': 'Board-Certified Dermatologist, Zurich',
                      'avatar':
                          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_aura_cta',
                'component': 'cta',
                'order': 5,
                'props': {
                  'headline': 'Begin your botanical ritual with 15% off.',
                  'description':
                      'Join our circle to receive our seasonal harvest monograph, skincare guides, and private releases.',
                  'buttonText': 'Claim Your 15% Welcome',
                  'buttonLink': '#newsletter',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_aura_footer',
                'component': 'footer',
                'order': 6,
                'props': {
                  'copyright':
                      '© 2026 Aura Botanicals AG. Zurich · Geneva · Paris.',
                  'links': [
                    {'label': 'Ingredients Glossary', 'href': '#ingredients'},
                    {
                      'label': 'Sustainability Charter',
                      'href': '#sustainability',
                    },
                    {'label': 'Stockists', 'href': '#stockists'},
                    {'label': 'Shipping & Returns', 'href': '#shipping'},
                    {'label': 'Privacy Policy', 'href': '#privacy'},
                  ],
                },
                'styles': {'background': 'background'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-lumen',
      'slug': 'lumen-coffee',
      'name': 'Lumen Coffee',
      'industry': 'Food & drink',
      'badge': "EDITOR'S PICK",
      'is_featured': true,
      'is_public': true,
      'description':
          "Warm tones and rich storytelling for your neighborhood's next favorite.",
      'headline': 'Good coffee.\nBetter mornings.',
      'subheadline':
          'Single-origin beans from farms we visit, roasted in our shop and shipped same day.',
      'ctaText': 'Explore our coffee',
      'primaryColor': '#9E4B28',
      'bgColor': '#FAF7F2',
      'preview_images': [
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Lumen Coffee',
          'theme': {
            'colors': {
              'primary': '#9E4B28',
              'secondary': '#6B5E55',
              'accent': '#C97D5D',
              'background': '#FAF7F2',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#2C241E',
                'secondary': '#786C64',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {
              'headingFamily': 'Playfair Display',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'Lumen Coffee'},
          'items': [
            {'label': 'Menu', 'href': '#products'},
            {'label': 'Our Story', 'href': '#story'},
            {'label': 'Visit Us', 'href': '#visit', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_lumen_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': "EDITOR'S PICK · SPECIALTY ROASTERS",
                  'headline': 'Good coffee.\nBetter mornings.',
                  'subheadline':
                      'Single-origin beans from farms we visit, roasted in small batches in our shop and shipped same day.',
                  'ctaText': 'Explore our coffee',
                  'ctaLink': '#products',
                  'secondaryCtaText': 'Visit the Café',
                  'secondaryCtaLink': '#visit',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Lumen Coffee Hand-Poured Latte',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_lumen_products',
                'component': 'products',
                'order': 1,
                'props': {
                  'title': 'Signature Single-Origin Roasts',
                  'subtitle':
                      'Roasted on our 1968 cast-iron Probat roaster every Tuesday and Friday.',
                  'items': [
                    {
                      'name': 'Crema Espresso Blend',
                      'price': '\$19.50',
                      'description':
                          'Rich dark chocolate, hazelnut, and sweet caramel finish.',
                      'image':
                          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Ethiopia Yirgacheffe G1',
                      'price': '\$22.00',
                      'description':
                          'Bergamot jasmine, ripe peach, and sparkling bright floral notes.',
                      'image':
                          'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Guatemala Antigua Valley',
                      'price': '\$21.00',
                      'description':
                          'Brown sugar, red apple crisp, and silky milk chocolate body.',
                      'image':
                          'https://images.unsplash.com/photo-1587734195503-904fca47e0e9?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Cold Brew Reserve',
                      'price': '\$18.00',
                      'description':
                          '18-hour slow-steeped concentrate with cacao nib sweetness.',
                      'image':
                          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_lumen_story',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'From Farm to Cup: A Decade of Craft',
                  'subtitle':
                      'We believe coffee should taste of the soil it grew in and the hands that harvested it.',
                  'body':
                      'In 2016, we started roasting in an old brick garage in Portland with a simple commitment: visit every farm, pay fair direct prices, and celebrate each harvest\'s unique terroir. Today, Lumen is a community living room where neighbors gather over slow-poured Chemex brews and sourdough pastries.',
                  'image':
                      'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_lumen_visit',
                'component': 'visit',
                'order': 3,
                'props': {
                  'title': 'Visit Our Roastery & Café',
                  'subtitle':
                      'Stop by for a flight, warm pastries, or whole beans for home.',
                  'address':
                      '842 Pearl Street, Pearl District, Portland, OR 97209',
                  'hours':
                      'Mon – Fri: 7:00 AM – 5:30 PM\nSat – Sun: 8:00 AM – 6:00 PM',
                  'phone': '(503) 555-0192',
                  'ctaText': 'Get Directions',
                  'ctaLink': 'https://maps.google.com',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_lumen_cta',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Fresh beans roasted and delivered weekly',
                  'description':
                      'Join our monthly coffee club for 15% off and complimentary doorstep delivery.',
                  'buttonText': 'Subscribe & Save 15%',
                  'buttonLink': '#subscribe',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_lumen_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      '© 2026 Lumen Coffee Roasters LLC. Crafted in Portland, Oregon.',
                  'links': [
                    {'label': 'Shipping & Returns', 'href': '#shipping'},
                    {'label': 'Privacy Policy', 'href': '#privacy'},
                    {'label': 'Wholesale', 'href': '#wholesale'},
                  ],
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-marlow',
      'slug': 'studio-marlow',
      'name': 'Studio Marlow',
      'industry': 'Portfolio · Architecture',
      'badge': 'QUIETLY BOLD',
      'is_featured': true,
      'is_public': true,
      'description':
          'An understated canvas that lets your work do the talking.',
      'headline': 'Spaces for\nthe everyday.',
      'subheadline':
          'Homes, libraries and small civic spaces, designed with the people who use them.',
      'ctaText': 'View our work',
      'primaryColor': '#111827',
      'bgColor': '#FFFFFF',
      'preview_images': [
        'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Studio Marlow',
          'theme': {
            'colors': {
              'primary': '#111827',
              'secondary': '#6B7280',
              'accent': '#0284C7',
              'background': '#FFFFFF',
              'surface': '#F9FAFB',
              'text': {
                'primary': '#111827',
                'secondary': '#4B5563',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {
              'headingFamily': 'Plus Jakarta Sans',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'Studio Marlow'},
          'items': [
            {'label': 'Works', 'href': '#works'},
            {'label': 'Practice', 'href': '#practice'},
            {'label': 'Inquiries', 'href': '#contact', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_marlow_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'ARCHITECTURE & INTERIORS · COPENHAGEN',
                  'headline': 'Spaces for\nthe everyday.',
                  'subheadline':
                      'Homes, libraries, and small civic spaces, designed in quiet harmony with the people who inhabit them.',
                  'ctaText': 'View our work',
                  'ctaLink': '#works',
                  'secondaryCtaText': 'About Practice',
                  'secondaryCtaLink': '#practice',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Studio Marlow Courtyard Residence',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_marlow_works',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Selected Works (2024–2026)',
                  'subtitle':
                      'Architecture grounded in natural light, tactile materiality, and enduring proportion.',
                  'items': [
                    {
                      'icon': '✦',
                      'title': 'Villa Sora · Lake Como',
                      'description':
                          'Monolithic limestone villa framing alpine views, featuring internal courtyards and passive geothermal cooling.',
                    },
                    {
                      'icon': '✦',
                      'title': 'The Oakhaven Reading Pavilion',
                      'description':
                          'Light-timber public pavilion in Copenhagen constructed with local larch and acoustic clay plaster.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Nordic Atelier Residence',
                      'description':
                          'Sculptor studio with double-height northern clerestory windows and minimalist concrete living quarters.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_marlow_story',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'Quietly Bold Design Philosophy',
                  'subtitle':
                      'A studio founded on clarity, daylight, and deliberate restraint.',
                  'body':
                      'Studio Marlow was founded by Henrik Marlow and Clara Jensen with a core conviction: architecture should quiet the senses and elevate daily rituals. We collaborate with regional craftsmen, utilizing local limestones and lime washes to shape timeless spaces.',
                  'image':
                      'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_marlow_contact',
                'component': 'visit',
                'order': 3,
                'props': {
                  'title': 'Start a Conversation',
                  'subtitle':
                      'We accept a limited number of residential and cultural commissions annually.',
                  'address': 'Bredgade 42, 1260 København K, Denmark',
                  'hours': 'Monday – Friday: 9:00 AM – 6:00 PM CET',
                  'phone': '+45 32 94 88 10',
                  'ctaText': 'Send Inquiry',
                  'ctaLink': 'mailto:commissions@studiomarlow.arch',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_marlow_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright':
                      '© 2026 Studio Marlow Architects ApS. Copenhagen · Zurich.',
                },
                'styles': {'background': 'background'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-vaultpay',
      'slug': 'vaultpay',
      'name': 'VaultPay',
      'industry': 'Fintech & Banking',
      'badge': 'ENTERPRISE GRADE',
      'is_featured': true,
      'is_public': true,
      'description':
          'Next-generation banking infrastructure for borderless commerce with multi-currency accounts and sub-second settlement.',
      'headline': 'Global treasury.\nZero borders.',
      'subheadline':
          'Move money across 140+ countries with institutional FX spreads, automated tax compliance, and military-grade security.',
      'ctaText': 'Open an Account',
      'primaryColor': '#0D9488',
      'bgColor': '#0B1120',
      'preview_images': [
        'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'VaultPay',
          'theme': {
            'colors': {
              'primary': '#0D9488',
              'secondary': '#38BDF8',
              'accent': '#10B981',
              'background': '#0B1120',
              'surface': '#131D31',
              'text': {
                'primary': '#F8FAFC',
                'secondary': '#94A3B8',
                'inverse': '#0B1120',
              },
            },
            'typography': {
              'headingFamily': 'Plus Jakarta Sans',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'VaultPay'},
          'items': [
            {'label': 'Infrastructure', 'href': '#features'},
            {'label': 'Pricing', 'href': '#pricing'},
            {'label': 'Open Account', 'href': '#cta', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_vault_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'LICENSED FINANCIAL INSTITUTION · PCI-DSS LEVEL 1',
                  'headline': 'Global treasury.\nZero borders.',
                  'subheadline':
                      'Move capital across 140+ currencies with institutional FX rates, programmatic corporate cards, and instantaneous treasury routing.',
                  'ctaText': 'Open Account in 5 Mins',
                  'ctaLink': '#cta',
                  'secondaryCtaText': 'Explore API Docs ↗',
                  'secondaryCtaLink': '#features',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'VaultPay Global Card and Interface',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_vault_features',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Institutional Rails at Modern Speed',
                  'subtitle':
                      'Everything high-growth internet companies need to manage global cash flows.',
                  'items': [
                    {
                      'icon': '🌐',
                      'title': 'Multi-Currency Virtual IBANs',
                      'description':
                          'Accept EUR, USD, GBP, JPY, and SGD locally without predatory foreign exchange fees.',
                    },
                    {
                      'icon': '⚡',
                      'title': 'Sub-Second Global Settlement',
                      'description':
                          'Instant payment routing across SEPA Instant, FedNow, and SWIFT gpi networks.',
                    },
                    {
                      'icon': '💳',
                      'title': 'Programmatic Corporate Cards',
                      'description':
                          'Issue unlimited virtual and physical cards with customizable spend rules and receipt matching.',
                    },
                    {
                      'icon': '🛡️',
                      'title': 'Automated Tax & ERP Sync',
                      'description':
                          'Direct two-way synchronization with NetSuite, QuickBooks, Xero, and Sage.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_vault_stats',
                'component': 'statistics',
                'order': 2,
                'props': {
                  'title': 'Scale Without Friction',
                  'subtitle':
                      'Trusted by forward-thinking CFOs and fintech innovators.',
                  'metrics': [
                    {
                      'value': '\$14.2B+',
                      'label': 'Volume Processed',
                      'description': 'Annual transactions',
                    },
                    {
                      'value': '140+',
                      'label': 'Countries Supported',
                      'description': 'Local payout networks',
                    },
                    {
                      'value': '99.999%',
                      'label': 'Engine Uptime',
                      'description': 'Fault-tolerant architecture',
                    },
                    {
                      'value': '0.2s',
                      'label': 'Settlement Speed',
                      'description': 'Instant ledger finality',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_vault_pricing',
                'component': 'products',
                'order': 3,
                'props': {
                  'title': 'Transparent Global Pricing',
                  'subtitle':
                      'No monthly maintenance fees, hidden markups, or minimum deposit requirements.',
                  'items': [
                    {
                      'name': 'Starter Business',
                      'price': '\$0 / mo',
                      'description':
                          'Multi-currency IBANs, 5 virtual debit cards, 0.35% interbank FX spread.',
                      'image':
                          'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Scale Treasury',
                      'price': '\$99 / mo',
                      'description':
                          'FedNow & SEPA Instant priority rails, unlimited virtual cards, 0.18% FX spread.',
                      'image':
                          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Enterprise Banking',
                      'price': 'Custom',
                      'description':
                          'Dedicated treasury desk, custom ERP integrations, volume FX pricing under 0.08%.',
                      'image':
                          'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_vault_cta',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Modernize your global treasury today.',
                  'description':
                      'Open verified business accounts in under five minutes with zero paperwork.',
                  'buttonText': 'Open Free Account',
                  'buttonLink': '#register',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_vault_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      '© 2026 VaultPay Financial Technologies Inc. Banking services provided by partner member banks.',
                  'links': [
                    {'label': 'Security & Compliance', 'href': '#security'},
                    {'label': 'API Reference', 'href': '#api'},
                    {'label': 'Regulatory Disclosures', 'href': '#disclosures'},
                    {'label': 'Privacy Policy', 'href': '#privacy'},
                  ],
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-mono',
      'slug': 'mono-studio',
      'name': 'Mono Studio',
      'industry': 'Agency & Creative',
      'badge': 'AVANT-GARDE',
      'is_featured': true,
      'is_public': true,
      'description':
          'Multidisciplinary design and digital engineering studio shaping definitive brand identities and interactive web systems.',
      'headline': 'We craft products\nthat define categories.',
      'subheadline':
          'Partnering with ambitious founders and visionary brands to build transcendent digital products, design systems, and brand worlds.',
      'ctaText': 'View Case Studies',
      'primaryColor': '#000000',
      'bgColor': '#FAFAFA',
      'preview_images': [
        'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Mono Studio',
          'theme': {
            'colors': {
              'primary': '#000000',
              'secondary': '#52525B',
              'accent': '#DC2626',
              'background': '#FAFAFA',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#09090B',
                'secondary': '#71717A',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {
              'headingFamily': 'Space Grotesk',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'MONO STUDIO'},
          'items': [
            {'label': 'Works', 'href': '#works'},
            {'label': 'Capabilities', 'href': '#capabilities'},
            {'label': 'Start a Project', 'href': '#cta', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_mono_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge':
                      'AWWWARDS STUDIO OF THE YEAR 2025 · NEW YORK & TOKYO',
                  'headline': 'We craft products\nthat define categories.',
                  'subheadline':
                      'Partnering with ambitious founders and visionary brands to build transcendent digital products, design systems, and brand worlds.',
                  'ctaText': 'View Case Studies',
                  'ctaLink': '#works',
                  'secondaryCtaText': 'Studio Capabilities',
                  'secondaryCtaLink': '#capabilities',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Mono Studio Visual Engineering',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_mono_capabilities',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Core Disciplines of Practice',
                  'subtitle':
                      'Bridging holistic brand strategy with cutting-edge software execution.',
                  'items': [
                    {
                      'icon': '✦',
                      'title': 'Brand Architecture & Systems',
                      'description':
                          'Typographic identity design, visual design languages, motion guidelines, and strategic brand positioning.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Interactive 3D & Digital Platforms',
                      'description':
                          'High-performance WebGL experiences, interactive storytelling websites, and next-gen mobile apps.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Design Systems at Scale',
                      'description':
                          'Modular tokenized component libraries built for engineering scale across Figma, React, and Flutter.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_mono_works',
                'component': 'products',
                'order': 2,
                'props': {
                  'title': 'Selected Works (2024–2026)',
                  'subtitle':
                      'Recent commissions for category-defining pioneers.',
                  'items': [
                    {
                      'name': 'Chronos Health · Continuous Metabolic OS',
                      'price': 'Mobile & Brand Design',
                      'description':
                          'End-to-end identity, hardware packaging, and reactive mobile application for wearable health sensors.',
                      'image':
                          'https://images.unsplash.com/photo-1510519138171-cbe656418844?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Hyperion GT · Electric Hypercar Experience',
                      'price': 'Interactive WebGL',
                      'description':
                          'Real-time 3D automotive vehicle configurator and telemetry dashboard with raytraced lighting.',
                      'image':
                          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Nouveau Modern Art Archive',
                      'price': 'Digital Experience',
                      'description':
                          'Interactive museum archive showcasing 1,200 contemporary works with fluid spatial navigation.',
                      'image':
                          'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_mono_story',
                'component': 'about',
                'order': 3,
                'props': {
                  'title': 'Deliberate Precision Over Generic Volume',
                  'subtitle':
                      'We deliberately limit our practice to twelve partnerships annually.',
                  'body':
                      'Mono is an independent creative collective founded in New York and Tokyo. We believe software and design should possess the weight of physical architecture and the emotional resonance of cinema. We work directly with founders from napkin sketch to IPO.',
                  'image':
                      'https://images.unsplash.com/photo-1497215728101-856f4ea42174?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_mono_cta',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Have an ambitious project worth building?',
                  'description':
                      'Now accepting commissions and strategic partnerships for the upcoming calendar quarters.',
                  'buttonText': 'Start a Conversation',
                  'buttonLink': '#contact',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_mono_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      '© 2026 Mono Design Studio LLC. New York · Tokyo · London.',
                  'links': [
                    {'label': 'Twitter / X', 'href': '#x'},
                    {'label': 'Instagram', 'href': '#ig'},
                    {'label': 'Careers', 'href': '#careers'},
                    {'label': 'Colophon', 'href': '#colophon'},
                  ],
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-solstice',
      'slug': 'solstice-culinary',
      'name': 'Solstice Fine Dining',
      'industry': 'Restaurant & Hospitality',
      'badge': 'MICHELIN GUIDE 2026',
      'is_featured': true,
      'is_public': true,
      'description':
          'Modern wood-fired culinary experience celebrating hyper-seasonal regional harvests and biodynamic wine pairings.',
      'headline': 'Wood-fired craft.\nSeasonal reverence.',
      'subheadline':
          'An intimate sixteen-seat dining counter nestled in downtown Seattle, serving nightly multi-course tasting menus inspired by Pacific Northwest terroir.',
      'ctaText': 'Reserve a Table',
      'primaryColor': '#D97706',
      'bgColor': '#171412',
      'preview_images': [
        'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Solstice Fine Dining',
          'theme': {
            'colors': {
              'primary': '#D97706',
              'secondary': '#A16207',
              'accent': '#F59E0B',
              'background': '#171412',
              'surface': '#211D1A',
              'text': {
                'primary': '#FDF8F0',
                'secondary': '#A89F91',
                'inverse': '#171412',
              },
            },
            'typography': {
              'headingFamily': 'Playfair Display',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'SOLSTICE'},
          'items': [
            {'label': 'Menu', 'href': '#menu'},
            {'label': 'Our Philosophy', 'href': '#about'},
            {'label': 'Reservations', 'href': '#visit', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_solstice_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'TWO MICHELIN STARS · JAMES BEARD NOMINEE',
                  'headline': 'Wood-fired craft.\nSeasonal reverence.',
                  'subheadline':
                      'An intimate sixteen-seat dining counter serving nightly multi-course tasting menus guided by today\'s wild foraging and coastal catch.',
                  'ctaText': 'Reserve via Resy',
                  'ctaLink': '#visit',
                  'secondaryCtaText': 'Tonight\'s Tasting Menu',
                  'secondaryCtaLink': '#menu',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Solstice Wood-Fired Hearth Dish',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_solstice_menu',
                'component': 'products',
                'order': 1,
                'props': {
                  'title': 'Spring Tasting Menu Highlights',
                  'subtitle':
                      'Twelve courses prepared over applewood and alder embers in our open kitchen.',
                  'items': [
                    {
                      'name': 'Ember-Roasted Copper River Salmon',
                      'price': '\$48',
                      'description':
                          'Wild coastal salmon roasted on Japanese binchotan, elderflower glaze, and foraged spruce tips.',
                      'image':
                          'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Heritage Wheat Agnolotti',
                      'price': '\$42',
                      'description':
                          'Hand-rolled pasta filled with roasted parsnip, cultured butter emulsion, and shaved black winter truffle.',
                      'image':
                          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Cedar-Smoked A5 Miyazaki Wagyu',
                      'price': '\$78',
                      'description':
                          'Wagyu striploin rested over cedar boughs, charred spring ramps, and fermented morel mushroom jus.',
                      'image':
                          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Caramelized Birch Mille-Feuille',
                      'price': '\$22',
                      'description':
                          'Flaky caramelized puff pastry, smoked birch syrup Diplomat cream, and sea salt wildflower honeycomb.',
                      'image':
                          'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_solstice_story',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'Honoring Hearth and Heritage',
                  'subtitle':
                      'Cooking over open flame with ingredients harvested within 100 miles.',
                  'body':
                      'Solstice was created by Chef Julian Mercer to celebrate the untamed abundance of the Pacific Northwest. Every evening, our kitchen gathers around our custom open wood hearth, cooking with alderwood, birch, and applewood embers. We work directly with small family divers, wild foragers, and organic growers.',
                  'image':
                      'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_solstice_visit',
                'component': 'visit',
                'order': 3,
                'props': {
                  'title': 'Dining Counter & Reservations',
                  'subtitle':
                      'Bookings release on the 1st of every month at 9:00 AM PST for the following month.',
                  'address': '512 Pike Street, Downtown Seattle, WA 98101',
                  'hours':
                      'Wednesday – Sunday: Two Seatings at 5:30 PM & 8:30 PM\nClosed Monday & Tuesday',
                  'phone': '(206) 555-0144',
                  'ctaText': 'Reserve via Resy',
                  'ctaLink': 'https://resy.com',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_solstice_cta',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Reserve an evening at our sixteen-seat counter.',
                  'description':
                      'Complimentary biodynamic wine pairings and temperance botanical infusions available.',
                  'buttonText': 'Find a Reservation',
                  'buttonLink': '#visit',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_solstice_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      '© 2026 Solstice Culinary Group LLC. Seattle, Washington.',
                  'links': [
                    {'label': 'Tasting Menu PDF', 'href': '#menu'},
                    {'label': 'Private Buyouts', 'href': '#private'},
                    {'label': 'Cellar List', 'href': '#wine'},
                    {'label': 'Press Inquiries', 'href': '#press'},
                  ],
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-kite',
      'slug': 'kite-yoga',
      'name': 'Kite Yoga',
      'industry': 'Wellness',
      'badge': 'ROOM TO BREATHE',
      'is_featured': true,
      'is_public': true,
      'description':
          'Earthy, open and easy to explore. A little space to breathe.',
      'headline': 'Find your\nkind of balance.',
      'subheadline':
          'Small classes in a sunlit studio, timers to daily practice.',
      'ctaText': 'Find a class',
      'primaryColor': '#5D6B50',
      'bgColor': '#FAF8F4',
      'preview_images': [
        'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Kite Yoga',
          'theme': {
            'colors': {
              'primary': '#5D6B50',
              'secondary': '#8C9B81',
              'accent': '#C48B71',
              'background': '#FAF8F4',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#2D3428',
                'secondary': '#6B7465',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {'headingFamily': 'Inter', 'bodyFamily': 'Inter'},
          },
        },
        'navigation': {
          'logo': {'text': 'Kite Yoga'},
          'items': [
            {'label': 'Classes', 'href': '#classes'},
            {'label': 'Pricing', 'href': '#pricing'},
            {'label': 'Find a Class', 'href': '#classes', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_kite_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'HOLISTIC MOVEMENT & MINDFULNESS',
                  'headline': 'Find your\nkind of balance.',
                  'subheadline':
                      'Small mindful classes in a sunlit sanctuary. A little space to breathe, restore, and connect with your breath.',
                  'ctaText': 'Find a class',
                  'ctaLink': '#classes',
                  'secondaryCtaText': 'View Passes',
                  'secondaryCtaLink': '#pricing',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Kite Yoga Sunlit Studio',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_kite_classes',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Mindful Practices for Every Body',
                  'subtitle':
                      'Led by certified somatic and Ashtanga teachers with over a decade of personal study.',
                  'items': [
                    {
                      'icon': '✦',
                      'title': 'Morning Vinyasa Flow',
                      'description':
                          'Dynamic sequences linking breath with movement to energize your focus and awaken physical vitality.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Restorative Yin & Sound',
                      'description':
                          'Supported floor postures with singing bowls and gentle hands-on assists to release tension.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Pranayama & Meditation',
                      'description':
                          'Ancient breathing exercises and guided stillness to balance the nervous system.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_kite_pricing',
                'component': 'products',
                'order': 2,
                'props': {
                  'title': 'Class Passes & Memberships',
                  'subtitle':
                      'No contracts, no cancellation fees. Complimentary Manduka mat rental and herbal tea.',
                  'items': [
                    {
                      'name': 'Single Drop-in',
                      'price': '\$25',
                      'description':
                          'Access to any 60 or 75-minute studio class. Includes mat rental.',
                      'image':
                          'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': '10-Class Pack',
                      'price': '\$210',
                      'description':
                          'Valid for 6 months across all styles. Shareable with a guest.',
                      'image':
                          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=600&q=80',
                    },
                    {
                      'name': 'Monthly Unlimited',
                      'price': '\$165/mo',
                      'description':
                          'Unlimited daily classes, 15% off workshops, and access to online library.',
                      'image':
                          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80',
                    },
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_kite_story',
                'component': 'about',
                'order': 3,
                'props': {
                  'title': 'Room to Breathe',
                  'subtitle':
                      'A non-competitive space nestled above the trees.',
                  'body':
                      'We founded Kite Yoga because the modern world has enough hurry. Here, the floorboards are reclaimed cedar, natural light filters through linen shades, and phones stay in cubbies. Whether you have practiced for twenty years or twenty minutes, you are welcome here.',
                  'image':
                      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_kite_visit',
                'component': 'visit',
                'order': 4,
                'props': {
                  'title': 'Studio Location & Hours',
                  'address': '214 Pine Street, 2nd Floor, Austin, TX 78701',
                  'hours':
                      'Mon – Fri: 6:30 AM – 8:30 PM\nSat – Sun: 8:00 AM – 6:00 PM',
                  'phone': '(512) 555-0184',
                  'ctaText': 'Studio Directions',
                  'ctaLink': 'https://maps.google.com',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_kite_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright': '© 2026 Kite Yoga Studio LLC. Austin, Texas.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-ana-teo',
      'slug': 'ana-teo',
      'name': 'Ana & Teo',
      'industry': 'Weddings',
      'badge': 'MADE FOR MOMENTS',
      'is_featured': true,
      'is_public': true,
      'description':
          'Romantic details and a story-led layout for your once-in-a-lifetime day.',
      'headline': 'Together is\na beautiful place.',
      'subheadline':
          'Join us under the olive trees in Tuscany to celebrate our wedding with family and friends.',
      'ctaText': 'Our story',
      'primaryColor': '#4A1525',
      'bgColor': '#FDFBF7',
      'preview_images': [
        'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Ana & Teo',
          'theme': {
            'colors': {
              'primary': '#4A1525',
              'secondary': '#8C5967',
              'accent': '#C9975D',
              'background': '#FDFBF7',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#331B22',
                'secondary': '#73565F',
                'inverse': '#FFFFFF',
              },
            },
            'typography': {
              'headingFamily': 'Playfair Display',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'Ana & Teo'},
          'items': [
            {'label': 'Our Story', 'href': '#story'},
            {'label': 'The Weekend', 'href': '#schedule'},
            {'label': 'RSVP', 'href': '#rsvp', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_ana_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'JUNE 12–14, 2026 · FIESOLE, TUSCANY',
                  'headline': 'Together is\na beautiful place.',
                  'subheadline':
                      'Join us under the olive groves of Tuscany as we exchange our vows and celebrate love, friendship, and family.',
                  'ctaText': 'Our story',
                  'ctaLink': '#story',
                  'secondaryCtaText': 'RSVP by April 15',
                  'secondaryCtaLink': '#rsvp',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Ana and Teo in Tuscany',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_ana_schedule',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'The Wedding Weekend Itinerary',
                  'subtitle':
                      'Three days of festivities in the sunlit hills overlooking Florence.',
                  'items': [
                    {
                      'icon': '✦',
                      'title': 'Friday Welcome Aperitivo',
                      'description':
                          'June 12, 6:30 PM · Trattoria al Poggio. Tuscan wines, woodfired pizza, and live acoustic music under the stars.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Saturday Ceremony & Banquet',
                      'description':
                          'June 13, 4:00 PM · Villa San Michele. Vows under ancient cypress trees followed by a courtyard feast and dancing.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Sunday Farewell Brunch',
                      'description':
                          'June 14, 10:30 AM · Poolside Terrace. Fresh espresso, pastries, fruit, and warm send-offs.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_ana_story',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'Eight Years of Adventures',
                  'subtitle':
                      'From a rainy coffee shop in Brooklyn to the cobblestones of Florence.',
                  'body':
                      'We first locked eyes on a wet Tuesday afternoon at a Brooklyn bookstore. Five apartments, two adopted rescue dogs, twenty-four stamps in our passports, and hundreds of bowls of pasta later, Teo proposed at sunrise overlooking the Arno river. We cannot wait to celebrate our next chapter with everyone we cherish most.',
                  'image':
                      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_ana_travel',
                'component': 'visit',
                'order': 3,
                'props': {
                  'title': 'Travel & Accommodations',
                  'subtitle': 'Villa San Michele, Fiesole (Firenze), Italy.',
                  'address': 'Via Doccia 4, 50014 Fiesole (Firenze), Italy',
                  'hours':
                      'Airport: Florence Peretola (FLR) 25 mins · Pisa (PSA) 75 mins\nComplimentary shuttles from Florence Santa Maria Novella station.',
                  'ctaText': 'View Lodging Details',
                  'ctaLink': '#lodging',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_ana_rsvp',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Kindly RSVP by April 15, 2026',
                  'description':
                      'Please confirm your attendance and let us know about any dietary preferences or shuttle requests.',
                  'buttonText': 'Submit Your RSVP',
                  'buttonLink': '#rsvp',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_ana_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      'Ana & Teo · June 12–14, 2026 · Fiesole, Tuscany. With love.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
  ];
}
