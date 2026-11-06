import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/network/api_client.dart';
import '../dashboard/dashboard_controller.dart';

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
  late final String websiteId;
  WebViewController? webViewController;

  final websiteName = 'Untitled site'.obs;
  final revisionNumber = 1.obs;
  final isSaving = false.obs;
  final isPublishing = false.obs;
  final isLoading = true.obs;
  final viewport = ViewportMode.mobile.obs;

  // Bottom panel state: 0 = Add, 1 = Edit, 2 = Layers, 3 = Design
  final selectedTab = 0.obs;
  final isPanelOpen = false.obs;

  // Selected Presets in Design Tab
  final selectedColorPreset = 'Crema'.obs;
  final selectedFontPreset = 'Serif'.obs;

  // AI prompt state
  final aiPromptPlaceholder = 'Ask AI to change your site'.obs;
  final aiPromptController = TextEditingController();
  final isAiEditing = false.obs;

  // Selected element / section details
  final selectedSectionId = RxnString();
  final selectedElementContext = 'Heading in Hero'.obs;
  final selectedElementKey = 'headline'.obs;
  final selectedElementSize = 'Large'.obs; // 'Small', 'Medium', 'Large'

  final textController = TextEditingController();
  final subheadlineController = TextEditingController();

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
    _initWebView();
    if (websiteId.isNotEmpty) {
      loadWebsite();
    }
  }

  void _initWebView() {
    // 127.0.0.1 on iOS simulator connects directly to Mac host! 10.0.2.2 on Android emulator.
    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

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
      ..loadRequest(Uri.parse('http://$host:3000/'));
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
      Get.snackbar('Error', 'Failed to load website: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _autoSelectInitialElement() {
    final doc = document.value;
    if (doc == null) return;
    final pages = doc['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null && sections.isNotEmpty) {
        final firstSec = sections[0] as Map<String, dynamic>;
        final secId = firstSec['id'] as String?;
        final comp = (firstSec['component'] as String? ?? 'hero').capitalizeFirst ?? 'Hero';
        final props = firstSec['props'] as Map<String, dynamic>? ?? {};

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
        "if (window.updateDocument) { window.updateDocument($jsonLiteral); }",
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
  }

  void _populateSectionInputs(String sectionId) {
    if (document.value == null) return;
    final pages = document.value!['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            final comp = (sec['component'] as String? ?? 'hero').capitalizeFirst ?? 'Section';
            final props = sec['props'] as Map<String, dynamic>? ?? {};
            selectedElementContext.value = 'Heading in $comp';
            selectedElementKey.value = 'headline';
            textController.text = props['headline'] ?? props['title'] ?? '';
            subheadlineController.text = props['subheadline'] ?? props['subtitle'] ?? props['description'] ?? '';
            selectedElementSize.value = props['headlineSize'] ?? 'Large';
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

  Future<void> submitAiPrompt() async {
    final text = aiPromptController.text.trim();
    if (text.isEmpty || websiteId.isEmpty) return;

    isAiEditing.value = true;
    try {
      final res = await ApiClient.aiEdit(
        websiteId: websiteId,
        instruction: text,
        targetSectionId: selectedSectionId.value,
      );
      final website = res['website'] as Map<String, dynamic>?;
      final newDoc = website?['document'] as Map<String, dynamic>?;
      if (newDoc != null) {
        document.value = newDoc;
        syncDocumentToWebView();
      }
      aiPromptController.clear();
      Get.snackbar(
        'AI Edit Complete',
        res['summary'] ?? 'Updated website with your AI instruction.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
      );
    } catch (e) {
      Get.snackbar('AI Edit Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAiEditing.value = false;
    }
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

    Get.snackbar(
      'Section Added',
      'Added $compCapitalized section to page',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.white.withValues(alpha: 0.95),
    );
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
      webViewController!.runJavaScript(
        "if (window.updateElementText) { window.updateElementText($safeSecId, $safeKey, $safeText, $safeSize); }",
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
    syncDocumentToWebView();
    _saveCurrentDocument();
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
      aiPromptPlaceholder.value = 'Ask AI to change your site';
    }

    syncDocumentToWebView();
    _saveCurrentDocument();

    Get.snackbar(
      'Removed',
      'Section removed from page',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
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

    Get.snackbar(
      'Theme Updated',
      'Applied ${preset.name} color palette',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.white.withValues(alpha: 0.95),
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

    Get.snackbar(
      'Typography Updated',
      'Applied ${preset.name} font style',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.white.withValues(alpha: 0.95),
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
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981)),
              SizedBox(width: 10),
              Text(
                'Published!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your website is live and deployed on global CDN hosting.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
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
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Publish Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
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
    _saveDebounceTimer?.cancel();
    aiPromptController.dispose();
    textController.dispose();
    subheadlineController.dispose();
    super.onClose();
  }
}
