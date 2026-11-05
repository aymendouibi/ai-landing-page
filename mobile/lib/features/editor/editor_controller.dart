import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/designsystem/colors.dart';
import '../../core/network/api_client.dart';
import '../dashboard/dashboard_controller.dart';

enum ViewportMode { mobile, tablet, desktop }

class EditorController extends GetxController {
  late final String websiteId;
  WebViewController? webViewController;

  final websiteName = 'Website Editor'.obs;
  final revisionNumber = 1.obs;
  final isSaving = false.obs;
  final isPublishing = false.obs;
  final isLoading = true.obs;
  final viewport = ViewportMode.mobile.obs;
  final selectedSectionId = RxnString();
  final document = Rxn<Map<String, dynamic>>();

  final headlineController = TextEditingController();
  final subheadlineController = TextEditingController();

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
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..addJavaScriptChannel(
        'AndroidBridge',
        onMessageReceived: (message) {
          try {
            final data = jsonDecode(message.message);
            final action = data['action'] ?? data['type'];
            if (action == 'EDITOR_READY' || action == 'RENDERER_READY') {
              syncDocumentToWebView();
            } else if (action == 'SELECT_SECTION' || action == 'SECTION_SELECTED') {
              final payload = data['payload'] as Map<String, dynamic>?;
              final sectionId = (payload?['sectionId'] ?? data['sectionId']) as String?;
              onSectionSelected(sectionId);
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
      ..loadRequest(Uri.parse('http://10.0.2.2:3000/'));
  }

  Future<void> loadWebsite() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.getWebsiteDetails(websiteId);
      final website = res['website'] as Map<String, dynamic>;
      final currentRev = website['current_revision'] as Map<String, dynamic>?;

      websiteName.value = website['name'] ?? 'Website Editor';
      revisionNumber.value = currentRev?['revision_number'] ?? (website['revision_number'] ?? 1);
      final rawDoc = (currentRev?['document'] as Map<String, dynamic>?) ??
          (website['document'] as Map<String, dynamic>?);
      document.value = rawDoc;

      syncDocumentToWebView();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load website: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
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

  void onSectionSelected(String? sectionId) {
    if (sectionId == null) return;
    selectedSectionId.value = sectionId;
    _populateSectionInputs(sectionId);
    showSectionEditorSheet();
  }

  void _populateSectionInputs(String sectionId) {
    if (document.value == null) return;
    final pages = document.value!['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            final props = sec['props'] as Map<String, dynamic>?;
            headlineController.text = props?['headline'] ?? '';
            subheadlineController.text = props?['subheadline'] ?? '';
            return;
          }
        }
      }
    }
  }

  void showSectionEditorSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editing Section',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  selectedSectionId.value ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.atmosphereViolet,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: headlineController,
              decoration: InputDecoration(
                labelText: 'Headline / Title',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subheadlineController,
              decoration: InputDecoration(
                labelText: 'Subheadline / Description',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.ink)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      saveSectionUpdates();
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Apply & Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> saveSectionUpdates() async {
    final sectionId = selectedSectionId.value;
    final doc = document.value;
    if (sectionId == null || doc == null) return;

    isSaving.value = true;

    // Deep copy document and apply mutations
    final docCopy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    final pages = docCopy['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final sections = pages[0]['sections'] as List?;
      if (sections != null) {
        for (final sec in sections) {
          if (sec['id'] == sectionId) {
            sec['props'] ??= <String, dynamic>{};
            if (headlineController.text.isNotEmpty) {
              sec['props']['headline'] = headlineController.text;
            }
            if (subheadlineController.text.isNotEmpty) {
              sec['props']['subheadline'] = subheadlineController.text;
            }
          }
        }
      }
    }

    try {
      final res = await ApiClient.updateWebsiteDocument(websiteId, docCopy);
      final website = res['website'] as Map<String, dynamic>?;
      final currentRev = website?['current_revision'] as Map<String, dynamic>?;

      document.value = docCopy;
      revisionNumber.value = currentRev?['revision_number'] ?? (revisionNumber.value + 1);
      selectedSectionId.value = null;

      syncDocumentToWebView();

      // Refresh dashboard if active
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      Get.snackbar(
        'Saved',
        'Revision #${revisionNumber.value} persisted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      );
    } catch (e) {
      Get.snackbar('Save Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> publishWebsite() async {
    isPublishing.value = true;
    try {
      final res = await ApiClient.publishWebsite(websiteId);
      final liveUrl = res['live_url'] as String? ?? 'https://preview.aibuilder.local';

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      Get.dialog(
        AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.green),
              SizedBox(width: 10),
              Text('Website Published!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your website is now live and deployed on CDN hosting.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  liveUrl,
                  style: const TextStyle(
                    color: AppColors.atmosphereViolet,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Awesome', style: TextStyle(color: Colors.white)),
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

  @override
  void onClose() {
    headlineController.dispose();
    subheadlineController.dispose();
    super.onClose();
  }
}

