import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/models/website.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/ad_service.dart';
import '../../core/storage/session_manager.dart';
import '../dashboard/dashboard_controller.dart';
import '../profile/components/subscription_plan_sheet.dart';
import '../subscription/subscription_view.dart';

class TemplatesController extends GetxController {
  final templates = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  final activeTab = 'For you'.obs;
  final tabs = [
    'For you',
    'Startups',
    'Business',
    'Weddings',
    'Personal',
    'Creative',
  ];

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
    AdService.instance.preloadVideoAd(adTag: 'create_template_website');
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
        final combined = <Map<String, dynamic>>[...list];
        for (final fallback in fallbackTemplates) {
          final id = fallback['id']?.toString() ?? '';
          final slug = fallback['slug']?.toString() ?? '';
          final name = (fallback['name'] ?? '').toString().toLowerCase();
          final exists = combined.any((t) =>
              t['id']?.toString() == id ||
              t['slug']?.toString() == slug ||
              (t['name'] ?? '').toString().toLowerCase() == name);
          if (!exists) {
            combined.add(fallback);
          }
        }
        templates.assignAll(combined);
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
        'elysian-vows',
        'devflow',
        'marcus-vance',
        'apex-capital',
        'botanical-vows',
        'pulse-health',
        'elena-rostova',
        'nordic-craft',
        'ana-teo',
        'kai-thorne',
        'lumen-coffee',
        'aura-botanicals',
        'studio-marlow',
        'vaultpay',
        'mono-studio',
        'solstice-culinary',
        'kite-yoga',
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
    } else if (tab == 'Startups') {
      list = list.where((t) {
        final ind = (t['industry'] ?? '').toString().toLowerCase();
        final cat = (t['category']?['slug'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        return ind.contains('startup') ||
            ind.contains('saas') ||
            ind.contains('tech') ||
            ind.contains('ai') ||
            ind.contains('dev') ||
            ind.contains('cloud') ||
            ind.contains('fintech') ||
            ind.contains('healthtech') ||
            ind.contains('app') ||
            cat.contains('saas') ||
            cat.contains('startups') ||
            name.contains('nexus') ||
            name.contains('devflow') ||
            name.contains('pulse') ||
            name.contains('vault');
      }).toList();
    } else if (tab == 'Business') {
      list = list.where((t) {
        final ind = (t['industry'] ?? '').toString().toLowerCase();
        final cat = (t['category']?['slug'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        return ind.contains('business') ||
            ind.contains('capital') ||
            ind.contains('advisory') ||
            ind.contains('finance') ||
            ind.contains('food') ||
            ind.contains('drink') ||
            ind.contains('coffee') ||
            ind.contains('roast') ||
            ind.contains('café') ||
            ind.contains('restaurant') ||
            ind.contains('hospitality') ||
            ind.contains('skincare') ||
            ind.contains('dining') ||
            ind.contains('retail') ||
            cat.contains('business') ||
            cat.contains('restaurants') ||
            cat.contains('local-business') ||
            cat.contains('ecommerce') ||
            name.contains('lumen') ||
            name.contains('aura') ||
            name.contains('apex') ||
            name.contains('solstice') ||
            name.contains('nordic') ||
            name.contains('bistro');
      }).toList();
    } else if (tab == 'Weddings') {
      list = list.where((t) {
        final ind = (t['industry'] ?? '').toString().toLowerCase();
        final cat = (t['category']?['slug'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        final desc = (t['description'] ?? '').toString().toLowerCase();
        return ind.contains('wedding') ||
            ind.contains('vow') ||
            ind.contains('celebration') ||
            ind.contains('ceremony') ||
            ind.contains('bridal') ||
            cat.contains('weddings') ||
            cat.contains('wedding') ||
            desc.contains('wedding') ||
            name.contains('ana') ||
            name.contains('elysian') ||
            name.contains('botanical') ||
            name.contains('vows');
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
            ind.contains('photography') ||
            ind.contains('editorial') ||
            ind.contains('identity') ||
            cat.contains('portfolios') ||
            cat.contains('agencies') ||
            cat.contains('photography') ||
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
        return ind.contains('personal') ||
            ind.contains('portfolio') ||
            ind.contains('author') ||
            ind.contains('thought') ||
            ind.contains('leadership') ||
            ind.contains('speaker') ||
            ind.contains('engineer') ||
            ind.contains('creator') ||
            ind.contains('wellness') ||
            ind.contains('yoga') ||
            ind.contains('coach') ||
            cat.contains('portfolios') ||
            cat.contains('fitness') ||
            cat.contains('personal') ||
            name.contains('marcus') ||
            name.contains('elena') ||
            name.contains('kai') ||
            name.contains('kite');
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
      AdService.instance.showVideoAd(adTag: 'create_template_website');
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
    {
      'id': 'tmpl-elysian-vows',
      'slug': 'elysian-vows',
      'name': 'Elysian Vows',
      'industry': 'Weddings & Celebrations',
      'badge': '✦ EDITORIAL ROMANCE',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Warm candlelight, lakeside terraces, and an intimate celebration layout on Lake Como.',
      'headline': 'Two Lives.\nOne Timeless Evening.',
      'subheadline':
          'Join Sophia & Julian as we exchange vows under the wisteria pergolas of Villa Balbianello, Lake Como.',
      'ctaText': 'RSVP by May 1',
      'primaryColor': '#B38E5D',
      'bgColor': '#FAF8F5',
      'preview_images': [
        'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Sophia & Julian',
          'theme': {
            'colors': {
              'primary': '#B38E5D',
              'secondary': '#786C5E',
              'accent': '#D4AF37',
              'background': '#FAF8F5',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#24211E',
                'secondary': '#6B635B',
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
          'logo': {'text': 'Sophia & Julian'},
          'items': [
            {'label': 'Our Story', 'href': '#story'},
            {'label': 'Schedule', 'href': '#schedule'},
            {'label': 'Travel', 'href': '#travel'},
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
                'id': 'sec_elysian_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'SEPTEMBER 18–20, 2026 · VILLA BALBIANELLO, LAKE COMO',
                  'headline': 'Two Lives.\nOne Timeless Evening.',
                  'subheadline':
                      'We invite our nearest and dearest to join us along the shores of Lake Como to celebrate love, family, and lifelong devotion.',
                  'ctaText': 'RSVP by May 1',
                  'ctaLink': '#rsvp',
                  'secondaryCtaText': 'Our Story ↗',
                  'secondaryCtaLink': '#story',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Sophia and Julian at Lake Como',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_elysian_schedule',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Celebration Itinerary',
                  'subtitle':
                      'A three-day gathering among the historic gardens and waters of Como.',
                  'items': [
                    {
                      'icon': '✦',
                      'title': 'Friday Welcome Prosecco',
                      'description':
                          'Sept 18, 6:00 PM · Grand Hotel Tremezzo Terrace. Sunset cocktails, antipasti, and lakeside jazz.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Saturday Vows & Gala',
                      'description':
                          'Sept 19, 4:30 PM · Villa Balbianello. Garden ceremony overlooking the lake followed by banquet dinner and dancing.',
                    },
                    {
                      'icon': '✦',
                      'title': 'Sunday Lakeside Brunch',
                      'description':
                          'Sept 20, 11:00 AM · Bellagio Pier. Fresh pastries, espresso, and private wooden boat excursions.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_elysian_story',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'How We Met',
                  'subtitle':
                      'Seven years of laughter, shared passports, and endless coffee.',
                  'body':
                      'From our first spontaneous encounter in a sunlit Montmartre gallery to building a life together across three cities, every milestone has brought us closer. We cannot wait to begin this sacred next chapter surrounded by the people who mean the world to us.',
                  'image':
                      'https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_elysian_travel',
                'component': 'visit',
                'order': 3,
                'props': {
                  'title': 'Travel & Accommodations',
                  'subtitle': 'Villa Balbianello, Lenno, Lake Como, Italy',
                  'address': 'Via Guido Monzino 1, 22016 Tremezzina CO, Italy',
                  'hours':
                      'Milan Malpensa Airport (MXP) is 60 minutes away. Private ferry shuttles depart every hour from Como San Giovanni station.',
                  'ctaText': 'View Room Blocks',
                  'ctaLink': '#rooms',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_elysian_rsvp',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Kindly RSVP by May 1, 2026',
                  'description':
                      'Please let us know if you can celebrate with us and provide dietary requirements or song requests.',
                  'buttonText': 'Confirm Attendance',
                  'buttonLink': '#rsvp',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_elysian_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      'Sophia & Julian · September 2026 · Lake Como, Italy. With love.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-botanical-vows',
      'slug': 'botanical-vows',
      'name': 'Botanical Romance',
      'industry': 'Weddings & Celebrations',
      'badge': '✦ WILDFLOWER GARDEN',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Sunlit coastal redwoods, organic wildflower florals, and outdoor dinner celebration in Big Sur.',
      'headline': 'Under the Stars,\nSurrounded by Nature.',
      'subheadline':
          'Join Maya & Liam in the coastal highlands of Big Sur for a weekend of vows, acoustic melodies, and woodland feast.',
      'ctaText': 'RSVP by June 15',
      'primaryColor': '#2D4739',
      'bgColor': '#F6F7F3',
      'preview_images': [
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Maya & Liam',
          'theme': {
            'colors': {
              'primary': '#2D4739',
              'secondary': '#4A6B56',
              'accent': '#D97706',
              'background': '#F6F7F3',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#1A241E',
                'secondary': '#4D5E53',
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
          'logo': {'text': 'Maya & Liam'},
          'items': [
            {'label': 'Schedule', 'href': '#schedule'},
            {'label': 'Our Story', 'href': '#story'},
            {'label': 'Guest FAQ', 'href': '#faq'},
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
                'id': 'sec_botanical_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': 'AUGUST 14–16, 2026 · BIG SUR, CALIFORNIA',
                  'headline': 'Under the Stars,\nSurrounded by Nature.',
                  'subheadline':
                      'Two paths intertwining beneath the ancient redwoods. Come share music, wine, and warm memories with us on the Pacific ridge.',
                  'ctaText': 'RSVP by June 15',
                  'ctaLink': '#rsvp',
                  'secondaryCtaText': 'Weekend Schedule ↗',
                  'secondaryCtaLink': '#schedule',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Maya and Liam outdoor wedding',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_botanical_schedule',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Weekend Gatherings',
                  'subtitle': 'A rustic coastal celebration from dawn till dusk.',
                  'items': [
                    {
                      'icon': '🌿',
                      'title': 'Friday Bonfire & Tacos',
                      'description':
                          'Aug 14, 7:00 PM · Redwood Glade. Local Baja-style tacos, local craft cider, and acoustic guitar by the firepit.',
                    },
                    {
                      'icon': '🌸',
                      'title': 'Saturday Forest Ceremony',
                      'description':
                          'Aug 15, 3:30 PM · The Cathedral Grove. Exchange of vows followed by family-style farm dinner under twinkle lights.',
                    },
                    {
                      'icon': '☀️',
                      'title': 'Sunday Morning Coffee & Pastries',
                      'description':
                          'Aug 16, 9:30 AM · The Overlook Deck. Pour-over bar, fresh pastries, and warm hugs before journeying home.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_botanical_story',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'Our Journey Together',
                  'subtitle':
                      'From trail runs in Marin to building our dream homestead.',
                  'body':
                      'We met at a trail race in 2019, both reaching for the same post-run orange slice. Six years, countless mountain peaks, and one rambunctious golden retriever later, we are overjoyed to say "I do" in the place where we feel most at home: outdoors.',
                  'image':
                      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_botanical_faq',
                'component': 'faq',
                'order': 3,
                'props': {
                  'title': 'Guest Information & FAQ',
                  'subtitle':
                      'Everything you need to know for our mountain weekend.',
                  'items': [
                    {
                      'question': 'What is the dress code?',
                      'answer':
                          'Garden cocktail attire. Please note that the ceremony and dinner are on grassy terrain, so wedges, block heels, or flats are strongly recommended.',
                    },
                    {
                      'question': 'How do we get to the venue?',
                      'answer':
                          'We are providing shuttles from Carmel Valley hotels. Mountain parking is limited, so we encourage taking the group shuttles.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_botanical_rsvp',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Will You Join Our Celebration?',
                  'description':
                      'Please let us know your RSVP by June 15, 2026 so we can finalize our farm-to-table banquet seats.',
                  'buttonText': 'Confirm Attendance',
                  'buttonLink': '#rsvp',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_botanical_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright':
                      'Maya & Liam · August 2026 · Big Sur, California. Forever.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-devflow',
      'slug': 'devflow',
      'name': 'DevFlow Cloud',
      'industry': 'Startups & Developer Tools',
      'badge': '✦ NEXT-GEN DEVOPS',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Instant preview branches, zero-config staging environments, and edge CI/CD for high-velocity engineering teams.',
      'headline': 'Instant Preview Branches\nfor Every Git Commit.',
      'subheadline':
          'Spin up isolated full-stack preview branches in 200ms with branched Postgres databases, ephemeral DNS, and automated synthetic tests.',
      'ctaText': 'Deploy Free with GitHub',
      'primaryColor': '#10B981',
      'bgColor': '#0A0F1D',
      'preview_images': [
        'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'DevFlow Cloud',
          'theme': {
            'colors': {
              'primary': '#10B981',
              'secondary': '#34D399',
              'accent': '#6EE7B7',
              'background': '#0A0F1D',
              'surface': '#131B2E',
              'text': {
                'primary': '#F8FAFC',
                'secondary': '#94A3B8',
                'inverse': '#0A0F1D',
              },
            },
            'typography': {
              'headingFamily': 'Plus Jakarta Sans',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'DevFlow Cloud'},
          'items': [
            {'label': 'Features', 'href': '#features'},
            {'label': 'Metrics', 'href': '#metrics'},
            {'label': 'Pricing', 'href': '#pricing'},
            {'label': 'Start Free', 'href': '#cta', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_devflow_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ YC S25 LAUNCH · 200MS COLD STARTS',
                  'headline': 'Instant Preview Branches\nfor Every Git Commit.',
                  'subheadline':
                      'Zero Kubernetes config. Zero staging bottlenecks. Deploy production-identical branch environments with isolated database copies in seconds.',
                  'ctaText': 'Deploy Free with GitHub',
                  'ctaLink': '#cta',
                  'secondaryCtaText': 'View Live Interactive Demo ↗',
                  'secondaryCtaLink': '#features',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'DevFlow Cloud Terminal & Preview Interface',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_devflow_features',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Engineered for High-Velocity Engineering',
                  'subtitle':
                      'Eliminate staging bottlenecks and merge conflicts permanently.',
                  'items': [
                    {
                      'icon': '⚡',
                      'title': 'Branched Postgres Databases',
                      'description':
                          'Copy-on-write database clones with real anonymized schemas and instant rollbacks.',
                    },
                    {
                      'icon': '🌐',
                      'title': 'Global Anycast Edge CDN',
                      'description':
                          'Sub-15ms TTFB routing across 180 global regions with automatic SSL provisioning.',
                    },
                    {
                      'icon': '🔒',
                      'title': 'SOC-2 Type II Certified',
                      'description':
                          'Enterprise-grade security, automated secrets injection, and fine-grained RBAC.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_devflow_stats',
                'component': 'statistics',
                'order': 2,
                'props': {
                  'title': 'Battle-Tested at Scale',
                  'subtitle': 'Trusted by the world\'s fastest-growing developer teams.',
                  'items': [
                    {'value': '200ms', 'label': 'Average Cold Start'},
                    {'value': '4.2M+', 'label': 'Preview Branches Deployed'},
                    {'value': '99.999%', 'label': 'Production SLA Uptime'},
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_devflow_pricing',
                'component': 'pricing',
                'order': 3,
                'props': {
                  'title': 'Predictable Pricing for Fast Teams',
                  'subtitle': 'Start free on hobby branches. Scale with your engineering roadmap.',
                  'items': [
                    {
                      'name': 'Hobby',
                      'price': '\$0 / month',
                      'description': 'For solo creators and side projects.',
                      'badge': 'FREE FOREVER',
                      'buttonText': 'Start Free',
                      'features': [
                        'Up to 5 active preview branches',
                        'Community Discord support',
                        'Shared compute resources',
                      ],
                    },
                    {
                      'name': 'Startup Pro',
                      'price': '\$49 / month',
                      'description': 'For high-velocity startups and scaling teams.',
                      'badge': 'MOST POPULAR',
                      'buttonText': 'Start 14-Day Trial',
                      'features': [
                        'Unlimited preview branches',
                        'Isolated copy-on-write databases',
                        'Priority edge deployment',
                        'GitHub & GitLab PR bot integrations',
                      ],
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_devflow_cta',
                'component': 'cta',
                'order': 4,
                'props': {
                  'headline': 'Ship Software 4x Faster Today',
                  'description':
                      'Connect your GitHub repository and have your first preview branch live in under 60 seconds.',
                  'buttonText': 'Get Started Free',
                  'buttonLink': '#start',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_devflow_footer',
                'component': 'footer',
                'order': 5,
                'props': {
                  'copyright': '© 2026 DevFlow Cloud, Inc. Built for developers.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-pulse-health',
      'slug': 'pulse-health',
      'name': 'Pulse Health AI',
      'industry': 'Startups & HealthTech',
      'badge': '✦ BIOMETRIC INTELLIGENCE',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Continuous biosensing paired with autonomous intelligence to optimize metabolic energy and daily cognitive focus.',
      'headline': 'Metabolic Intelligence\nfor Peak Daily Focus.',
      'subheadline':
          'Real-time biomarker telemetry meets predictive AI to optimize your focus windows, nutrition, and cardiovascular recovery.',
      'ctaText': 'Order Sensor Kit',
      'primaryColor': '#0EA5E9',
      'bgColor': '#080C14',
      'preview_images': [
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Pulse Health AI',
          'theme': {
            'colors': {
              'primary': '#0EA5E9',
              'secondary': '#14B8A6',
              'accent': '#38BDF8',
              'background': '#080C14',
              'surface': '#0F172A',
              'text': {
                'primary': '#F8FAFC',
                'secondary': '#94A3B8',
                'inverse': '#080C14',
              },
            },
            'typography': {
              'headingFamily': 'Plus Jakarta Sans',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'Pulse Health AI'},
          'items': [
            {'label': 'Science', 'href': '#science'},
            {'label': 'Features', 'href': '#features'},
            {'label': 'Kit', 'href': '#pricing'},
            {'label': 'Order Now', 'href': '#cta', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_pulse_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ CLINICAL METABOLIC INTELLIGENCE',
                  'headline': 'Metabolic Intelligence\nfor Peak Daily Focus.',
                  'subheadline':
                      'Continuous interstitial glucose and autonomic biomarker sensing paired with personalized algorithmic insights to prevent energy slumps and maximize daily output.',
                  'ctaText': 'Order Sensor Kit',
                  'ctaLink': '#cta',
                  'secondaryCtaText': 'Read Clinical Studies ↗',
                  'secondaryCtaLink': '#science',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Pulse Biosensor & Live Mobile App',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_pulse_features',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Precision Biology Meets Machine Learning',
                  'subtitle': 'Transform complex physiological signals into simple daily decisions.',
                  'items': [
                    {
                      'icon': '🧬',
                      'title': 'Real-Time Glycemic Tracking',
                      'description':
                          'Understand your unique insulin sensitivity and avoid afternoon brain fog permanently.',
                    },
                    {
                      'icon': '🧠',
                      'title': 'Autonomic Focus Predictor',
                      'description':
                          'Algorithmic recommendations on when to tackle deep strategic work based on HRV stability.',
                    },
                    {
                      'icon': '🌙',
                      'title': 'Sleep Architecture Optimization',
                      'description':
                          'Targeted interventions to increase restorative slow-wave sleep and REM duration.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_pulse_stats',
                'component': 'statistics',
                'order': 2,
                'props': {
                  'title': 'Proven Clinical Outcomes',
                  'subtitle': 'Validated across 12,000+ member clinical trials.',
                  'items': [
                    {'value': '89%', 'label': 'Reduced Daily Fatigue'},
                    {'value': '3.4x', 'label': 'Sustained Morning Focus'},
                    {'value': '14-Day', 'label': 'Continuous Sensor Life'},
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_pulse_cta',
                'component': 'cta',
                'order': 3,
                'props': {
                  'headline': 'Reclaim Your Biology Today',
                  'description':
                      'Join 45,000+ executives, athletes, and founders who optimize their health with Pulse Health AI.',
                  'buttonText': 'Reserve Your Kit',
                  'buttonLink': '#kit',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_pulse_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright': '© 2026 Pulse Health AI. Medical grade intelligence.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-marcus-vance',
      'slug': 'marcus-vance',
      'name': 'Dr. Marcus Vance',
      'industry': 'Personal & Thought Leadership',
      'badge': '✦ NYT BESTSELLING AUTHOR',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Stanford neuroscientist, keynote speaker, and author of "The Focused Mind" exploring high-performance cognition.',
      'headline': 'Demystifying High-Performance\nCognition & Focus.',
      'subheadline':
          'Keynote lectures, executive briefings, and evidence-backed neurobiology research for leaders shaping the future.',
      'ctaText': 'Book Keynote Lecture',
      'primaryColor': '#8B5E3C',
      'bgColor': '#FAF6F0',
      'preview_images': [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Dr. Marcus Vance',
          'theme': {
            'colors': {
              'primary': '#8B5E3C',
              'secondary': '#60432C',
              'accent': '#C99757',
              'background': '#FAF6F0',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#1E1A17',
                'secondary': '#5E544B',
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
          'logo': {'text': 'Dr. Marcus Vance'},
          'items': [
            {'label': 'Books', 'href': '#books'},
            {'label': 'Keynotes', 'href': '#keynotes'},
            {'label': 'Research', 'href': '#about'},
            {'label': 'Inquire', 'href': '#contact', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_marcus_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ STANFORD NEUROSCIENCE · NYT BESTSELLER',
                  'headline': 'Demystifying High-Performance\nCognition & Focus.',
                  'subheadline':
                      'Bridging molecular neuroscience and executive leadership. Author of the international bestseller "The Focused Mind" read by over 500,000 decision makers.',
                  'ctaText': 'Book Keynote Lecture',
                  'ctaLink': '#contact',
                  'secondaryCtaText': 'Explore Essays & Books ↗',
                  'secondaryCtaLink': '#books',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Dr. Marcus Vance',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_marcus_keynotes',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Signature Keynote Lectures',
                  'subtitle': 'Equipping global audiences with practical cognitive frameworks.',
                  'items': [
                    {
                      'icon': '🎯',
                      'title': 'Architectures of Focus',
                      'description':
                          'How attentional circuits function in the modern distractible world, and actionable protocols to trigger deep work flow states.',
                    },
                    {
                      'icon': '⚖️',
                      'title': 'The Biology of High-Stakes Decisions',
                      'description':
                          'Understanding cognitive fatigue, dopamine dynamics, and emotional resilience under sustained volatility.',
                    },
                    {
                      'icon': '💡',
                      'title': 'Neuroplasticity for Organizations',
                      'description':
                          'Cultivating cultures of rapid learning, psychological safety, and collective intelligence in distributed teams.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_marcus_about',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'About Dr. Vance',
                  'subtitle': 'Over fifteen years investigating attentional mechanics.',
                  'body':
                      'Marcus Vance holds a Ph.D. in Cognitive Neurobiology from Oxford and currently directs research initiatives at Stanford. His essays have appeared in Nature, Harvard Business Review, and The Atlantic. He consults regularly with Fortune 100 executives and top-tier athletics programs on human potential.',
                  'image':
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_marcus_cta',
                'component': 'cta',
                'order': 3,
                'props': {
                  'headline': 'Bring Dr. Vance to Your Next Event',
                  'description':
                      'Inquire about keynote availability, executive retreats, or advisory engagements for 2026/2027.',
                  'buttonText': 'Submit Speaker Inquiry',
                  'buttonLink': '#contact',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_marcus_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright': '© 2026 Dr. Marcus Vance. All rights reserved.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-elena-rostova',
      'slug': 'elena-rostova',
      'name': 'Elena Rostova',
      'industry': 'Personal & Architecture Portfolio',
      'badge': '✦ AD100 ARCHITECT',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Bespoke residential pavilions, private sanctuaries, and minimalist interior architecture across Kyoto and Zurich.',
      'headline': 'Form, Silence,\nand Natural Light.',
      'subheadline':
          'Sculpting spaces that endure. Bespoke architectural commissions focusing on tactile materials, monolithic concrete, and sacred geometries.',
      'ctaText': 'View Selected Works',
      'primaryColor': '#1C1917',
      'bgColor': '#FAFAF9',
      'preview_images': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Elena Rostova Architect',
          'theme': {
            'colors': {
              'primary': '#1C1917',
              'secondary': '#57534E',
              'accent': '#A8A29E',
              'background': '#FAFAF9',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#1C1917',
                'secondary': '#78716C',
                'inverse': '#FAFAF9',
              },
            },
            'typography': {
              'headingFamily': 'Space Grotesk',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'Elena Rostova'},
          'items': [
            {'label': 'Projects', 'href': '#projects'},
            {'label': 'Philosophy', 'href': '#philosophy'},
            {'label': 'Awards', 'href': '#awards'},
            {'label': 'Inquire', 'href': '#contact', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_elena_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ AD100 2026 · ARCHITECTURAL DESIGN & INTERIORS',
                  'headline': 'Form, Silence,\nand Natural Light.',
                  'subheadline':
                      'Bespoke architectural commissions that honor natural materiality, raw concrete, and the sacred balance between interior and wild exterior landscapes.',
                  'ctaText': 'Explore Works',
                  'ctaLink': '#projects',
                  'secondaryCtaText': 'Design Philosophy ↗',
                  'secondaryCtaLink': '#philosophy',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Villa Kanso in Kyoto by Elena Rostova',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_elena_projects',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Selected Architectural Works',
                  'subtitle': 'Monolithic residential sanctuaries completed across Europe and Asia.',
                  'items': [
                    {
                      'icon': '🏛️',
                      'title': 'Villa Kanso · Kyoto',
                      'description':
                          'Charred cedar yakisugi facade paired with basalt stone courtyard gardens and hidden subterranean tea chamber.',
                    },
                    {
                      'icon': '🏔️',
                      'title': 'Alpine Glass Sanctuary · Vals',
                      'description':
                          'Cantilevered board-formed concrete pavilion embedded into the Swiss granite slopes with 360-degree panoramic glazing.',
                    },
                    {
                      'icon': '🌊',
                      'title': 'Pavilion VII · Stockholm Archipelago',
                      'description':
                          'Zero-carbon timber dwelling featuring thermal bedrock heating and private natural harbor jetty.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_elena_philosophy',
                'component': 'about',
                'order': 2,
                'props': {
                  'title': 'Architectural Manifesto',
                  'subtitle': 'A dialogue between permanence and ephemeral daylight.',
                  'body':
                      'Architecture should not compete with nature; it should serve as a quiet frame through which the changes of season, wind, and sky are felt deeply. We work with an intentional palette of raw stone, unvarnished timber, and shadow to craft spaces that inspire reverence.',
                  'image':
                      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_elena_cta',
                'component': 'cta',
                'order': 3,
                'props': {
                  'headline': 'Initiate a Private Commission',
                  'description':
                      'We accept a select number of residential and cultural architectural commissions each year.',
                  'buttonText': 'Contact the Studio',
                  'buttonLink': '#contact',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_elena_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright': '© 2026 Elena Rostova Studio. Zurich · Kyoto.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-kai-thorne',
      'slug': 'kai-thorne',
      'name': 'Kai Thorne',
      'industry': 'Personal & Software Engineer',
      'badge': '✦ INDIE CREATOR',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Staff engineer turned independent maker. Building high-performance developer tools, terminal utilities, and open source libraries in Rust.',
      'headline': 'High-Performance Systems\nand Open Source Tools.',
      'subheadline':
          'Creator of open source devtools used by over 250,000 developers worldwide. Writing about systems programming, memory safety, and terminal UI.',
      'ctaText': 'Explore GitHub Tools',
      'primaryColor': '#10B981',
      'bgColor': '#121316',
      'preview_images': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Kai Thorne',
          'theme': {
            'colors': {
              'primary': '#10B981',
              'secondary': '#34D399',
              'accent': '#6EE7B7',
              'background': '#121316',
              'surface': '#1A1D24',
              'text': {
                'primary': '#F1F5F9',
                'secondary': '#94A3B8',
                'inverse': '#121316',
              },
            },
            'typography': {
              'headingFamily': 'Inter',
              'bodyFamily': 'Inter',
            },
          },
        },
        'navigation': {
          'logo': {'text': 'kai.thorne.dev'},
          'items': [
            {'label': 'Projects', 'href': '#projects'},
            {'label': 'Articles', 'href': '#articles'},
            {'label': 'Stack', 'href': '#stack'},
            {'label': 'GitHub ↗', 'href': 'https://github.com', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_kai_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ STAFF ENGINEER · OPEN SOURCE CREATOR',
                  'headline': 'High-Performance Systems\nand Open Source Tools.',
                  'subheadline':
                      'Ex-systems architect crafting developer-first terminal tools, high-throughput network engines, and CLI utilities in Rust and Go.',
                  'ctaText': 'Explore GitHub Tools',
                  'ctaLink': '#projects',
                  'secondaryCtaText': 'Read Technical Essays ↗',
                  'secondaryCtaLink': '#articles',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Kai Thorne coding in terminal',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_kai_projects',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Featured Open Source Projects',
                  'subtitle': 'Downloaded over 2.4 million times across crates.io and homebrew.',
                  'items': [
                    {
                      'icon': '⚡',
                      'title': 'TurboTrace · Rust',
                      'description':
                          'Zero-overhead distributed tracing daemon with sub-microsecond latency and eBPF kernel hooks.',
                    },
                    {
                      'icon': '📦',
                      'title': 'BytePack · Go',
                      'description':
                          'High-throughput columnar binary serialization protocol designed for edge database replication.',
                    },
                    {
                      'icon': '🖥️',
                      'title': 'HyperQuery · Terminal TUI',
                      'description':
                          'Modern 60fps terminal query explorer with vim bindings, fuzzy regex matching, and instant charts.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_kai_stats',
                'component': 'statistics',
                'order': 2,
                'props': {
                  'title': 'Community Impact',
                  'subtitle': 'Building in public with full open source transparency.',
                  'items': [
                    {'value': '250K+', 'label': 'Active Developers'},
                    {'value': '14.8K', 'label': 'GitHub Stars'},
                    {'value': '100%', 'label': 'Open Source MIT'},
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_kai_cta',
                'component': 'cta',
                'order': 3,
                'props': {
                  'headline': 'Sponsor or Collaborate',
                  'description':
                      'Have an interesting systems challenge or want to support my open source tools? Reach out or sponsor via GitHub.',
                  'buttonText': 'Get in Touch',
                  'buttonLink': '#contact',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_kai_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright': '© 2026 Kai Thorne. Open source software for all.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-apex-capital',
      'slug': 'apex-capital',
      'name': 'Apex Capital Partners',
      'industry': 'Business & Wealth Advisory',
      'badge': '✦ INSTITUTIONAL EXCELLENCE',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Disciplined private equity and multi-generational wealth advisory managing \$4.8B across North America and Europe.',
      'headline': 'Disciplined Capital.\nMulti-Generational Growth.',
      'subheadline':
          'Managing \$4.8B in private equity, sovereign wealth, and family office assets with rigorous governance and long-term partnership.',
      'ctaText': 'Schedule Advisory Consultation',
      'primaryColor': '#0F2027',
      'bgColor': '#F8FAFC',
      'preview_images': [
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Apex Capital Partners',
          'theme': {
            'colors': {
              'primary': '#0F2027',
              'secondary': '#203A43',
              'accent': '#D4AF37',
              'background': '#F8FAFC',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#0F172A',
                'secondary': '#475569',
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
          'logo': {'text': 'Apex Capital Partners'},
          'items': [
            {'label': 'Practices', 'href': '#practices'},
            {'label': 'Track Record', 'href': '#track-record'},
            {'label': 'Team', 'href': '#team'},
            {'label': 'Contact', 'href': '#contact', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_apex_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ \$4.8B AUM · PRIVATE EQUITY & WEALTH ADVISORY',
                  'headline': 'Disciplined Capital.\nMulti-Generational Growth.',
                  'subheadline':
                      'Institutional private equity and family office fiduciary advisory. Partnering with visionary founders and institutional funds to compound generational wealth.',
                  'ctaText': 'Schedule Advisory Consultation',
                  'ctaLink': '#contact',
                  'secondaryCtaText': 'Our Investment Focus ↗',
                  'secondaryCtaLink': '#practices',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Apex Capital Partners Corporate Headquarters',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_apex_practices',
                'component': 'features',
                'order': 1,
                'props': {
                  'title': 'Core Investment Practices',
                  'subtitle': 'Decades of disciplined capital deployment across asymmetric market cycles.',
                  'items': [
                    {
                      'icon': '📊',
                      'title': 'Growth Private Equity',
                      'description':
                          'Minority and control equity investments into cash-flow positive enterprise software and tech-enabled logistics.',
                    },
                    {
                      'icon': '🌐',
                      'title': 'Global Real Assets',
                      'description':
                          'Core-plus real estate, data center infrastructure, and sustainable energy projects with direct inflation hedging.',
                    },
                    {
                      'icon': '🏛️',
                      'title': 'Family Office Fiduciary',
                      'description':
                          'Multi-generational wealth succession planning, tax optimization, and bespoke liquidity management structures.',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_apex_stats',
                'component': 'statistics',
                'order': 2,
                'props': {
                  'title': 'Proven Track Record',
                  'subtitle': 'Demonstrated risk-adjusted performance across 18 consecutive years.',
                  'items': [
                    {'value': '\$4.8B+', 'label': 'Assets Under Management'},
                    {'value': '22.4%', 'label': 'Historical Net IRR'},
                    {'value': '18 Years', 'label': 'Continuous Stewardship'},
                  ],
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_apex_cta',
                'component': 'cta',
                'order': 3,
                'props': {
                  'headline': 'Schedule a Confidential Briefing',
                  'description':
                      'Our managing partners welcome inquiries from institutional allocators, single-family offices, and qualified purchasers.',
                  'buttonText': 'Inquire for Consultation',
                  'buttonLink': '#contact',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_apex_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright': '© 2026 Apex Capital Partners LLP. Member FINRA / SIPC.',
                },
                'styles': {'background': 'surface'},
              },
            ],
          },
        ],
      },
    },
    {
      'id': 'tmpl-nordic-craft',
      'slug': 'nordic-craft',
      'name': 'Nordic Craft Roasters',
      'industry': 'Business & Specialty Coffee',
      'badge': '✦ DIRECT TRADE ORIGIN',
      'is_featured': true,
      'is_public': true,
      'is_premium': false,
      'description':
          'Direct-trade Scandinavian light roasts sourced from ethical smallholder cooperatives across Ethiopia and Colombia.',
      'headline': 'Precision Roasting.\nUncompromised Purity.',
      'subheadline':
          'Supplying single-origin specialty coffees to Michelin-starred restaurants, boutique hotels, and coffee connoisseurs worldwide.',
      'ctaText': 'Explore Wholesale & Retail',
      'primaryColor': '#2C1810',
      'bgColor': '#F5F2EB',
      'preview_images': [
        'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=1200&q=80',
      ],
      'document': {
        'schema_version': 1,
        'site': {
          'name': 'Nordic Craft Roasters',
          'theme': {
            'colors': {
              'primary': '#2C1810',
              'secondary': '#5E3A2B',
              'accent': '#C5A880',
              'background': '#F5F2EB',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#2C1810',
                'secondary': '#6B5448',
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
          'logo': {'text': 'Nordic Craft Roasters'},
          'items': [
            {'label': 'Coffee', 'href': '#products'},
            {'label': 'Sourcing', 'href': '#about'},
            {'label': 'Café & Tasting', 'href': '#visit'},
            {'label': 'Wholesale', 'href': '#wholesale', 'type': 'button'},
          ],
        },
        'pages': [
          {
            'id': 'page_home',
            'slug': '/',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_nordic_hero',
                'component': 'hero',
                'order': 0,
                'props': {
                  'badge': '✦ COPENHAGEN MICRO-ROASTERY · DIRECT TRADE',
                  'headline': 'Precision Roasting.\nUncompromised Purity.',
                  'subheadline':
                      'Light, expressive Scandinavian roast profiles designed to preserve floral sweetness, vibrant citrus acidity, and authentic terroir from farm to cup.',
                  'ctaText': 'Explore Coffee Offerings',
                  'ctaLink': '#products',
                  'secondaryCtaText': 'Visit Our Tasting Room ↗',
                  'secondaryCtaLink': '#visit',
                  'image': {
                    'src':
                        'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=1200&q=80',
                    'alt': 'Nordic Craft Specialty Coffee Roasters',
                  },
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_nordic_products',
                'component': 'products',
                'order': 1,
                'props': {
                  'title': 'Seasonal Single-Origin Selections',
                  'subtitle': 'Small-batch roasted every Tuesday on our zero-emission Loring S35.',
                  'items': [
                    {
                      'name': 'Guji Natural · Ethiopia',
                      'price': '€19.50',
                      'description': 'Jasmine blossom, wild strawberry, and bergamot finish.',
                      'badge': 'LIMITED HARVEST',
                    },
                    {
                      'name': 'Huila Pink Bourbon · Colombia',
                      'price': '€22.00',
                      'description': 'Crisp white peach, sugarcane syrup, and honeysuckle aroma.',
                      'badge': 'MICR-LOT',
                    },
                    {
                      'name': 'Nordic Winter Espresso',
                      'price': '€17.00',
                      'description': 'Milk chocolate ganache, candied orange, and smooth body.',
                      'badge': 'HOUSE BLEND',
                    },
                  ],
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_nordic_visit',
                'component': 'visit',
                'order': 2,
                'props': {
                  'title': 'Copenhagen Tasting Room',
                  'subtitle': 'Vesterbrogade 44, 1620 København V, Denmark',
                  'address': 'Vesterbrogade 44, 1620 København V, Denmark',
                  'hours':
                      'Monday – Friday: 07:30 – 17:00\nSaturday – Sunday: 08:30 – 18:00\nPublic cuppings every Saturday at 11:00 AM.',
                  'ctaText': 'Get Directions',
                  'ctaLink': '#directions',
                },
                'styles': {'background': 'background'},
              },
              {
                'id': 'sec_nordic_cta',
                'component': 'cta',
                'order': 3,
                'props': {
                  'headline': 'Wholesale & Michelin Partner Program',
                  'description':
                      'We provide bespoke roast profiles, commercial La Marzocco equipment, and barista training to world-class hospitality venues.',
                  'buttonText': 'Inquire for Wholesale',
                  'buttonLink': '#wholesale',
                },
                'styles': {'background': 'surface'},
              },
              {
                'id': 'sec_nordic_footer',
                'component': 'footer',
                'order': 4,
                'props': {
                  'copyright': '© 2026 Nordic Craft Roasters ApS. Copenhagen, Denmark.',
                },
                'styles': {'background': 'background'},
              },
            ],
          },
        ],
      },
    },
  ];
}
