import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/models/uploaded_image.dart';
import '../../core/models/user_site_info.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/media_asset_service.dart';
import '../../core/storage/session_manager.dart';
import '../dashboard/components/recent_project_card.dart';

class AssetsController extends GetxController {
  final mediaService = MediaAssetService.shared;

  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // Tab filter: 'all', 'pages', 'uploads'
  final selectedFilter = 'all'.obs;

  // Site filter for uploaded assets: 'all' or specific siteId
  final selectedSiteFilter = 'all'.obs;

  final userInitials = 'MR'.obs;
  final userName = RxnString();
  final isLoading = false.obs;

  static final List<WebsitePreviewItem> defaultPageItems = [
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
    const WebsitePreviewItem(
      id: 'showcase_lumen_coffee',
      title: 'Lumen Coffee',
      category: 'Roastery & Café, Portland',
      categoryColor: Color(0xFF9E4B28),
      headline: 'Small-batch coffee, roasted weekly',
      body: 'Single-origin beans from ethical farms, roasted fresh in our Pacific shop.',
      ctaText: 'Order beans',
      ctaColor: Color(0xFF9E4B28),
      ctaBorderRadius: 6.0,
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80',
      isSerif: true,
      bgCanvasColor: Color(0xFFFBF9F5),
      isLive: true,
      domain: 'lumencoffee.com',
    ),
    const WebsitePreviewItem(
      id: 'showcase_nordic_ceramic',
      title: 'Nordic Ceramic',
      category: 'Studio & Shop, Stockholm',
      categoryColor: Color(0xFF334155),
      headline: 'Tactile vessels made by hand',
      body: 'Stoneware and porcelain tableware thrown in Stockholm and glazed in matte earth.',
      ctaText: 'Explore shop',
      ctaColor: Color(0xFF1E293B),
      ctaBorderRadius: 4.0,
      imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
      isSerif: true,
      bgCanvasColor: Color(0xFFFAFAFA),
      isLive: false,
      timeAgo: 'Draft · Edited 1 day ago',
    ),
  ];

  static List<UserSiteInfo> get defaultSites => [
    const UserSiteInfo(
      id: 'showcase_studio_marlow',
      name: 'Studio Marlow',
      domain: 'studiomarlow.com',
      status: 'live',
      category: 'Architecture, Copenhagen',
      imageUrl: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=600&q=80',
      assetCount: 4,
      timeAgo: 'Live · Active now',
      isLive: true,
    ),
    const UserSiteInfo(
      id: 'showcase_kite_yoga',
      name: 'Kite Yoga',
      subdomain: 'kiteyoga.aibuilder.app',
      status: 'draft',
      category: 'East 6th St, Austin',
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80',
      assetCount: 2,
      timeAgo: 'Draft · Edited 3 days ago',
      isLive: false,
    ),
  ];

  final pageItems = <WebsitePreviewItem>[...defaultPageItems].obs;
  final sites = <UserSiteInfo>[...defaultSites].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadSites();
  }

  Future<void> _loadUser() async {
    final initials = await SessionManager.getUserInitials();
    if (initials.isNotEmpty && initials != 'DC') {
      userInitials.value = initials;
    }
    userName.value = await SessionManager.getUserName();
  }

  Future<void> loadSites() async {
    isLoading.value = true;
    try {
      final siteList = <UserSiteInfo>[...defaultSites];
      final previewList = <WebsitePreviewItem>[...defaultPageItems];

      // User websites fetched from backend
      try {
        final backendWebsites = await ApiClient.getWebsites();
        for (final site in backendWebsites) {
          if (site.slug == 'studio-marlow' || site.slug == 'kite-yoga') continue;

          final isLive = site.status == 'published' || site.status == 'live';
          String headline = 'Crafted for Modern Growth';
          String body = 'Clean architecture, custom layout, and optimized speed.';
          String category = isLive ? 'Published Website' : 'Draft Project';
          String ctaText = 'Explore work';
          String imageUrl = 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80';

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
                      headline = props['headline']?.toString() ?? headline;
                      body = props['subheadline']?.toString() ?? body;
                      ctaText = props['ctaText']?.toString() ?? ctaText;
                      final raw = props['image'] ?? props['imageUrl'] ?? props['url'];
                      if (raw is Map) {
                        imageUrl = raw['src']?.toString() ?? imageUrl;
                      } else if (raw is String && raw.startsWith('http')) {
                        imageUrl = raw;
                      }
                    }
                    break;
                  }
                }
              }
            }
          }

          siteList.add(
            UserSiteInfo(
              id: site.id,
              name: site.name,
              domain: isLive ? (site.subdomain != null ? '${site.subdomain}.com' : '${site.slug}.com') : null,
              subdomain: site.subdomain != null ? '${site.subdomain}.aibuilder.app' : '${site.slug}.aibuilder.app',
              status: site.status,
              category: category,
              imageUrl: imageUrl,
              assetCount: getAssetCountForSite(site.id),
              timeAgo: isLive ? 'Live · Updated recently' : 'Draft · Updated recently',
              isLive: isLive,
              document: site.document,
            ),
          );

          previewList.add(
            WebsitePreviewItem(
              id: site.id,
              title: site.name,
              category: category,
              headline: headline,
              body: body,
              ctaText: ctaText,
              ctaColor: const Color(0xFF0F172A),
              imageUrl: imageUrl,
              isLive: isLive,
              domain: isLive ? (site.subdomain != null ? '${site.subdomain}.com' : '${site.slug}.com') : null,
              timeAgo: isLive ? null : 'Draft · Edited recently',
            ),
          );
        }
      } catch (_) {}

      sites.assignAll(siteList);
      pageItems.assignAll(previewList);
    } finally {
      isLoading.value = false;
    }
  }

  int getAssetCountForSite(String siteId) {
    return mediaService.uploadedImages.where((img) => img.siteId == siteId).length;
  }

  List<WebsitePreviewItem> get filteredPages {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return pageItems;
    return pageItems.where((p) {
      return p.title.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.headline.toLowerCase().contains(query) ||
          (p.domain?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<UploadedImage> get filteredUploads {
    var list = mediaService.uploadedImages.toList();

    // Filter by site if selected
    if (selectedSiteFilter.value != 'all') {
      list = list.where((img) => img.siteId == selectedSiteFilter.value).toList();
    }

    // Filter by search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((img) {
        final matchesFilename = img.filename.toLowerCase().contains(query);
        final matchesAlt = img.alt.toLowerCase().contains(query);
        final matchesSite = img.siteName?.toLowerCase().contains(query) ?? false;
        return matchesFilename || matchesAlt || matchesSite;
      }).toList();
    }

    return list;
  }

  List<UploadedImage> get filteredAssets => filteredUploads;

  List<UserSiteInfo> get filteredSites {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return sites;
    return sites.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.category.toLowerCase().contains(query) ||
          (s.domain?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  int get pagesCount => filteredPages.length;
  int get uploadsCount => filteredUploads.length;

  String get selectedSiteName {
    if (selectedSiteFilter.value == 'all') return 'All Sites';
    final site = sites.firstWhereOrNull((s) => s.id == selectedSiteFilter.value);
    return site?.name ?? 'Selected Site';
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void filterBySite(String siteId) {
    selectedSiteFilter.value = siteId;
  }

  void clearSiteFilter() {
    selectedSiteFilter.value = 'all';
  }

  void openWebsite(String siteId) {
    Get.toNamed(AppRoutes.editor, arguments: {'websiteId': siteId});
  }

  void _showSnackbar(
    String title,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
    Duration? duration,
  }) {
    AppSnackbar.show(
      message,
      title: title,
      type: type,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  Future<void> uploadAsset() async {
    if (mediaService.uploadedImages.length >= MediaAssetService.maxImageUploadLimit) {
      _showSnackbar(
        'Upload Limit Reached',
        'You have reached the maximum of ${MediaAssetService.maxImageUploadLimit} stored media assets.',
        type: AppSnackbarType.error,
      );
      return;
    }

    String? targetSiteId;
    String? targetSiteName;
    if (selectedSiteFilter.value != 'all') {
      targetSiteId = selectedSiteFilter.value;
      targetSiteName = selectedSiteName;
    } else if (sites.isNotEmpty) {
      targetSiteId = sites.first.id;
      targetSiteName = sites.first.name;
    }

    final newAsset = await mediaService.uploadFromDevice(
      targetSiteId: targetSiteId,
      targetSiteName: targetSiteName,
    );

    if (newAsset != null) {
      loadSites();
      _showSnackbar(
        'Asset Uploaded',
        'Added "${newAsset.filename}" to your library (${mediaService.uploadedImages.length}/${MediaAssetService.maxImageUploadLimit}).',
        type: AppSnackbarType.success,
      );
    }
  }

  void deleteAsset(String id, {String? filename}) {
    final deleted = mediaService.deleteAsset(id);
    if (deleted) {
      loadSites();
      _showSnackbar(
        'Asset Deleted',
        'Removed "${filename ?? 'Asset'}" from media library (${mediaService.uploadedImages.length}/${MediaAssetService.maxImageUploadLimit} remaining).',
        type: AppSnackbarType.info,
      );
    }
  }

  void copyAssetUrl(UploadedImage asset) {
    Clipboard.setData(ClipboardData(text: asset.url));
    AppSnackbar.copied(message: 'Asset URL copied to clipboard.');
  }
}
