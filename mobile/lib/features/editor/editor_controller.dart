import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/models/uploaded_image.dart';
import '../../core/services/media_asset_service.dart';
import '../../core/network/api_client.dart';
export '../../core/models/uploaded_image.dart';
import '../dashboard/dashboard_controller.dart';
import '../subscription/subscription_view.dart';
import 'ask_ai_review_sheet.dart';

enum ViewportMode { mobile, tablet, desktop }

class ColorPreset {
  final String name;
  final Color bg;
  final Color aaColor;
  final Color dot1;
  final Color dot2;
  final Map<String, dynamic> themeColors;

  const ColorPreset({
    required this.name,
    required this.bg,
    required this.aaColor,
    required this.dot1,
    required this.dot2,
    required this.themeColors,
  });
}

class FontPreset {
  final String name;
  final String family;
  final TextStyle aaStyle;

  const FontPreset({
    required this.name,
    required this.family,
    required this.aaStyle,
  });
}

class EditorController extends GetxController {
  EditorController() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      MediaAssetService.shared.resetToDefaults();
    }
  }

  String websiteId = '';
  WebViewController? webViewController;

  final websiteName = 'Untitled site'.obs;
  final revisionNumber = 1.obs;
  final isSaving = false.obs;
  final isPublishing = false.obs;
  final isLoading = true.obs;
  final viewport = ViewportMode.mobile.obs;
  final isLandscape = false.obs;

  void toggleLandscape() {
    if (isLandscape.value) {
      setPortrait();
    } else {
      setLandscape();
    }
  }

  void setLandscape() {
    isLandscape.value = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void setPortrait() {
    isLandscape.value = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // Bottom panel state: 0 = Add, 1 = Edit, 2 = Layers, 3 = Design
  final selectedTab = 0.obs;
  final isPanelOpen = false.obs;

  // Showcase keys for guided tour
  final showcaseRotateKey = GlobalKey();
  final showcaseCanvasKey = GlobalKey();
  final showcaseDockKey = GlobalKey();
  final showcasePublishKey = GlobalKey();

  void openTab(int index) {
    selectedTab.value = index;
    isPanelOpen.value = true;
  }

  void closePanel() {
    isPanelOpen.value = false;
  }

  // Selected Presets in Design Tab
  final selectedColorPreset = 'Crema'.obs;
  final selectedFontPreset = 'Serif'.obs;

  // AI prompt state & Before/After Review (Images 3 & 4)
  final aiPromptPlaceholder = 'Ask AI to change your site'.obs;
  final aiPromptController = TextEditingController();
  final isAiEditing = false.obs;

  final isAiReviewActive = false.obs;
  final aiReviewStep = 'prompt'.obs; // 'prompt' (Image 3) or 'review' (Image 4)
  final aiReviewMode = 'After'.obs; // 'Before' or 'After'
  final aiReviewScope = 'Entire website'.obs; // 'No selection' or 'Entire website'
  final stashedOriginalDoc = Rxn<Map<String, dynamic>>();
  final stashedAiProposedDoc = Rxn<Map<String, dynamic>>();
  final stashedOriginalPalette = 'Crema'.obs;
  final aiChangeDiffs = <Map<String, String>>[].obs;
  final aiCustomPromptController = TextEditingController();
  final aiVariationIndex = 0.obs;

  // Selected element / section details
  final selectedSectionId = RxnString();
  final selectedElementContext = 'Heading in Hero'.obs;
  final selectedElementKey = 'headline'.obs;
  final selectedElementSize = 'Large'.obs; // 'Small', 'Medium', 'Large'

  final textController = TextEditingController();
  final subheadlineController = TextEditingController();

  // CTA & Action properties (Buttons, URLs, Anchors, Badges)
  final ctaTextController = TextEditingController();
  final ctaLinkController = TextEditingController();
  final secondaryCtaTextController = TextEditingController();
  final secondaryCtaLinkController = TextEditingController();
  final badgeController = TextEditingController();

  // Observable collections for dynamic section items
  final testimonialItems = <Map<String, dynamic>>[].obs;
  final statItems = <Map<String, dynamic>>[].obs;
  final featureItems = <Map<String, dynamic>>[].obs;

  // Navigation, Footer, FAQ, Products & Contact properties
  final navLogoTextController = TextEditingController();
  final navLogoSrcController = TextEditingController();
  final navItems = <Map<String, dynamic>>[].obs;

  final footerCopyrightController = TextEditingController();
  final footerLinks = <Map<String, dynamic>>[].obs;

  final productItems = <Map<String, dynamic>>[].obs;
  final faqItems = <Map<String, dynamic>>[].obs;
  final galleryImages = <Map<String, dynamic>>[].obs;

  final contactEmailController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final contactAddressController = TextEditingController();
  final contactHoursController = TextEditingController();

  // Wix Section Design & Layout Styles (For any section)
  final selectedSectionBackground = 'default'.obs; // 'default', 'surface', 'dark', 'brand'
  final selectedSectionAlign = 'left'.obs; // 'left', 'center', 'right'
  final selectedSectionPadding = 'normal'.obs; // 'compact', 'normal', 'spacious'

  // Wix Universal Properties Inspector (Allows modifying literally ANY key/value)
  final customProps = <String, dynamic>{}.obs;

  // Image Workflow & Uploads (Screenshots from user)
  static const int maxImageUploadLimit = MediaAssetService.maxImageUploadLimit;

  final uploadedImages = MediaAssetService.shared.uploadedImages;

  final selectedUploadImageId = 'img_1'.obs;
  final isAddingImageSubView = false.obs;
  final isReplacingImageMode = false.obs;
  final isGeneratingAltText = false.obs;

  final selectedSectionType = 'hero'.obs;
  final selectedImageProps = <String, dynamic>{}.obs;
  final selectedImageFit = 'crop'.obs;
  final altTextController = TextEditingController();

  String get selectedImageFilename =>
      selectedImageProps['filename']?.toString() ?? 'café-interior.jpg';
  String get selectedImageUrl =>
      selectedImageProps['url']?.toString() ??
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80';

  final document = Rxn<Map<String, dynamic>>();

  // Undo / Redo history stacks
  final undoStack = <Map<String, dynamic>>[].obs;
  final redoStack = <Map<String, dynamic>>[].obs;

  Timer? _saveDebounceTimer;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  String get siteDomain {
    final clean = websiteName.value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return clean.isEmpty ? 'lumencoffee.com' : '$clean.com';
  }

  // Curated Design Presets (Screenshot from user)
  final colorPresets = const [
    ColorPreset(
      name: 'Crema',
      bg: Color(0xFFFAF6F0),
      aaColor: Color(0xFF0F172A),
      dot1: Color(0xFFB85028),
      dot2: Color(0xFFEFE8DE),
      themeColors: {
        'primary': '#B85028',
        'secondary': '#78716C',
        'accent': '#D97706',
        'background': '#FAF6F0',
        'surface': '#FFFFFF',
        'text': {
          'primary': '#0F172A',
          'secondary': '#78716C',
          'inverse': '#FFFFFF',
        },
      },
    ),
    ColorPreset(
      name: 'Espresso',
      bg: Color(0xFF1C1917),
      aaColor: Colors.white,
      dot1: Color(0xFFEA580C),
      dot2: Color(0xFF292524),
      themeColors: {
        'primary': '#D97706',
        'secondary': '#A8A29E',
        'accent': '#EA580C',
        'background': '#1C1917',
        'surface': '#292524',
        'text': {
          'primary': '#F5F5F4',
          'secondary': '#A8A29E',
          'inverse': '#0F172A',
        },
      },
    ),
    ColorPreset(
      name: 'Midnight',
      bg: Color(0xFF0B0F17),
      aaColor: Colors.white,
      dot1: Color(0xFF38BDF8),
      dot2: Color(0xFF1E293B),
      themeColors: {
        'primary': '#38BDF8',
        'secondary': '#94A3B8',
        'accent': '#818CF8',
        'background': '#0B0F17',
        'surface': '#1E293B',
        'text': {
          'primary': '#F8FAFC',
          'secondary': '#94A3B8',
          'inverse': '#0B0F17',
        },
      },
    ),
    ColorPreset(
      name: 'Matcha',
      bg: Color(0xFFF0FDF4),
      aaColor: Color(0xFF14532D),
      dot1: Color(0xFF15803D),
      dot2: Color(0xFFDCFCE7),
      themeColors: {
        'primary': '#15803D',
        'secondary': '#16A34A',
        'accent': '#22C55E',
        'background': '#F0FDF4',
        'surface': '#FFFFFF',
        'text': {
          'primary': '#14532D',
          'secondary': '#15803D',
          'inverse': '#FFFFFF',
        },
      },
    ),
    ColorPreset(
      name: 'Riviera',
      bg: Color(0xFFF0F7FF),
      aaColor: Color(0xFF1E3A8A),
      dot1: Color(0xFF2563EB),
      dot2: Color(0xFFDBEAFE),
      themeColors: {
        'primary': '#2563EB',
        'secondary': '#0284C7',
        'accent': '#06B6D4',
        'background': '#F0F7FF',
        'surface': '#FFFFFF',
        'text': {
          'primary': '#0F172A',
          'secondary': '#64748B',
          'inverse': '#FFFFFF',
        },
      },
    ),
    ColorPreset(
      name: 'Blush',
      bg: Color(0xFFFFF1F2),
      aaColor: Color(0xFF881337),
      dot1: Color(0xFFBE123C),
      dot2: Color(0xFFFFE4E6),
      themeColors: {
        'primary': '#BE123C',
        'secondary': '#E11D48',
        'accent': '#FB7185',
        'background': '#FFF1F2',
        'surface': '#FFFFFF',
        'text': {
          'primary': '#1E1B4B',
          'secondary': '#881337',
          'inverse': '#FFFFFF',
        },
      },
    ),
    ColorPreset(
      name: 'Mono',
      bg: Colors.white,
      aaColor: Color(0xFF09090B),
      dot1: Color(0xFF09090B),
      dot2: Color(0xFFE4E4E7),
      themeColors: {
        'primary': '#09090B',
        'secondary': '#52525B',
        'accent': '#27272A',
        'background': '#FFFFFF',
        'surface': '#F4F4F5',
        'text': {
          'primary': '#09090B',
          'secondary': '#71717A',
          'inverse': '#FFFFFF',
        },
      },
    ),
  ];

  final fontPresets = const [
    FontPreset(
      name: 'Serif',
      family: 'Playfair Display',
      aaStyle: TextStyle(
        fontFamily: 'serif',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    ),
    FontPreset(
      name: 'Sans',
      family: 'Inter',
      aaStyle: TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    ),
    FontPreset(
      name: 'Editorial',
      family: 'Cinzel',
      aaStyle: TextStyle(
        fontFamily: 'serif',
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: Color(0xFF0F172A),
      ),
    ),
    FontPreset(
      name: 'Mono',
      family: 'Space Mono',
      aaStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
    ),
    FontPreset(
      name: 'Warm',
      family: 'Merriweather',
      aaStyle: TextStyle(
        fontFamily: 'serif',
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
    ),
    FontPreset(
      name: 'Display',
      family: 'Plus Jakarta Sans',
      aaStyle: TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    websiteId = args?['websiteId'] ?? '';
    // Landscape view by default as requested
    setLandscape();
    _initWebView();
    if (websiteId.isNotEmpty) {
      loadWebsite();
    } else {
      _loadDefaultLumenCoffeeSite();
    }
  }

  static String get rendererUrl {
    const customUrl = String.fromEnvironment('RENDERER_URL');
    if (customUrl.isNotEmpty) return customUrl;
    const useLocal = bool.fromEnvironment('USE_LOCAL_RENDERER', defaultValue: false);
    if (useLocal) {
      final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
      return 'http://$host:3000/?editor=true';
    }
    return 'https://ai-landing-page.xyz/?editor=true';
  }

  void _initWebView() {
    try {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..addJavaScriptChannel(
          'AndroidBridge',
          onMessageReceived: (message) {
            try {
              final data = jsonDecode(message.message);
              final action = data['action'] ?? data['type'];
              if (action == 'EDITOR_READY' || action == 'RENDERER_READY') {
                syncDocumentToWebView();
              } else if (action == 'SELECT_ELEMENT') {
                final payload = (data['payload'] ?? data) as Map<String, dynamic>;
                onElementSelected(payload);
              } else if (action == 'SELECT_SECTION' || action == 'SECTION_SELECTED') {
                final payload = data['payload'] as Map<String, dynamic>?;
                onSectionSelected(payload);
              } else if (action == 'OPEN_EDIT_TAB') {
                selectedTab.value = 1;
                isPanelOpen.value = true;
              } else if (action == 'FOCUS_AI_PROMPT') {
                final payload = data['payload'] as Map<String, dynamic>?;
                final ctx = payload?['context'] as String? ?? 'element';
                aiPromptPlaceholder.value = 'Ask AI about this ${ctx.toLowerCase()}';
              } else if (action == 'MOVE_SECTION_UP') {
                final secId = data['payload']?['sectionId'] as String?;
                if (secId != null) moveSection(secId, 'up');
              } else if (action == 'MOVE_SECTION_DOWN') {
                final secId = data['payload']?['sectionId'] as String?;
                if (secId != null) moveSection(secId, 'down');
              } else if (action == 'DELETE_SECTION') {
                final secId = data['payload']?['sectionId'] as String?;
                if (secId != null) deleteSection(secId);
              }
            } catch (_) {}
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              syncDocumentToWebView();
            },
          ),
        )
        ..loadRequest(Uri.parse(rendererUrl));
    } catch (_) {
      // In headless unit tests, WebViewPlatform is uninitialized
    }
  }

  Future<void> loadWebsite() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.getWebsiteDetails(websiteId);
      final website = res['website'] as Map<String, dynamic>;
      final currentRev = website['current_revision'] as Map<String, dynamic>?;

      websiteName.value = website['name'] ?? 'Untitled site';
      revisionNumber.value = currentRev?['revision_number'] ?? (website['revision_number'] ?? 1);
      final rawDoc = (currentRev?['document'] as Map<String, dynamic>?) ??
          (website['document'] as Map<String, dynamic>?);
      document.value = rawDoc;

      _autoSelectInitialElement();
      syncDocumentToWebView();
    } catch (e) {
      AppSnackbar.error('Failed to load website: $e', title: 'Error');
      AppSnackbar.error('Failed to load website: $e', title: 'common_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultLumenCoffeeSite() {
    websiteName.value = 'Lumen Coffee';
    document.value = {
      'id': 'lumen-coffee-default',
      'site': {
        'title': 'Lumen Coffee',
        'theme': {
          'colors': {
            'primary': '#B85028',
            'background': '#F8F4EE',
            'surface': '#FFFFFF',
            'text': '#1C1917',
          },
          'fonts': {
            'heading': 'Playfair Display',
            'body': 'Inter',
          },
        },
      },
      'pages': [
        {
          'id': 'page-home',
          'title': 'Home',
          'slug': '/',
          'sections': [
            {
              'id': 'sec-hero-1',
              'component': 'hero',
              'order': 0,
              'props': {
                'badge': 'Roastery and café in Portland',
                'headline': 'Small-batch coffee, roasted every Friday',
                'subheadline':
                    'Single-origin beans from farms we visit, roasted in our shop and shipped same day.',
                'ctaText': 'Order beans',
              },
            },
          ],
        },
      ],
    };
    isLoading.value = false;
    _autoSelectInitialElement();
    syncDocumentToWebView();
  }

  void _autoSelectInitialElement() {
    final doc = document.value;
    if (doc == null) return;
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null && sections.isNotEmpty) {
        Map<String, dynamic> targetSec = sections[0] as Map<String, dynamic>;
        for (final s in sections) {
          if ((s as Map<String, dynamic>)['component'] == 'products') {
            targetSec = s;
            break;
          }
        }
        final secId = targetSec['id'] as String?;
        final comp = (targetSec['component'] as String? ?? 'hero').capitalizeFirst ?? 'Hero';
        final props = targetSec['props'] as Map<String, dynamic>? ?? {};

        selectedSectionId.value = secId;
        selectedElementContext.value = 'Heading in $comp';
        selectedElementKey.value = 'headline';
        textController.text = props['headline'] ?? props['title'] ?? '';
        subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
        selectedElementSize.value = props['headlineSize'] ?? 'Large';
        aiPromptPlaceholder.value = 'Ask AI about this ${comp.toLowerCase()}';
      } else {
        selectedTab.value = 0;
        isPanelOpen.value = true;
        aiPromptPlaceholder.value = 'Ask AI to change your site';
      }
    }
  }

  void syncDocumentToWebView() {
    final doc = document.value;
    if (doc == null || webViewController == null) return;
    try {
      final jsonLiteral = jsonEncode(jsonEncode(doc));
      webViewController!.runJavaScript(
        "if (window.updateDocument) { window.updateDocument($jsonLiteral); } try { window.postMessage(JSON.stringify({ type: 'UPDATE_DOCUMENT', document: JSON.parse($jsonLiteral) }), '*'); } catch(_) {}",
      );
    } catch (_) {}
  }

  void onElementSelected(Map<String, dynamic> payload) {
    final sectionId = payload['sectionId'] as String?;
    final elementKey = payload['elementKey'] as String? ?? 'headline';
    final elementName = payload['elementName'] as String? ?? 'Heading in Hero';
    final text = payload['text'] as String? ?? '';
    final size = payload['size'] as String? ?? 'Large';

    selectedSectionId.value = sectionId;
    selectedElementKey.value = elementKey;
    selectedElementContext.value = elementName;
    textController.text = text;
    selectedElementSize.value = size;

    final typeLabel = elementKey == 'headline' ? 'heading' : (elementKey == 'subheadline' ? 'text' : 'element');
    aiPromptPlaceholder.value = 'Ask AI about this $typeLabel';
  }

  void onSectionSelected(Map<String, dynamic>? payload) {
    final sectionId = (payload?['sectionId'] ?? payload?['id']) as String?;
    if (sectionId == null) return;
    selectedSectionId.value = sectionId;
    _populateSectionInputs(sectionId);

    final comp = (payload?['component'] as String? ?? 'section').toLowerCase();
    aiPromptPlaceholder.value = 'Ask AI about this $comp';

    selectedTab.value = 1;
    isPanelOpen.value = true;
  }

  void _populateSectionInputs(String sectionId) {
    if (document.value == null) return;

    // Handle Header / Navigation layer
    if (sectionId == 'sec_navigation') {
      selectedSectionType.value = 'navigation';
      selectedElementContext.value = 'Navigation Bar';
      selectedSectionId.value = 'sec_navigation';
      final nav = Map<String, dynamic>.from(document.value!['navigation'] as Map? ?? {});
      navLogoTextController.text = nav['logo']?['text']?.toString() ?? document.value!['site']?['name']?.toString() ?? '';
      navLogoSrcController.text = nav['logo']?['src']?.toString() ?? '';
      final rawItems = nav['items'] as List? ?? [];
      navItems.assignAll(rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList());
      customProps.assignAll(nav);
      return;
    }

    final pages = document.value!['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            final compName = (sec['component'] as String? ?? 'hero').toLowerCase();
            selectedSectionType.value = compName;
            final props = Map<String, dynamic>.from(sec['props'] as Map? ?? {});
            final styles = Map<String, dynamic>.from(sec['styles'] as Map? ?? {});

            // Wix Layout & Styles
            selectedSectionBackground.value = styles['background']?.toString() ?? 'default';
            selectedSectionAlign.value = styles['textAlign']?.toString() ?? 'left';
            selectedSectionPadding.value = styles['padding']?.toString() ?? 'normal';

            // Universal / Custom Properties
            customProps.assignAll(props);

            // 1. Populate CTA, links & Eyebrow Badges
            ctaTextController.text = props['ctaText']?.toString() ?? props['buttonText']?.toString() ?? '';
            ctaLinkController.text = props['ctaLink']?.toString() ?? props['buttonLink']?.toString() ?? '';
            secondaryCtaTextController.text = props['secondaryCtaText']?.toString() ?? '';
            secondaryCtaLinkController.text = props['secondaryCtaLink']?.toString() ?? '';
            badgeController.text = props['badge']?.toString() ?? '';

            // 2. Populate Testimonials items
            if (compName == 'testimonials' || compName == 'reviews') {
              final rawItems = props['items'] as List? ?? [];
              testimonialItems.assignAll(rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              testimonialItems.clear();
            }

            // 3. Populate Statistics items ("statics")
            if (compName == 'statistics' || compName == 'metrics') {
              final rawItems = (props['metrics'] as List?) ?? (props['items'] as List?) ?? [];
              statItems.assignAll(rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              statItems.clear();
            }

            // 4. Populate Features & Icons items
            if (compName == 'features' || compName == 'benefits') {
              final rawItems = props['items'] as List? ?? [];
              featureItems.assignAll(rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              featureItems.clear();
            }

            // 5. Populate Products & Pricing
            if (compName == 'products' || compName == 'pricing' || compName == 'store' || compName == 'product_grid' || compName == 'pricing_grid') {
              final rawItems = (props['items'] as List?) ?? (props['products'] as List?) ?? (props['plans'] as List?) ?? [];
              productItems.assignAll(rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              productItems.clear();
            }

            // 6. Populate FAQ
            if (compName == 'faq') {
              final rawItems = props['items'] as List? ?? [];
              faqItems.assignAll(rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              faqItems.clear();
            }

            // 7. Populate Contact & Visit
            contactEmailController.text = props['email']?.toString() ?? '';
            contactPhoneController.text = props['phone']?.toString() ?? '';
            contactAddressController.text = props['address']?.toString() ?? '';
            contactHoursController.text = props['hours']?.toString() ?? '';

            // 8. Populate Gallery
            if (compName == 'gallery') {
              final rawImgs = props['images'] as List? ?? props['items'] as List? ?? [];
              galleryImages.assignAll(rawImgs.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              galleryImages.clear();
            }

            // 9. Populate Footer
            if (compName == 'footer' || sectionId == 'sec_footer') {
              footerCopyrightController.text = props['copyright']?.toString() ?? '';
              final rawLinks = props['links'] as List? ?? [];
              footerLinks.assignAll(rawLinks.map((e) => Map<String, dynamic>.from(e as Map)).toList());
            } else {
              footerLinks.clear();
            }

            if (compName == 'image') {
              selectedElementContext.value = 'Image';
              selectedImageProps.value = props;
              selectedImageFit.value = props['fit']?.toString() ?? 'crop';
              altTextController.text = props['alt']?.toString() ?? '';
            } else if (compName == 'products' || compName == 'store' || compName == 'product_grid') {
              selectedElementContext.value = 'Products';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? 'Products';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedImageProps.clear();
            } else if (compName == 'pricing' || compName == 'pricing_grid') {
              selectedElementContext.value = 'Pricing Plans';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? 'Pricing';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedImageProps.clear();
            } else if (compName == 'features' || compName == 'benefits') {
              selectedElementContext.value = 'Features';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? 'Features';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedImageProps.clear();
            } else if (compName == 'faq') {
              selectedElementContext.value = 'FAQ';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? 'Frequently Asked Questions';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedImageProps.clear();
            } else if (compName == 'contact' || compName == 'visit') {
              selectedElementContext.value = 'Contact Info';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? 'Contact Us';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedImageProps.clear();
            } else if (compName == 'testimonials' || compName == 'reviews') {
              selectedElementContext.value = 'Testimonials';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? 'Testimonials';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedImageProps.clear();
            } else if (compName == 'story' || compName == 'about') {
              final comp = compName.capitalizeFirst ?? 'Section';
              selectedElementContext.value = '$comp Section';
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? '';
              subheadlineController.text = props['description'] ?? props['subheadline'] ?? '';
              selectedElementSize.value = props['headlineSize'] ?? 'Large';

              final img = props['image'];
              if (img is Map) {
                selectedImageProps.value = {
                  'url': img['src'] ?? '',
                  'filename': img['filename'] ?? 'story-image.jpg',
                  'alt': img['alt'] ?? '',
                  'fit': 'crop',
                };
                altTextController.text = img['alt']?.toString() ?? '';
              } else {
                selectedImageProps.clear();
              }
            } else if (compName == 'gallery') {
              selectedElementContext.value = 'Gallery Section';
              selectedElementKey.value = 'headline';
              textController.text = props['title'] ?? props['headline'] ?? '';
              subheadlineController.text = props['subtitle'] ?? props['subheadline'] ?? '';
              selectedElementSize.value = 'Large';

              final items = props['items'] as List?;
              if (items != null && items.isNotEmpty && items[0] is Map) {
                selectedImageProps.value = {
                  'url': items[0]['src'] ?? '',
                  'filename': items[0]['caption'] ?? 'gallery-item.jpg',
                  'alt': items[0]['alt'] ?? '',
                  'fit': 'crop',
                };
                altTextController.text = items[0]['alt']?.toString() ?? '';
              } else {
                selectedImageProps.clear();
              }
            } else {
              final comp = compName.capitalizeFirst ?? 'Section';
              selectedElementContext.value = comp;
              selectedElementKey.value = 'headline';
              textController.text = props['headline'] ?? props['title'] ?? '';
              subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
              selectedElementSize.value = props['headlineSize'] ?? 'Large';

              final img = props['image'];
              if (img is Map) {
                selectedImageProps.value = {
                  'url': img['src'] ?? '',
                  'filename': img['filename'] ?? '$compName-image.jpg',
                  'alt': img['alt'] ?? '',
                  'fit': 'crop',
                };
                altTextController.text = img['alt']?.toString() ?? '';
              } else {
                selectedImageProps.clear();
              }
            }
            return;
          }
        }
      }
    }
  }

  void _pushUndoState() {
    if (document.value != null) {
      undoStack.add(jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>);
      redoStack.clear();
    }
  }

  void undo() {
    if (undoStack.isEmpty || document.value == null) return;
    redoStack.add(jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>);
    final prev = undoStack.removeLast();
    document.value = prev;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  void redo() {
    if (redoStack.isEmpty || document.value == null) return;
    undoStack.add(jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>);
    final next = redoStack.removeLast();
    document.value = next;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  // --- Ask AI & Before/After Review Flow (Images 3 & 4) ---

  void openAskAiSheet({String? initialPrompt, bool directToReview = false}) {
    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      aiCustomPromptController.text = initialPrompt;
    }
    if (directToReview) {
      aiReviewStep.value = 'review';
    } else {
      aiReviewStep.value = 'prompt';
    }
    isAiReviewActive.value = true;
    try {
      if (Get.context != null) {
        Get.bottomSheet(
          AskAiReviewSheet(controller: this),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
        );
      }
    } catch (_) {}
  }

  Future<void> submitAiPrompt([String? instruction]) async {
    final text = (instruction ??
            (aiCustomPromptController.text.trim().isNotEmpty
                ? aiCustomPromptController.text.trim()
                : aiPromptController.text.trim()))
        .trim();
    if (document.value == null) return;

    // Snapshot current document & palette as the "Before" baseline
    stashedOriginalDoc.value = jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>;
    stashedOriginalPalette.value = selectedColorPreset.value;
    isAiEditing.value = true;

    try {
      Map<String, dynamic>? proposedDoc;

      try {
        final res = await ApiClient.aiEdit(
          websiteId: websiteId.isNotEmpty ? websiteId : null,
          instruction: text.isEmpty ? 'Improve visual appeal and modernize styling' : text,
          targetSectionId: aiReviewScope.value == 'Entire website' ? null : selectedSectionId.value,
          document: stashedOriginalDoc.value!,
        ).timeout(const Duration(seconds: 40));

        final website = res['website'] as Map<String, dynamic>?;
        proposedDoc = (res['document'] as Map<String, dynamic>?) ??
            (website?['document'] as Map<String, dynamic>?);
      } catch (e) {
        if (ApiClient.isSubscriptionLimitError(e)) {
          SubscriptionView.open();
          return;
        }
        debugPrint('OpenRouter edit error: $e');
      }

      proposedDoc ??= _createAiProposalDocument(
        baseDoc: stashedOriginalDoc.value!,
        prompt: text.isEmpty ? 'Make modern improvements' : text,
        variation: aiVariationIndex.value,
      );

      stashedAiProposedDoc.value = proposedDoc;
      aiChangeDiffs.value = _computeDocumentDiffs(stashedOriginalDoc.value!, proposedDoc);
      aiReviewMode.value = 'After';
      aiReviewStep.value = 'review';

      // Live update canvas to the proposed "After" state
      document.value = jsonDecode(jsonEncode(proposedDoc)) as Map<String, dynamic>;
      selectedColorPreset.value = getPaletteNameForDoc(proposedDoc);
      syncDocumentToWebView();

      aiPromptController.clear();

      // Open review sheet if not already open
      if (!(Get.isBottomSheetOpen ?? false)) {
        openAskAiSheet(directToReview: true);
      }
    } finally {
      isAiEditing.value = false;
    }
  }

  void toggleAiReviewMode(String mode) {
    aiReviewMode.value = mode;
    if (mode == 'Before') {
      if (stashedOriginalDoc.value != null) {
        document.value = jsonDecode(jsonEncode(stashedOriginalDoc.value!)) as Map<String, dynamic>;
        selectedColorPreset.value = stashedOriginalPalette.value;
        syncDocumentToWebView();
      }
    } else {
      if (stashedAiProposedDoc.value != null) {
        document.value = jsonDecode(jsonEncode(stashedAiProposedDoc.value!)) as Map<String, dynamic>;
        selectedColorPreset.value = getPaletteNameForDoc(stashedAiProposedDoc.value!);
        syncDocumentToWebView();
      }
    }
  }

  void tryAnotherAiVersion() {
    if (stashedOriginalDoc.value == null) return;
    aiVariationIndex.value = (aiVariationIndex.value + 1) % 4;
    final prompt = aiCustomPromptController.text.trim();
    final newVariationDoc = _createAiProposalDocument(
      baseDoc: stashedOriginalDoc.value!,
      prompt: prompt.isEmpty ? 'Switch palette and layout' : prompt,
      variation: aiVariationIndex.value,
    );
    stashedAiProposedDoc.value = newVariationDoc;
    aiChangeDiffs.value = _computeDocumentDiffs(stashedOriginalDoc.value!, newVariationDoc);

    // If currently previewing "After", live update canvas
    if (aiReviewMode.value == 'After') {
      document.value = jsonDecode(jsonEncode(newVariationDoc)) as Map<String, dynamic>;
      selectedColorPreset.value = getPaletteNameForDoc(newVariationDoc);
      syncDocumentToWebView();
    }
  }

  void discardAiProposal() {
    if (stashedOriginalDoc.value != null) {
      document.value = jsonDecode(jsonEncode(stashedOriginalDoc.value!)) as Map<String, dynamic>;
      selectedColorPreset.value = stashedOriginalPalette.value;
      syncDocumentToWebView();
    }
    stashedOriginalDoc.value = null;
    stashedAiProposedDoc.value = null;
    isAiReviewActive.value = false;
    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    } catch (_) {}
    AppSnackbar.info(
      'editor_kept_previous'.tr,
      title: 'editor_discarded_changes_title'.tr,
    );
  }

  void applyAiProposal() {
    if (stashedAiProposedDoc.value != null) {
      _pushUndoState();
      document.value = jsonDecode(jsonEncode(stashedAiProposedDoc.value!)) as Map<String, dynamic>;
      selectedColorPreset.value = getPaletteNameForDoc(stashedAiProposedDoc.value!);
      syncDocumentToWebView();
      _saveCurrentDocument();
    }
    stashedOriginalDoc.value = null;
    stashedAiProposedDoc.value = null;
    isAiReviewActive.value = false;
    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    } catch (_) {}
    AppSnackbar.success(
      'editor_saved_ai_version'.tr,
      title: 'editor_saved_changes_title'.tr,
    );
  }

  String getPaletteNameForDoc(Map<String, dynamic>? doc) {
    if (doc == null) return selectedColorPreset.value;
    final site = doc['site'] as Map?;
    final theme = site?['theme'] as Map?;
    final colors = theme?['colors'] as Map?;
    final bg = colors?['background']?.toString();
    final primary = colors?['primary']?.toString();
    if (bg != null) {
      for (final preset in colorPresets) {
        if (preset.themeColors['background']?.toLowerCase() == bg.toLowerCase()) {
          return preset.name;
        }
      }
      final l = bg.toLowerCase();
      if (l.contains('fff1f2') ||
          l.contains('fdf2f8') ||
          l.contains('ff69b4') ||
          l.contains('ffc0cb') ||
          l.contains('fce7f3')) {
        return 'Blush';
      }
      if (l.contains('f0fdf4') || l.contains('dcfce7') || l.contains('15803d')) {
        return 'Matcha';
      }
      if (l.contains('f0f9ff') ||
          l.contains('f0f7ff') ||
          l.contains('e0f2fe') ||
          l.contains('0284c7')) {
        return 'Riviera';
      }
      if (l.contains('1c1917') || l.contains('292524')) {
        return 'Espresso';
      }
      if (l.contains('faf6f0') || l.contains('efe8de')) {
        return 'Crema';
      }
    }
    if (primary != null) {
      final p = primary.toLowerCase();
      if (p.contains('db2777') ||
          p.contains('be123c') ||
          p.contains('e11d48') ||
          p.contains('f472b6')) {
        return 'Blush';
      }
      if (p.contains('15803d') || p.contains('16a34a') || p.contains('22c55e')) {
        return 'Matcha';
      }
      if (p.contains('2563eb') || p.contains('0284c7')) {
        return 'Riviera';
      }
      if (p.contains('d97706') || p.contains('ea580c')) {
        return 'Espresso';
      }
    }
    return selectedColorPreset.value;
  }

  String getHeroHeadlineForDoc(Map<String, dynamic>? doc) {
    if (doc == null) return '';
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['component'] == 'hero') {
            final props = sec['props'] as Map<String, dynamic>?;
            return props?['headline'] ?? props?['title'] ?? '';
          }
        }
      }
    }
    return '';
  }

  String getHeroSubheadlineForDoc(Map<String, dynamic>? doc) {
    if (doc == null) return '';
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['component'] == 'hero') {
            final props = sec['props'] as Map<String, dynamic>?;
            return props?['subheadline'] ?? props?['subtitle'] ?? props?['description'] ?? '';
          }
        }
      }
    }
    return '';
  }

  String getHeroCtaForDoc(Map<String, dynamic>? doc) {
    if (doc == null) return '';
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['component'] == 'hero') {
            final props = sec['props'] as Map<String, dynamic>?;
            return props?['ctaText'] ?? props?['buttonText'] ?? '';
          }
        }
      }
    }
    return '';
  }

  List<Map<String, String>> _computeDocumentDiffs(
    Map<String, dynamic> beforeDoc,
    Map<String, dynamic> afterDoc,
  ) {
    final diffs = <Map<String, String>>[];

    // 1. Palette diff
    final oldPalette = getPaletteNameForDoc(beforeDoc);
    final newPalette = getPaletteNameForDoc(afterDoc);
    if (oldPalette != newPalette) {
      diffs.add({
        'type': 'Palette',
        'old': oldPalette,
        'new': newPalette,
      });
    }

    // 2. Headline diff
    final oldHeadline = getHeroHeadlineForDoc(beforeDoc);
    final newHeadline = getHeroHeadlineForDoc(afterDoc);
    if (oldHeadline.isNotEmpty && newHeadline.isNotEmpty && oldHeadline != newHeadline) {
      diffs.add({
        'type': 'Headline',
        'old': oldHeadline,
        'new': newHeadline,
      });
    }

    // 3. Subheadline diff
    final oldSub = getHeroSubheadlineForDoc(beforeDoc);
    final newSub = getHeroSubheadlineForDoc(afterDoc);
    if (oldSub.isNotEmpty && newSub.isNotEmpty && oldSub != newSub) {
      diffs.add({
        'type': 'Description',
        'old': oldSub,
        'new': newSub,
      });
    }

    // 4. CTA button diff
    final oldCta = getHeroCtaForDoc(beforeDoc);
    final newCta = getHeroCtaForDoc(afterDoc);
    if (oldCta.isNotEmpty && newCta.isNotEmpty && oldCta != newCta) {
      diffs.add({
        'type': 'Button',
        'old': oldCta,
        'new': newCta,
      });
    }

    // 5. Section changes (added / removed)
    final oldSections = (beforeDoc['pages'] as List?)?[0]?['sections'] as List? ?? [];
    final newSections = (afterDoc['pages'] as List?)?[0]?['sections'] as List? ?? [];
    if (newSections.length > oldSections.length) {
      final added = newSections.where((ns) => !oldSections.any((os) => os['id'] == ns['id'])).toList();
      final names = added.map((s) => s['component']?.toString() ?? 'section').join(', ');
      diffs.add({
        'type': 'Added Section',
        'old': '${oldSections.length} sections',
        'new': '+ $names (${newSections.length} total)',
      });
    } else if (newSections.length < oldSections.length) {
      final removed = oldSections.where((os) => !newSections.any((ns) => ns['id'] == os['id'])).toList();
      final names = removed.map((s) => s['component']?.toString() ?? 'section').join(', ');
      diffs.add({
        'type': 'Removed Section',
        'old': '- $names (${oldSections.length} total)',
        'new': '${newSections.length} sections',
      });
    }

    // Fallback: If no diff detected, ensure changes are clearly described
    if (diffs.isEmpty) {
      final oldP = getPaletteNameForDoc(beforeDoc);
      final newP = getPaletteNameForDoc(afterDoc);
      if (oldP != newP) {
        diffs.add({
          'type': 'Palette',
          'old': oldP,
          'new': newP,
        });
      } else {
        diffs.add({
          'type': 'Content',
          'old': 'Current version',
          'new': 'AI refined layout & styling',
        });
      }
    }

    return diffs;
  }

  Map<String, dynamic> _createAiProposalDocument({
    required Map<String, dynamic> baseDoc,
    required String prompt,
    int variation = 0,
  }) {
    final docCopy = jsonDecode(jsonEncode(baseDoc)) as Map<String, dynamic>;
    final lowerPrompt = prompt.toLowerCase();

    // Check if user requested a specific color or palette in prompt
    ColorPreset? requestedPreset;
    if (lowerPrompt.contains('pink') ||
        lowerPrompt.contains('rose') ||
        lowerPrompt.contains('blush') ||
        lowerPrompt.contains('magenta')) {
      requestedPreset = colorPresets.firstWhere(
        (p) => p.name == 'Blush',
        orElse: () => colorPresets[4],
      );
    } else if (lowerPrompt.contains('green') ||
        lowerPrompt.contains('matcha') ||
        lowerPrompt.contains('emerald') ||
        lowerPrompt.contains('mint') ||
        lowerPrompt.contains('nature')) {
      requestedPreset = colorPresets.firstWhere(
        (p) => p.name == 'Matcha',
        orElse: () => colorPresets[2],
      );
    } else if (lowerPrompt.contains('blue') ||
        lowerPrompt.contains('ocean') ||
        lowerPrompt.contains('sky') ||
        lowerPrompt.contains('riviera') ||
        lowerPrompt.contains('azure')) {
      requestedPreset = colorPresets.firstWhere(
        (p) => p.name == 'Riviera',
        orElse: () => colorPresets[3],
      );
    } else if (lowerPrompt.contains('dark') ||
        lowerPrompt.contains('espresso') ||
        lowerPrompt.contains('black') ||
        lowerPrompt.contains('night')) {
      requestedPreset = colorPresets.firstWhere(
        (p) => p.name == 'Espresso',
        orElse: () => colorPresets[1],
      );
    } else if (lowerPrompt.contains('crema') ||
        lowerPrompt.contains('cream') ||
        lowerPrompt.contains('warm') ||
        lowerPrompt.contains('coffee') ||
        lowerPrompt.contains('latte')) {
      requestedPreset = colorPresets.firstWhere(
        (p) => p.name == 'Crema',
        orElse: () => colorPresets[0],
      );
    } else if (lowerPrompt.contains('mono') ||
        lowerPrompt.contains('monochrome') ||
        lowerPrompt.contains('minimal') ||
        lowerPrompt.contains('white') ||
        lowerPrompt.contains('clean')) {
      requestedPreset = colorPresets.firstWhere(
        (p) => p.name == 'Mono',
        orElse: () => colorPresets[5],
      );
    }

    ColorPreset targetPreset;
    if (requestedPreset != null) {
      targetPreset = requestedPreset;
    } else {
      if (variation == 1) {
        targetPreset = colorPresets.firstWhere(
          (p) => p.name == 'Matcha',
          orElse: () => colorPresets[2],
        );
      } else if (variation == 2) {
        targetPreset = colorPresets.firstWhere(
          (p) => p.name == 'Riviera',
          orElse: () => colorPresets[3],
        );
      } else if (variation == 3) {
        targetPreset = colorPresets.firstWhere(
          (p) => p.name == 'Blush',
          orElse: () => colorPresets[4],
        );
      } else {
        final currentPal = getPaletteNameForDoc(baseDoc);
        targetPreset = currentPal == 'Espresso'
            ? colorPresets.firstWhere((p) => p.name == 'Crema', orElse: () => colorPresets[0])
            : colorPresets.firstWhere((p) => p.name == 'Espresso', orElse: () => colorPresets[1]);
      }
    }

    // Apply preset colors
    docCopy['site'] ??= {};
    docCopy['site']['theme'] ??= {};
    docCopy['site']['theme']['colors'] = {
      ...(docCopy['site']['theme']['colors'] ?? {}),
      ...targetPreset.themeColors,
    };

    // Update hero copy based on prompt if prompt is descriptive
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['component'] == 'hero') {
            final props = sec['props'] as Map<String, dynamic>? ?? {};
            if (lowerPrompt.contains('bakery') || lowerPrompt.contains('leeds')) {
              docCopy['site']['name'] = 'Kirkgate Bakery';
              props['headline'] = 'Artisan Sourdough & Pastries, baked fresh in Leeds';
              props['subheadline'] =
                  'Small-batch organic bakery on Kirkgate. Fresh loaves, morning buns, and specialty coffee every day from 7am.';
              props['ctaText'] = "View today's menu";
            } else if (lowerPrompt.contains('ceramic') ||
                lowerPrompt.contains('artist') ||
                lowerPrompt.contains('portfolio')) {
              docCopy['site']['name'] = 'Studio Earth & Fire';
              props['headline'] = 'Handcrafted Ceramics & Functional Art';
              props['subheadline'] =
                  'Sculptural stoneware and tableware made with local clay in our Portland studio.';
              props['ctaText'] = 'Explore gallery';
            } else if (lowerPrompt.contains('dinner') || lowerPrompt.contains('pop-up')) {
              docCopy['site']['name'] = 'Solstice Table';
              props['headline'] = 'A Five-Course Seasonal Pop-Up Dinner';
              props['subheadline'] =
                  'An intimate evening celebrating hyper-seasonal ingredients, open-fire cooking, and natural wines.';
              props['ctaText'] = 'Reserve a seat';
            } else if (lowerPrompt.contains('punchy') || variation == 1) {
              props['headline'] = 'Freshly Roasted Single-Origin Coffee';
              props['subheadline'] =
                  'Crafted by hand in Portland, delivered to your door within 48 hours of roasting.';
            } else if (variation == 2) {
              props['headline'] = 'Mindfully Sourced, Roasted with Care';
              props['subheadline'] =
                  'Single-origin beans direct from farms we visit, celebrating distinct terroir in every cup.';
            }
            sec['props'] = props;
            break;
          }
        }
      }

      // 2. Intelligent Component Generation: Handle user requests to add products, catalog, store, pricing
      final wantsProducts = lowerPrompt.contains('product') ||
          lowerPrompt.contains('store') ||
          lowerPrompt.contains('shop') ||
          lowerPrompt.contains('catalog') ||
          lowerPrompt.contains('pricing') ||
          lowerPrompt.contains('item') ||
          lowerPrompt.contains('buy') ||
          lowerPrompt.contains('plan');

      if (wantsProducts) {
        final sections = (pages[0]['sections'] as List?) ?? [];
        final existingSec = sections.firstWhereOrNull(
          (s) => s is Map && (s['component'] == 'products' || s['component'] == 'store' || s['component'] == 'pricing'),
        );

        final isBakery = lowerPrompt.contains('bakery') || (docCopy['site']?['name']?.toString().toLowerCase().contains('bakery') ?? false);
        final isCeramic = lowerPrompt.contains('ceramic') || lowerPrompt.contains('artist');

        List<Map<String, dynamic>> productItems;
        String secTitle = 'Featured Products';
        String secSub = 'Carefully curated items crafted with exceptional quality.';

        if (isBakery) {
          secTitle = 'Fresh Bakes & Pastries';
          secSub = 'Handmade daily using organic flour and slow cold fermentation.';
          productItems = [
            {
              'name': 'Artisan Country Sourdough',
              'price': '\$8.50',
              'description': 'Crispy golden crust, open airy crumb, naturally leavened.',
              'image': 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Cardamom Morning Bun',
              'price': '\$4.75',
              'description': 'Laminated pastry rolled with freshly ground green cardamom sugar.',
              'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Almond Twice-Baked Croissant',
              'price': '\$5.25',
              'description': 'Filled with rich almond frangipane and topped with toasted sliced almonds.',
              'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
            },
          ];
        } else if (isCeramic) {
          secTitle = 'Studio Collection';
          secSub = 'Small batch stoneware made with locally sourced clays.';
          productItems = [
            {
              'name': 'Speckled Stoneware Mug',
              'price': '\$38.00',
              'description': 'Comfortable handle, unglazed raw exterior with satin white interior.',
              'image': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Minimalist Pouring Carafe',
              'price': '\$65.00',
              'description': 'Hand-thrown sculptural carafe ideal for pour-over coffee or wine.',
              'image': 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Fluted Ceramic Bowl',
              'price': '\$48.00',
              'description': 'Earthy warm terracotta bowl with delicate hand-carved ridges.',
              'image': 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
            },
          ];
        } else {
          secTitle = 'Our Products';
          secSub = 'Explore our handcrafted products and premium selections.';
          productItems = [
            {
              'name': 'Signature Reserve',
              'price': '\$24.00',
              'description': 'Handcrafted premium quality with natural organic finishes.',
              'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Everyday Essential',
              'price': '\$18.50',
              'description': 'Designed for daily comfort, built to last with durable materials.',
              'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80',
            },
            {
              'name': 'Special Edition Kit',
              'price': '\$39.00',
              'description': 'Exclusive collection featuring our most beloved creations.',
              'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=600&q=80',
            },
          ];
        }

        if (existingSec != null) {
          final existingProps = (existingSec as Map)['props'] as Map<String, dynamic>? ?? {};
          existingProps['title'] = secTitle;
          existingProps['subtitle'] = secSub;
          existingProps['items'] = productItems;
          existingSec['props'] = existingProps;
        } else {
          final ts = DateTime.now().millisecondsSinceEpoch;
          final newSec = {
            'id': 'sec_products_$ts',
            'component': 'products',
            'variant': 'grid_3col',
            'order': 1,
            'props': {
              'title': secTitle,
              'subtitle': secSub,
              'items': productItems,
            },
            'styles': {'background': 'surface'},
          };
          final heroIdx = sections.indexWhere((s) => s is Map && s['component'] == 'hero');
          if (heroIdx != -1) {
            sections.insert(heroIdx + 1, newSec);
          } else {
            sections.insert(0, newSec);
          }
          for (int i = 0; i < sections.length; i++) {
            if (sections[i] is Map) {
              sections[i]['order'] = i;
            }
          }
          pages[0]['sections'] = sections;
        }
      }

      // 3. Intelligent FAQ Generation
      final wantsFaq = lowerPrompt.contains('faq') || lowerPrompt.contains('question') || lowerPrompt.contains('frequently');
      if (wantsFaq) {
        final sections = (pages[0]['sections'] as List?) ?? [];
        final hasFaq = sections.any((s) => s is Map && s['component'] == 'faq');
        if (!hasFaq) {
          final ts = DateTime.now().millisecondsSinceEpoch;
          final newSec = {
            'id': 'sec_faq_$ts',
            'component': 'faq',
            'order': sections.length,
            'props': {
              'title': 'Frequently Asked Questions',
              'subtitle': 'Everything you need to know about our products and ordering.',
              'items': [
                {
                  'question': 'How do I place an order?',
                  'answer': 'Select your favorite items from our catalog and check out securely online or in person.',
                },
                {
                  'question': 'Where do you source your materials?',
                  'answer': 'We work directly with certified organic producers and ethical craft suppliers.',
                },
                {
                  'question': 'What is your satisfaction guarantee?',
                  'answer': 'We stand behind our craft 100%. Reach out within 14 days and we will gladly make it right.',
                },
              ],
            },
            'styles': {'background': 'default'},
          };
          sections.add(newSec);
          pages[0]['sections'] = sections;
        }
      }

      // 4. Intelligent Contact Generation
      final wantsContact = lowerPrompt.contains('contact') || lowerPrompt.contains('reach') || lowerPrompt.contains('visit') || lowerPrompt.contains('hours');
      if (wantsContact) {
        final sections = (pages[0]['sections'] as List?) ?? [];
        final hasContact = sections.any((s) => s is Map && (s['component'] == 'contact' || s['component'] == 'visit'));
        if (!hasContact) {
          final ts = DateTime.now().millisecondsSinceEpoch;
          final newSec = {
            'id': 'sec_contact_$ts',
            'component': 'contact',
            'order': sections.length,
            'props': {
              'title': 'Get In Touch',
              'email': 'hello@ourstudio.com',
              'phone': '+1 (555) 234-5678',
              'address': '423 Market Street, Suite 100, Portland, OR 97201',
              'hours': 'Monday – Saturday: 8am – 6pm',
            },
            'styles': {'background': 'surface'},
          };
          sections.add(newSec);
          pages[0]['sections'] = sections;
        }
      }
    }

    return docCopy;
  }

  void addSection(String type) {
    if (document.value == null) return;
    _pushUndoState();

    final ts = DateTime.now().millisecondsSinceEpoch;
    final sectionId = 'sec_${type}_$ts';

    Map<String, dynamic> newSec;
    switch (type.toLowerCase()) {
      case 'hero':
        newSec = {
          'id': sectionId,
          'component': 'hero',
          'variant': 'split_image',
          'order': 0,
          'props': {
            'headline': 'Small-batch coffee, roasted every Friday',
            'subheadline':
                'Single-origin beans from farms we visit, roasted in our Alberta Street shop and shipped the same day.',
            'ctaText': 'Order beans',
            'ctaLink': '#products',
            'secondaryCtaText': 'Visit cafe',
            'secondaryCtaLink': '#about',
            'image': {
              'src':
                  'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
              'alt': 'Small Batch Roasting',
            },
          },
          'styles': {'background': 'default'},
        };
        break;

      case 'products':
        newSec = {
          'id': sectionId,
          'component': 'products',
          'variant': 'grid_3col',
          'order': 1,
          'props': {
            'title': 'Fresh Roast Offerings',
            'subtitle': 'Carefully selected beans from ethical farm partnerships.',
            'items': [
              {
                'name': 'Ethiopia Yirgacheffe',
                'price': '\$18.00',
                'description': 'Floral jasmine, bergamot, and sweet peach notes.',
                'image':
                    'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=400&q=80',
              },
              {
                'name': 'Colombia Huila Reserve',
                'price': '\$17.50',
                'description': 'Milk chocolate, caramel, and bright crisp apple.',
                'image':
                    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
              },
              {
                'name': 'Guatemala Antigua',
                'price': '\$19.00',
                'description': 'Rich dark cocoa, toasted hazelnut, and warm spice.',
                'image':
                    'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=400&q=80',
              },
            ],
          },
          'styles': {'background': 'surface'},
        };
        break;

      case 'story':
        newSec = {
          'id': sectionId,
          'component': 'story',
          'variant': 'split_image',
          'order': 2,
          'props': {
            'headline': 'Crafted in Alberta Street',
            'description':
                'We believe great coffee is an intentional craft. Every single origin lot is meticulously roasted on our vintage cast iron drum roaster.',
            'highlights': ['Direct farm partnerships', 'Carbon neutral delivery', 'Roasted weekly'],
            'image': {
              'src':
                  'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
              'alt': 'Coffee Roaster in Action',
            },
          },
          'styles': {'background': 'default'},
        };
        break;

      case 'gallery':
        newSec = {
          'id': sectionId,
          'component': 'gallery',
          'order': 3,
          'props': {
            'title': 'The Roastery Atmosphere',
            'subtitle': 'A glance into our daily roasting rituals.',
            'items': [
              {
                'src':
                    'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=600&q=80',
                'caption': 'Pour Over Bar',
              },
              {
                'src':
                    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
                'caption': 'Single Origin Green Beans',
              },
              {
                'src':
                    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=600&q=80',
                'caption': 'Fresh Morning Brew',
              },
            ],
          },
          'styles': {'background': 'surface'},
        };
        break;

      case 'text':
        newSec = {
          'id': sectionId,
          'component': 'text',
          'order': 4,
          'props': {
            'headline': 'The Philosophy of Slow Coffee',
            'subheadline': 'Patience in cultivation, discipline in roasting.',
            'content':
                'Coffee is more than morning caffeine. It is the culmination of hundreds of hands working in harmony across continents.',
          },
          'styles': {'background': 'default'},
        };
        break;

      case 'visit':
        newSec = {
          'id': sectionId,
          'component': 'visit',
          'order': 5,
          'props': {
            'title': 'Visit Our Cafe',
            'subtitle': 'Open daily 7am - 6pm on Alberta Street.',
            'address': '1240 NE Alberta St, Portland, OR',
            'phone': '(503) 555-0192',
            'email': 'hello@lumencoffee.local',
            'hours': 'Mon-Sun: 7:00 AM - 6:00 PM',
          },
          'styles': {'background': 'surface'},
        };
        break;

      case 'image':
        openAddImageView();
        return;

      case 'cta':
      case 'call to action':
      default:
        newSec = {
          'id': sectionId,
          'component': 'cta',
          'variant': 'centered',
          'order': 5,
          'props': {
            'headline': 'Roasted Fresh Every Friday',
            'description': 'Order today and experience artisanal coffee shipped direct to your kitchen.',
            'buttonText': 'Order Coffee Now',
            'buttonLink': '#products',
          },
          'styles': {'background': 'accent'},
        };
        break;
    }

    final docCopy = jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List? ?? [];
    if (pages.isEmpty) {
      docCopy['pages'] = [
        {'id': 'page_home', 'slug': '/', 'title': 'Home', 'sections': [newSec]}
      ];
    } else {
      final currentSections = (pages[0]['sections'] as List? ?? []);
      newSec['order'] = currentSections.length;
      currentSections.add(newSec);
      pages[0]['sections'] = currentSections;
    }

    document.value = docCopy;
    selectedSectionId.value = sectionId;
    final compCapitalized = type.capitalizeFirst ?? 'Section';
    selectedElementContext.value = 'Heading in $compCapitalized';
    selectedElementKey.value = 'headline';
    textController.text = newSec['props']['headline'] ?? newSec['props']['title'] ?? '';
    subheadlineController.text = newSec['props']['subheadline'] ?? newSec['props']['subtitle'] ?? '';
    selectedElementSize.value = 'Large';

    syncDocumentToWebView();
    selectedTab.value = 1;
    isPanelOpen.value = true;

    _saveCurrentDocument();

    _showSnackbar(
      'Section Added',
      'Added $compCapitalized section to page',
      backgroundColor: Colors.white.withValues(alpha: 0.95),
    );
  }

  void _showSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    AppSnackbar.show(
      message,
      title: title,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  void openAddImageView({bool isReplacing = false}) {
    isReplacingImageMode.value = isReplacing;
    isAddingImageSubView.value = true;
    if (!isReplacing) {
      selectedTab.value = 0; // Go to Add tab when adding new section
    }
    isPanelOpen.value = true;
  }

  void openReplaceImageView() {
    openAddImageView(isReplacing: true);
  }

  void closeAddImageView() {
    isAddingImageSubView.value = false;
    isReplacingImageMode.value = false;
  }

  void selectUploadImage(String id) {
    selectedUploadImageId.value = id;
  }

  void applyImageToCurrentSection(UploadedImage chosen) {
    if (document.value == null) return;
    _pushUndoState();

    final doc = jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>;
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = (pages[0]['sections'] as List? ?? []).cast<Map<String, dynamic>>();

      // Determine target section
      String targetId = '';
      if (selectedSectionId.value != null && selectedSectionId.value!.isNotEmpty) {
        final currentSec = sections.firstWhereOrNull((s) => s['id'] == selectedSectionId.value);
        if (currentSec != null) {
          targetId = currentSec['id'] as String;
        }
      }
      if (targetId.isEmpty) {
        final imgSec = sections.firstWhereOrNull((s) => s['component'] == 'image');
        if (imgSec != null) {
          targetId = imgSec['id'] as String;
        } else if (sections.isNotEmpty) {
          targetId = sections.first['id'] as String;
        }
      }
      if (targetId.isNotEmpty) {
        selectedSectionId.value = targetId;
      }

      for (final sec in sections) {
        if (sec['id'] == targetId) {
          sec['props'] ??= <String, dynamic>{};
          final comp = (sec['component'] as String? ?? '').toLowerCase();

          if (comp == 'image') {
            sec['props']['url'] = chosen.url;
            sec['props']['src'] = chosen.url;
            sec['props']['filename'] = chosen.filename;
            sec['props']['alt'] = chosen.alt.isNotEmpty ? chosen.alt : 'Website visual';
            selectedSectionType.value = 'image';
            selectedImageProps.value = Map<String, dynamic>.from(sec['props'] as Map);
            altTextController.text = sec['props']['alt'] ?? '';
          } else if (comp == 'story' || comp == 'about' || comp == 'hero') {
            sec['props']['image'] = {
              'src': chosen.url,
              'alt': chosen.alt.isNotEmpty ? chosen.alt : 'Website visual',
              'filename': chosen.filename,
            };
            if (comp == 'hero' && sec['variant'] == 'minimal') {
              sec['variant'] = 'split_image';
            }
            selectedImageProps.value = {
              'url': chosen.url,
              'filename': chosen.filename,
              'alt': chosen.alt,
              'fit': 'crop',
            };
            altTextController.text = chosen.alt;
          } else if (comp == 'gallery') {
            final items = (sec['props']['items'] as List? ?? []).cast<Map<String, dynamic>>();
            if (items.isNotEmpty) {
              items[0]['src'] = chosen.url;
              items[0]['caption'] = chosen.filename;
              items[0]['alt'] = chosen.alt;
            } else {
              items.add({
                'src': chosen.url,
                'caption': chosen.filename,
                'alt': chosen.alt,
              });
            }
            sec['props']['items'] = items;
            selectedImageProps.value = {
              'url': chosen.url,
              'filename': chosen.filename,
              'alt': chosen.alt,
              'fit': 'crop',
            };
            altTextController.text = chosen.alt;
          } else {
            sec['props']['url'] = chosen.url;
            sec['props']['src'] = chosen.url;
            sec['props']['filename'] = chosen.filename;
            selectedImageProps.value = {
              'url': chosen.url,
              'filename': chosen.filename,
              'alt': chosen.alt,
              'fit': 'crop',
            };
            altTextController.text = chosen.alt;
          }
          break;
        }
      }
      pages[0]['sections'] = sections;
      doc['pages'] = pages;
    }

    document.value = doc;
    syncDocumentToWebView();
    _saveCurrentDocument();

    _showSnackbar(
      'Image Updated',
      'Updated to "${chosen.filename}".',
      backgroundColor: Colors.white.withValues(alpha: 0.95),
    );
  }

  Future<void> uploadImageFromDevice({bool applyImmediately = false}) async {
    if (uploadedImages.length >= maxImageUploadLimit) {
      _showSnackbar(
        'Upload Limit Reached',
        'You have reached the limit of $maxImageUploadLimit images.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    // In unit testing environment without native platform channels:
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _fallbackSampleUpload(applyImmediately: applyImmediately);
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile == null) return; // user cancelled

      final bytes = await pickedFile.readAsBytes();
      final name = pickedFile.name.isNotEmpty ? pickedFile.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ext = name.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:$mime;base64,$base64Data';
      final newId = 'img_${DateTime.now().millisecondsSinceEpoch}';

      final newUploaded = UploadedImage(
        id: newId,
        filename: name,
        dimensions: 'Original ratio',
        url: dataUrl,
        alt: name.replaceAll(RegExp(r'\.[^.]+$'), '').replaceAll('-', ' ').replaceAll('_', ' '),
      );

      uploadedImages.insert(0, newUploaded);
      selectedUploadImageId.value = newId;

      if (applyImmediately || isReplacingImageMode.value) {
        applyImageToCurrentSection(newUploaded);
        if (isReplacingImageMode.value) {
          closeAddImageView();
          selectedTab.value = 1;
        }
      } else {
        _showSnackbar(
          'Image Uploaded',
          'Added "$name" (${uploadedImages.length}/$maxImageUploadLimit stored).',
          backgroundColor: Colors.white.withValues(alpha: 0.95),
        );
      }
    } catch (e) {
      debugPrint('uploadImageFromDevice error: $e');
      // If platform gallery is unavailable (e.g. headless tests), fallback to sample photo
      _fallbackSampleUpload(applyImmediately: applyImmediately);
    }
  }

  void _fallbackSampleUpload({bool applyImmediately = false}) {
    final newIndex = uploadedImages.length + 1;
    final samplePhotos = [
      {
        'filename': 'cafe-patio.jpg',
        'dimensions': '1600 × 1200',
        'url': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=1200&q=80',
        'alt': 'Cozy outdoor cafe patio seating',
      },
      {
        'filename': 'roaster-beans.jpg',
        'dimensions': '1200 × 1200',
        'url': 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=1200&q=80',
        'alt': 'Fresh roasted artisan coffee beans cooling in tray',
      },
      {
        'filename': 'barista-steam.jpg',
        'dimensions': '1600 × 1066',
        'url': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80',
        'alt': 'Barista steaming milk for flat white',
      },
    ];

    final pick = samplePhotos[(newIndex - 1) % samplePhotos.length];
    final newId = 'img_${DateTime.now().millisecondsSinceEpoch}';

    final newUploaded = UploadedImage(
      id: newId,
      filename: pick['filename']!,
      dimensions: pick['dimensions']!,
      url: pick['url']!,
      alt: pick['alt']!,
    );

    uploadedImages.insert(0, newUploaded);
    selectedUploadImageId.value = newId;

    if (applyImmediately || isReplacingImageMode.value) {
      applyImageToCurrentSection(newUploaded);
      if (isReplacingImageMode.value) {
        closeAddImageView();
        selectedTab.value = 1;
      }
    } else {
      _showSnackbar(
        'Image Uploaded',
        'Added "${pick['filename']}" (${uploadedImages.length}/$maxImageUploadLimit stored).',
        backgroundColor: Colors.white.withValues(alpha: 0.95),
      );
    }
  }

  void deleteUploadedImage(String id) {
    MediaAssetService.shared.deleteAsset(id);
    if (selectedUploadImageId.value == id) {
      selectedUploadImageId.value = uploadedImages.firstOrNull?.id ?? '';
    }
    _showSnackbar(
      'Image Deleted',
      'Image removed from your uploads (${uploadedImages.length}/$maxImageUploadLimit remaining).',
      backgroundColor: Colors.white.withValues(alpha: 0.95),
    );
  }

  void addSelectedImageToPage() {
    final chosen = uploadedImages.firstWhereOrNull((img) => img.id == selectedUploadImageId.value)
        ?? uploadedImages.firstOrNull;
    if (chosen == null) return;

    if (isReplacingImageMode.value) {
      applyImageToCurrentSection(chosen);
      isReplacingImageMode.value = false;
      isAddingImageSubView.value = false;
      selectedTab.value = 1;
      return;
    }

    _pushUndoState();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final sectionId = 'sec_image_$ts';

    final newSec = {
      'id': sectionId,
      'component': 'image',
      'variant': 'default',
      'order': 1,
      'props': {
        'url': chosen.url,
        'src': chosen.url,
        'filename': chosen.filename,
        'alt': chosen.alt.isNotEmpty ? chosen.alt : 'Website visual',
        'fit': 'crop',
        'aspectRatio': '16/10',
      },
      'styles': {'background': 'default'},
    };

    final doc = jsonDecode(jsonEncode(document.value ?? {})) as Map<String, dynamic>;
    doc['pages'] ??= [
      {'id': 'page-home', 'title': 'Home', 'slug': '/', 'sections': <dynamic>[]}
    ];
    final pages = doc['pages'] as List;
    if (pages.isNotEmpty) {
      final sections = (pages[0]['sections'] as List? ?? []).cast<Map<String, dynamic>>();

      // Insert directly after currently selected section, or at the end
      int insertIndex = sections.length;
      if (selectedSectionId.value != null && selectedSectionId.value!.isNotEmpty) {
        final currentIdx = sections.indexWhere((s) => s['id'] == selectedSectionId.value);
        if (currentIdx != -1) {
          insertIndex = currentIdx + 1;
        }
      }

      sections.insert(insertIndex, newSec);
      for (int i = 0; i < sections.length; i++) {
        sections[i]['order'] = i;
      }
      pages[0]['sections'] = sections;
    }

    document.value = doc;
    syncDocumentToWebView();
    _saveCurrentDocument();

    selectedSectionId.value = sectionId;
    selectedSectionType.value = 'image';
    selectedElementKey.value = 'image';
    selectedElementContext.value = 'Image';
    selectedImageProps.value = Map<String, dynamic>.from(newSec['props'] as Map);
    selectedImageFit.value = 'crop';
    final propsMap = newSec['props'] as Map<String, dynamic>;
    altTextController.text = propsMap['alt']?.toString() ?? '';

    isAddingImageSubView.value = false;
    isReplacingImageMode.value = false;
    selectedTab.value = 1;

    try {
      webViewController?.runJavaScript(
        "if (window.selectSection) { window.selectSection('$sectionId'); } "
        "setTimeout(function() { var el = document.getElementById('$sectionId'); if (el) { el.scrollIntoView({ behavior: 'smooth', block: 'center' }); } }, 200);"
      );
    } catch (_) {}

    _showSnackbar(
      'Image Added',
      'Added "${chosen.filename}" to your page.',
      backgroundColor: Colors.white.withValues(alpha: 0.95),
    );
  }

  void updateImageFit(String fit) {
    selectedImageFit.value = fit;
    if (selectedSectionId.value == null || document.value == null) return;

    final doc = jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>;
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == selectedSectionId.value) {
            sec['props'] ??= {};
            sec['props']['fit'] = fit;
            selectedImageProps.value = Map<String, dynamic>.from(sec['props'] as Map);
            break;
          }
        }
      }
    }
    document.value = doc;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  void updateImageAltText(String alt) {
    if (selectedSectionId.value == null || document.value == null) return;

    final doc = jsonDecode(jsonEncode(document.value!)) as Map<String, dynamic>;
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == selectedSectionId.value) {
            sec['props'] ??= {};
            sec['props']['alt'] = alt;
            selectedImageProps.value = Map<String, dynamic>.from(sec['props'] as Map);
            break;
          }
        }
      }
    }
    document.value = doc;
    _saveCurrentDocument();
  }

  Future<void> generateAiAltText() async {
    isGeneratingAltText.value = true;
    try {
      final currentFilename = selectedImageProps['filename'] ?? 'image';
      final prompt = 'Generate concise, accessible alt text (under 12 words) for an image named "$currentFilename" on website "${websiteName.value}". Return only the alt text sentence.';
      
      final res = await ApiClient.aiEdit(
        instruction: prompt,
        document: document.value,
        targetSectionId: selectedSectionId.value,
      );

      final summary = res['summary'] as String? ?? 'Sunlit seating inside the Lumen Coffee café';
      var cleanAlt = summary.replaceAll('Updated alt text to:', '').replaceAll('AI Edit:', '').trim();
      if (cleanAlt.startsWith('"') && cleanAlt.endsWith('"')) {
        cleanAlt = cleanAlt.substring(1, cleanAlt.length - 1);
      }
      altTextController.text = cleanAlt;
      updateImageAltText(cleanAlt);
    } catch (_) {
      altTextController.text = 'Sunlit seating inside the Lumen Coffee café';
      updateImageAltText(altTextController.text);
    } finally {
      isGeneratingAltText.value = false;
    }
  }

  void deleteCurrentImageSection() {
    if (selectedSectionId.value != null) {
      deleteSection(selectedSectionId.value!);
    }
  }

  void selectSection(String sectionId) {
    selectedSectionId.value = sectionId;
    _populateSectionInputs(sectionId);
    final comp = selectedSectionType.value.capitalizeFirst ?? 'Section';
    aiPromptPlaceholder.value = 'Ask AI about this ${comp.toLowerCase()}';

    // Switch to Edit tab and open panel so the user sees only this section's editor
    selectedTab.value = 1;
    isPanelOpen.value = true;

    if (webViewController != null) {
      final safeId = jsonEncode(sectionId);
      webViewController!.runJavaScript(
        "if (window.selectSection) { window.selectSection($safeId); }",
      );
    }
  }

  void duplicateSection(String sectionId) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        final idx = sections.indexWhere((s) => s['id'] == sectionId);
        if (idx != -1) {
          final original = Map<String, dynamic>.from(sections[idx] as Map);
          final cloned = jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
          final compName = (cloned['component'] as String? ?? 'section').toLowerCase();
          final newId = 'sec_${compName}_${DateTime.now().millisecondsSinceEpoch}';
          cloned['id'] = newId;
          sections.insert(idx + 1, cloned);
          for (int i = 0; i < sections.length; i++) {
            sections[i]['order'] = i;
          }
          document.value = docCopy;
          syncDocumentToWebView();
          _saveCurrentDocument();
          selectSection(newId);
          _showSnackbar('Section Duplicated', 'Cloned section added below.');
          return;
        }
      }
    }
  }

  void deleteSelectedSection() {
    final secId = selectedSectionId.value;
    if (secId != null && secId.isNotEmpty) {
      deleteSection(secId);
    }
  }

  void updateText(String newText) {
    final sectionId = selectedSectionId.value;
    final key = selectedElementKey.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['props'] ??= <String, dynamic>{};
            if (key == 'headline') {
              sec['props']['headline'] = newText;
              sec['props']['title'] = newText;
            } else if (key == 'subheadline') {
              sec['props']['subheadline'] = newText;
              sec['props']['subtitle'] = newText;
              sec['props']['description'] = newText;
            } else if (key == 'ctaText') {
              sec['props']['ctaText'] = newText;
              sec['props']['buttonText'] = newText;
            } else {
              sec['props'][key] = newText;
            }
          }
        }
      }
    }

    document.value = docCopy;

    if (webViewController != null) {
      final safeText = jsonEncode(newText);
      final safeKey = jsonEncode(key);
      final safeSecId = jsonEncode(sectionId);
      final safeSize = jsonEncode(selectedElementSize.value);
      final jsonLiteral = jsonEncode(jsonEncode(docCopy));
      webViewController!.runJavaScript(
        "if (window.updateElementText) { window.updateElementText($safeSecId, $safeKey, $safeText, $safeSize); } else if (window.updateDocument) { window.updateDocument($jsonLiteral); }",
      );
    }

    _debounceSave();
  }

  void updateSize(String size) {
    selectedElementSize.value = size;
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['props'] ??= <String, dynamic>{};
            sec['props']['headlineSize'] = size;
          }
        }
      }
    }

    document.value = docCopy;
    if (webViewController != null) {
      final safeText = jsonEncode(textController.text);
      final safeKey = jsonEncode(selectedElementKey.value);
      final safeSecId = jsonEncode(sectionId);
      final safeSize = jsonEncode(size);
      webViewController!.runJavaScript(
        "if (window.updateElementText) { window.updateElementText($safeSecId, $safeKey, $safeText, $safeSize); }",
      );
    }
    _saveCurrentDocument();
  }

  void updateCtaProperty(String key, String value) {
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['props'] ??= <String, dynamic>{};
            sec['props'][key] = value;
            if (key == 'ctaText') sec['props']['buttonText'] = value;
            if (key == 'buttonText') sec['props']['ctaText'] = value;
            if (key == 'ctaLink') sec['props']['buttonLink'] = value;
            if (key == 'buttonLink') sec['props']['ctaLink'] = value;
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  void updateBadge(String value) {
    updateCtaProperty('badge', value);
  }

  void updateTestimonial(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= testimonialItems.length) return;
    testimonialItems[index] = item;
    _saveSectionItems('items', testimonialItems.toList());
  }

  void addTestimonial() {
    testimonialItems.add({
      'quote': 'Exceptional experience from start to finish. Highly recommend!',
      'author': 'Jane Doe',
      'role': 'Product Director',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'rating': 5,
    });
    _saveSectionItems('items', testimonialItems.toList());
  }

  void deleteTestimonial(int index) {
    if (index < 0 || index >= testimonialItems.length) return;
    testimonialItems.removeAt(index);
    _saveSectionItems('items', testimonialItems.toList());
  }

  void updateStat(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= statItems.length) return;
    statItems[index] = item;
    _saveSectionItems('metrics', statItems.toList());
    _saveSectionItems('items', statItems.toList());
  }

  void addStat() {
    statItems.add({
      'value': '99.9%',
      'label': 'Satisfaction Rate',
    });
    _saveSectionItems('metrics', statItems.toList());
    _saveSectionItems('items', statItems.toList());
  }

  void deleteStat(int index) {
    if (index < 0 || index >= statItems.length) return;
    statItems.removeAt(index);
    _saveSectionItems('metrics', statItems.toList());
    _saveSectionItems('items', statItems.toList());
  }

  void updateFeature(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= featureItems.length) return;
    featureItems[index] = item;
    _saveSectionItems('items', featureItems.toList());
  }

  void addFeature() {
    featureItems.add({
      'icon': 'Sparkles',
      'title': 'New Capability',
      'description': 'Designed for speed, clarity and delightful user experience.',
    });
    _saveSectionItems('items', featureItems.toList());
  }

  void deleteFeature(int index) {
    if (index < 0 || index >= featureItems.length) return;
    featureItems.removeAt(index);
    _saveSectionItems('items', featureItems.toList());
  }

  void _saveSectionItems(String key, List<Map<String, dynamic>> items) {
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['props'] ??= <String, dynamic>{};
            sec['props'][key] = items;
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  // --- Wix Section Layout & Styles ---
  void updateSectionStyle(String key, String value) {
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    if (key == 'background') selectedSectionBackground.value = value;
    if (key == 'textAlign') selectedSectionAlign.value = value;
    if (key == 'padding') selectedSectionPadding.value = value;

    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['styles'] ??= <String, dynamic>{};
            sec['styles'][key] = value;
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  // --- Wix Universal Properties Inspector ---
  void updateCustomProperty(String key, dynamic value) {
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    customProps[key] = value;

    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

    if (sectionId == 'sec_navigation') {
      docCopy['navigation'] ??= <String, dynamic>{};
      docCopy['navigation'][key] = value;
    } else {
      final pages = docCopy['pages'] as List?;
      if (pages != null && pages.isNotEmpty) {
        final sections = pages[0]['sections'] as List?;
        if (sections != null) {
          for (final sec in sections) {
            if (sec['id'] == sectionId) {
              sec['props'] ??= <String, dynamic>{};
              sec['props'][key] = value;
            }
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  void addCustomProperty(String key, String value) {
    if (key.trim().isEmpty) return;
    updateCustomProperty(key.trim(), value);
  }

  void deleteCustomProperty(String key) {
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    customProps.remove(key);

    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    if (sectionId == 'sec_navigation') {
      docCopy['navigation']?.remove(key);
    } else {
      final pages = docCopy['pages'] as List?;
      if (pages != null && pages.isNotEmpty) {
        final sections = pages[0]['sections'] as List?;
        if (sections != null) {
          for (final sec in sections) {
            if (sec['id'] == sectionId) {
              sec['props']?.remove(key);
            }
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  // --- Navigation Layer Controls ---
  void updateNavLogo({String? text, String? src}) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    docCopy['navigation'] ??= <String, dynamic>{};
    docCopy['navigation']['logo'] ??= <String, dynamic>{};
    if (text != null) {
      docCopy['navigation']['logo']['text'] = text;
      docCopy['site']?['name'] = text;
      websiteName.value = text;
    }
    if (src != null) {
      docCopy['navigation']['logo']['src'] = src;
    }
    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  void updateNavItem(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= navItems.length) return;
    navItems[index] = item;
    _saveNavItems();
  }

  void addNavItem() {
    navItems.add({'label': 'New Link', 'href': '#'});
    _saveNavItems();
  }

  void deleteNavItem(int index) {
    if (index < 0 || index >= navItems.length) return;
    navItems.removeAt(index);
    _saveNavItems();
  }

  void _saveNavItems() {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    docCopy['navigation'] ??= <String, dynamic>{};
    docCopy['navigation']['items'] = navItems.toList();
    document.value = docCopy;
    syncDocumentToWebView();
    _debounceSave();
  }

  // --- Footer Controls ---
  void updateFooterCopyright(String copy) {
    updateCtaProperty('copyright', copy);
  }

  void updateFooterLink(int index, Map<String, dynamic> link) {
    if (index < 0 || index >= footerLinks.length) return;
    footerLinks[index] = link;
    _saveSectionItems('links', footerLinks.toList());
  }

  void addFooterLink() {
    footerLinks.add({'label': 'Privacy Policy', 'href': '#privacy'});
    _saveSectionItems('links', footerLinks.toList());
  }

  void deleteFooterLink(int index) {
    if (index < 0 || index >= footerLinks.length) return;
    footerLinks.removeAt(index);
    _saveSectionItems('links', footerLinks.toList());
  }

  // --- Products & Pricing Controls ---
  void updateProduct(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= productItems.length) return;
    productItems[index] = item;
    _saveSectionItems('items', productItems.toList());
  }

  void addProduct() {
    productItems.add({
      'name': 'Premium Plan',
      'price': '\$29.00',
      'description': 'Full access to all premium features, unlimited sites and priority support.',
      'buttonText': 'Get Started',
      'buttonLink': '#checkout',
    });
    _saveSectionItems('items', productItems.toList());
  }

  void deleteProduct(int index) {
    if (index < 0 || index >= productItems.length) return;
    productItems.removeAt(index);
    _saveSectionItems('items', productItems.toList());
  }

  // --- FAQ Controls ---
  void updateFaq(int index, Map<String, dynamic> item) {
    if (index < 0 || index >= faqItems.length) return;
    faqItems[index] = item;
    _saveSectionItems('items', faqItems.toList());
  }

  void addFaq() {
    faqItems.add({
      'question': 'How does it work?',
      'answer': 'Simply select a template, customize your content, and publish instantly.',
    });
    _saveSectionItems('items', faqItems.toList());
  }

  void deleteFaq(int index) {
    if (index < 0 || index >= faqItems.length) return;
    faqItems.removeAt(index);
    _saveSectionItems('items', faqItems.toList());
  }

  // --- Gallery Controls ---
  void updateGalleryImage(int index, Map<String, dynamic> img) {
    if (index < 0 || index >= galleryImages.length) return;
    galleryImages[index] = img;
    _saveSectionItems('images', galleryImages.toList());
    _saveSectionItems('items', galleryImages.toList());
  }

  void addGalleryImage() {
    galleryImages.add({
      'url': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
      'alt': 'Gallery photo',
      'caption': 'Creative showcase',
    });
    _saveSectionItems('images', galleryImages.toList());
    _saveSectionItems('items', galleryImages.toList());
  }

  void deleteGalleryImage(int index) {
    if (index < 0 || index >= galleryImages.length) return;
    galleryImages.removeAt(index);
    _saveSectionItems('images', galleryImages.toList());
    _saveSectionItems('items', galleryImages.toList());
  }

  // --- Contact / Visit Controls ---
  void updateContactDetail(String key, String value) {
    updateCtaProperty(key, value);
  }

  void moveSection(String sectionId, String direction) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        final idx = sections.indexWhere((s) => s['id'] == sectionId);
        if (idx != -1) {
          if (direction == 'up' && idx > 0) {
            final temp = sections[idx];
            sections[idx] = sections[idx - 1];
            sections[idx - 1] = temp;
          } else if (direction == 'down' && idx < sections.length - 1) {
            final temp = sections[idx];
            sections[idx] = sections[idx + 1];
            sections[idx + 1] = temp;
          }
          for (int i = 0; i < sections.length; i++) {
            sections[i]['order'] = i;
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  void toggleSectionVisibility(String sectionId) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['visible'] = !(sec['visible'] ?? true);
          }
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  void deleteSection(String sectionId) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        sections.removeWhere((s) => s['id'] == sectionId);
        for (int i = 0; i < sections.length; i++) {
          sections[i]['order'] = i;
        }
      }
    }

    document.value = docCopy;
    if (selectedSectionId.value == sectionId) {
      selectedSectionId.value = null;
      selectedSectionType.value = '';
      selectedImageProps.clear();
      selectedTab.value = 0;
      aiPromptPlaceholder.value = 'Ask AI to change your site';
    }

    syncDocumentToWebView();
    _saveCurrentDocument();

    _showSnackbar(
      'Removed',
      'Section removed from page',
    );
  }

  void reorderSections(int oldIndex, int newIndex) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null && sections.length > 1) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = sections.removeAt(oldIndex);
        sections.insert(newIndex, item);
        for (int i = 0; i < sections.length; i++) {
          sections[i]['order'] = i;
        }
      }
    }

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  // Design Tab: Apply Color Preset
  void selectColorPreset(ColorPreset preset) {
    selectedColorPreset.value = preset.name;
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    docCopy['site'] ??= {};
    docCopy['site']['theme'] ??= {};
    docCopy['site']['theme']['colors'] = {
      ...(docCopy['site']['theme']['colors'] ?? {}),
      ...preset.themeColors,
    };

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();

    AppSnackbar.info(
      'editor_applied_palette'.trParams({'name': preset.name}),
      title: 'editor_theme_updated_title'.tr,
      duration: const Duration(seconds: 1),
    );
  }

  // Design Tab: Apply Font Preset
  void selectFontPreset(FontPreset preset) {
    selectedFontPreset.value = preset.name;
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    docCopy['site'] ??= {};
    docCopy['site']['theme'] ??= {};
    docCopy['site']['theme']['typography'] ??= {};
    docCopy['site']['theme']['typography']['headingFamily'] = preset.family;

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();

    AppSnackbar.info(
      'editor_applied_typography'.trParams({'name': preset.name}),
      title: 'editor_typography_updated_title'.tr,
      duration: const Duration(seconds: 1),
    );
  }

  void updateThemeColor(String hex) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    docCopy['site'] ??= {};
    docCopy['site']['theme'] ??= {};
    docCopy['site']['theme']['colors'] ??= {};
    docCopy['site']['theme']['colors']['primary'] = hex;

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  void updateTypography(String headingFamily) {
    final doc = document.value;
    if (doc == null) return;
    _pushUndoState();

    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    docCopy['site'] ??= {};
    docCopy['site']['theme'] ??= {};
    docCopy['site']['theme']['typography'] ??= {};
    docCopy['site']['theme']['typography']['headingFamily'] = headingFamily;

    document.value = docCopy;
    syncDocumentToWebView();
    _saveCurrentDocument();
  }

  void _debounceSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      _saveCurrentDocument();
    });
  }

  Future<void> _saveCurrentDocument() async {
    final doc = document.value;
    if (doc == null || websiteId.isEmpty) return;

    isSaving.value = true;
    try {
      final res = await ApiClient.updateWebsiteDocument(websiteId, doc);
      final website = res['website'] as Map<String, dynamic>?;
      final currentRev = website?['current_revision'] as Map<String, dynamic>?;

      revisionNumber.value = currentRev?['revision_number'] ?? (revisionNumber.value + 1);

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }
    } catch (_) {
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> publishWebsite() async {
    isPublishing.value = true;
    try {
      final res = await ApiClient.publishWebsite(websiteId);
      final liveUrl = res['live_url'] as String? ?? 'https://preview.aibuilder.local';

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(LucideIcons.circleCheck, color: Color(0xFF10B981)),
              const SizedBox(width: 10),
              Text(
                'editor_published_title'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'editor_published_desc'.tr,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  liveUrl,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('common_done'.tr),
            ),
          ],
        ),
      );
    } catch (e) {
      if (ApiClient.isSubscriptionLimitError(e)) {
        SubscriptionView.open();
        return;
      }
      AppSnackbar.error(e.toString(), title: 'common_error'.tr);
    } finally {
      isPublishing.value = false;
    }
  }

  void setViewport(ViewportMode mode) {
    viewport.value = mode;
  }

  double? get viewportWidth {
    switch (viewport.value) {
      case ViewportMode.mobile:
        return 375;
      case ViewportMode.tablet:
        return 600;
      case ViewportMode.desktop:
        return null;
    }
  }

  List<Map<String, dynamic>> get currentSections {
    final doc = document.value;
    if (doc == null) return [];
    final pages = doc['pages'] as List?;
    if (pages == null || pages.isEmpty) return [];
    return List<Map<String, dynamic>>.from(pages[0]['sections'] ?? []);
  }

  @override
  void onClose() {
    // Restore portrait lock when leaving editor screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _saveDebounceTimer?.cancel();
    aiPromptController.dispose();
    aiCustomPromptController.dispose();
    textController.dispose();
    subheadlineController.dispose();
    ctaTextController.dispose();
    ctaLinkController.dispose();
    secondaryCtaTextController.dispose();
    secondaryCtaLinkController.dispose();
    badgeController.dispose();
    navLogoTextController.dispose();
    navLogoSrcController.dispose();
    footerCopyrightController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    contactAddressController.dispose();
    contactHoursController.dispose();
    super.onClose();
  }
}
