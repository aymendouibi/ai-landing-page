import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/models/website.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/project_export_service.dart';
import '../../core/storage/session_manager.dart';
import '../dashboard/dashboard_controller.dart';
import '../subscription/subscription_view.dart';

class WebsiteConfigController extends GetxController {
  final websiteId = ''.obs;
  final currentWebsite = Rxn<Website>();
  final websiteName = ''.obs;
  final subdomain = ''.obs;
  final status = 'draft'.obs;
  final liveUrl = ''.obs;
  final domains = <Map<String, dynamic>>[].obs;
  final dnsInstructions = Rxn<Map<String, dynamic>>();
  final deployments = <Map<String, dynamic>>[].obs;
  final allWebsites = <Website>[].obs;

  static final showcaseStudioMarlow = Website(
    id: 'showcase_studio_marlow',
    projectId: 'project_showcase',
    name: 'Studio Marlow',
    slug: 'studio-marlow',
    status: 'published',
    subdomain: 'studiomarlow',
    revisionNumber: 1,
  );

  static final showcaseKiteYoga = Website(
    id: 'showcase_kite_yoga',
    projectId: 'project_showcase',
    name: 'Kite Yoga',
    slug: 'kite-yoga',
    status: 'published',
    subdomain: 'kiteyoga',
    revisionNumber: 1,
  );

  final isLoading = true.obs;
  final isPublishing = false.obs;
  final isUnpublishing = false.obs;
  final isAttachingDomain = false.obs;
  final verifyingDomainIds = <String>{}.obs;
  final isSavingMetadata = false.obs;
  final isExportingZip = false.obs;
  final isImportingZip = false.obs;
  final isDeleting = false.obs;
  final forceHttps = true.obs;
  final importedZipName = 'portfolio.zip'.obs;
  final importedZipInfo = '2.4 MB · Imported 15 Nov 2026'.obs;
  final selectedExportFormat = 0.obs;

  final domainInputController = TextEditingController();
  final nameController = TextEditingController();
  final subdomainController = TextEditingController();
  final faviconController = TextEditingController();
  final logoController = TextEditingController();

  bool get isLive => status.value == 'published' || status.value == 'live';

  bool get isPremium {
    if (Get.isRegistered<DashboardController>()) {
      return Get.find<DashboardController>().isPremium;
    }
    return true; // Default to true if standalone or no DashboardController registered
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['websiteId'] != null) {
      websiteId.value = args['websiteId'] as String;
    } else if (Get.parameters['websiteId'] != null) {
      websiteId.value = Get.parameters['websiteId']!;
    }
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    dnsInstructions.value = null;

    try {
      final gathered = <Website>[];

      // 1. Gather all websites for switcher
      if (Get.isRegistered<DashboardController>()) {
        final dc = Get.find<DashboardController>();
        if (dc.websites.isNotEmpty) {
          gathered.addAll(dc.websites);
        }
      }
      if (gathered.isEmpty) {
        try {
          final fetched = await ApiClient.getWebsites();
          gathered.addAll(fetched);
        } catch (_) {}
      }

      // Filter out deleted website IDs
      final deletedIds = await SessionManager.getDeletedWebsiteIds();
      gathered.removeWhere(
        (w) =>
            deletedIds.contains(w.id) ||
            (w.slug.isNotEmpty && deletedIds.contains(w.slug)),
      );

      // 2. Include showcase websites if not deleted
      final allowMarlow =
          !deletedIds.contains('showcase_studio_marlow') &&
          !deletedIds.contains('studio-marlow');
      final allowKite =
          !deletedIds.contains('showcase_kite_yoga') &&
          !deletedIds.contains('kite-yoga');

      if (allowMarlow &&
          (websiteId.value == 'showcase_studio_marlow' || gathered.isEmpty)) {
        gathered.add(showcaseStudioMarlow);
      }
      if (allowKite &&
          (websiteId.value == 'showcase_kite_yoga' || gathered.isEmpty)) {
        gathered.add(showcaseKiteYoga);
      }

      // 3. Deduplicate by ID
      final seen = <String>{};
      final uniqueList = <Website>[];
      for (final site in gathered) {
        if (seen.add(site.id)) {
          uniqueList.add(site);
        }
      }
      allWebsites.assignAll(uniqueList);

      // If no websiteId specified, use first available
      if (websiteId.isEmpty && allWebsites.isNotEmpty) {
        websiteId.value = allWebsites.first.id;
      }

      // If websiteId specified but not in allWebsites, insert fallback
      if (websiteId.isNotEmpty &&
          !allWebsites.any((w) => w.id == websiteId.value)) {
        if (websiteId.value == 'showcase_studio_marlow') {
          allWebsites.insert(0, showcaseStudioMarlow);
        } else if (websiteId.value == 'showcase_kite_yoga') {
          allWebsites.insert(0, showcaseKiteYoga);
        } else {
          final fallbackSite = Website(
            id: websiteId.value,
            projectId: 'project_custom',
            name: websiteName.value.isNotEmpty
                ? websiteName.value
                : 'Custom Website',
            slug: 'custom-website',
            status: 'draft',
            revisionNumber: 1,
          );
          allWebsites.insert(0, fallbackSite);
        }
      }

      if (websiteId.isNotEmpty) {
        // Find matching website
        final site = allWebsites.firstWhereOrNull(
          (w) => w.id == websiteId.value,
        );
        if (site != null) {
          _applyWebsite(site);
        }

        // Mock domains and deployments for showcase websites
        if (websiteId.value == 'showcase_studio_marlow') {
          domains.assignAll([
            {
              'id': 'dom_marlow',
              'domain': 'studiomarlow.com',
              'status': 'active',
              'ssl_status': 'active',
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String(),
            },
          ]);
        } else if (websiteId.value == 'showcase_kite_yoga') {
          domains.assignAll([
            {
              'id': 'dom_kite',
              'domain': 'kiteyoga.com',
              'status': 'active',
              'ssl_status': 'active',
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 20))
                  .toIso8601String(),
            },
          ]);
        } else {
          // Fetch deep details for real websites
          try {
            final details = await ApiClient.getWebsiteDetails(websiteId.value);
            final rawSite = details['website'];
            if (rawSite is Map<String, dynamic>) {
              final refreshedSite = Website.fromJson(rawSite);
              _applyWebsite(refreshedSite);

              // If domains included
              if (rawSite['domains'] is List) {
                domains.assignAll(
                  (rawSite['domains'] as List).cast<Map<String, dynamic>>(),
                );
              }
            }
          } catch (_) {}

          // Fetch domains specifically if not populated
          if (domains.isEmpty) {
            await loadDomains();
          }

          // Fetch deployments
          try {
            final depList = await ApiClient.getDeployments(websiteId.value);
            deployments.assignAll(depList);
          } catch (_) {}
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applyWebsite(Website site) {
    currentWebsite.value = site;
    websiteName.value = site.name;
    nameController.text = site.name;
    subdomain.value = site.subdomain ?? site.slug;
    subdomainController.text = site.subdomain ?? site.slug;
    status.value = site.status;
    final sub = site.subdomain ?? site.slug;
    liveUrl.value = 'https://www.ai-landing-page.xyz/sites/$sub';
    final doc = site.document;
    final siteMap = doc?['site'] as Map<String, dynamic>?;
    final navMap = doc?['navigation'] as Map<String, dynamic>?;
    faviconController.text = siteMap?['favicon']?.toString() ?? '';
    logoController.text = navMap?['logo']?['src']?.toString() ?? '';
    final baseSlug = site.slug.isNotEmpty
        ? site.slug
        : (site.subdomain ?? 'portfolio');
    importedZipName.value = '$baseSlug.zip';
  }

  void selectWebsite(String id) {
    if (id == websiteId.value) return;
    websiteId.value = id;
    domains.clear();
    dnsInstructions.value = null;
    loadData();
  }

  Future<void> loadDomains() async {
    if (websiteId.isEmpty) return;
    try {
      final res = await ApiClient.getDomains(websiteId.value);
      final rawDomains = res['domains'] as List? ?? [];
      domains.assignAll(
        rawDomains.map((d) => d as Map<String, dynamic>).toList(),
      );
    } catch (_) {}
  }

  Future<bool> publishSite() async {
    if (websiteId.isEmpty) return false;
    isPublishing.value = true;
    try {
      final res = await ApiClient.publishWebsite(websiteId.value);
      status.value = 'published';
      if (res['live_url'] != null) {
        liveUrl.value = res['live_url'] as String;
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }
      return true;
    } catch (e) {
      if (ApiClient.isSubscriptionLimitError(e)) {
        SubscriptionView.open();
        return false;
      }
      AppSnackbar.error(
        e.toString().replaceFirst('Exception: ', ''),
        title: 'Publishing Failed',
      );
      return false;
    } finally {
      isPublishing.value = false;
    }
  }

  Future<bool> unpublishSite() async {
    if (websiteId.isEmpty) return false;
    isUnpublishing.value = true;
    try {
      await ApiClient.unpublishWebsite(websiteId.value);
      status.value = 'draft';
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }
      return true;
    } catch (e) {
      AppSnackbar.error(
        e.toString().replaceFirst('Exception: ', ''),
        title: 'Error',
      );
      return false;
    } finally {
      isUnpublishing.value = false;
    }
  }

  Future<bool> attachDomain(String domain) async {
    final clean = domain.trim().toLowerCase();
    if (clean.isEmpty || !clean.contains('.') || websiteId.isEmpty) {
      return false;
    }

    isAttachingDomain.value = true;
    dnsInstructions.value = null;

    try {
      final res = await ApiClient.attachDomain(websiteId.value, clean);
      domainInputController.clear();
      dnsInstructions.value = res['dns_instructions'] as Map<String, dynamic>?;
      await loadDomains();
      return true;
    } catch (e) {
      if (ApiClient.isSubscriptionLimitError(e)) {
        SubscriptionView.open();
        return false;
      }
      AppSnackbar.error(
        e.toString().replaceFirst('Exception: ', ''),
        title: 'Domain Error',
      );
      return false;
    } finally {
      isAttachingDomain.value = false;
    }
  }

  Future<bool> verifyDomain(String domainId) async {
    if (websiteId.isEmpty || domainId.isEmpty) return false;
    verifyingDomainIds.add(domainId);

    try {
      final res = await ApiClient.verifyDomain(websiteId.value, domainId);
      final verified = res['verified'] == true;
      await loadDomains();
      return verified;
    } catch (e) {
      AppSnackbar.error(
        e.toString().replaceFirst('Exception: ', ''),
        title: 'Verification Error',
      );
      return false;
    } finally {
      verifyingDomainIds.remove(domainId);
    }
  }

  Future<bool> deleteDomain(String domainId) async {
    if (websiteId.isEmpty || domainId.isEmpty) return false;
    try {
      final ok = await ApiClient.deleteDomain(websiteId.value, domainId);
      if (ok) {
        domains.removeWhere((d) => d['id']?.toString() == domainId);
      }
      return ok;
    } catch (e) {
      AppSnackbar.error('Failed to disconnect domain: $e', title: 'Error');
      return false;
    }
  }

  Future<bool> saveMetadata({String? name, String? newSubdomain}) async {
    if (websiteId.isEmpty) return false;
    isSavingMetadata.value = true;

    final targetName =
        name ??
        (nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : websiteName.value);
    final targetSub =
        newSubdomain ??
        (subdomainController.text.trim().isNotEmpty
            ? subdomainController.text.trim()
            : subdomain.value);

    try {
      final res = await ApiClient.updateWebsiteMetadata(
        websiteId.value,
        name: targetName,
        subdomain: targetSub,
      );
      final updatedSite = res['website'] as Map<String, dynamic>?;
      if (updatedSite != null) {
        if (updatedSite['id'] != null) {
          websiteId.value = updatedSite['id'].toString();
          currentWebsite.value = Website.fromJson(updatedSite);
        }
        websiteName.value = updatedSite['name']?.toString() ?? targetName;
        subdomain.value = updatedSite['subdomain']?.toString() ?? targetSub;
        liveUrl.value = 'https://www.ai-landing-page.xyz/sites/${subdomain.value}';
      }

      // Persist Favicon & Brand Logo updates in document
      final curDoc = currentWebsite.value?.document;
      if (curDoc != null) {
        final docCopy = jsonDecode(jsonEncode(curDoc)) as Map<String, dynamic>;
        bool docChanged = false;
        docCopy['site'] ??= <String, dynamic>{};
        final newFav = faviconController.text.trim();
        if (newFav != (docCopy['site']['favicon']?.toString() ?? '')) {
          docCopy['site']['favicon'] = newFav.isNotEmpty ? newFav : null;
          docChanged = true;
        }
        docCopy['navigation'] ??= <String, dynamic>{};
        docCopy['navigation']['logo'] ??= <String, dynamic>{};
        final newLogo = logoController.text.trim();
        if (newLogo != (docCopy['navigation']['logo']['src']?.toString() ?? '')) {
          docCopy['navigation']['logo']['src'] = newLogo.isNotEmpty ? newLogo : null;
          docChanged = true;
        }
        if (docChanged) {
          try {
            await ApiClient.updateWebsiteDocument(websiteId.value, docCopy);
          } catch (_) {}
        }
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }
      AppSnackbar.success(
        'site_settings_saved_success'.tr,
        title: 'site_settings_saved_title'.tr,
      );
      return true;
    } catch (e) {
      String message = e.toString().replaceFirst('Exception: ', '');
      if (message.contains('No query results for model') ||
          message.contains('ModelNotFoundException')) {
        message = 'Website could not be found or has not been initialized.';
      }
      AppSnackbar.error(
        message,
        title: 'common_error'.tr,
      );
      return false;
    } finally {
      isSavingMetadata.value = false;
    }
  }

  Future<void> chooseZipFile() async {
    isImportingZip.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final clean = websiteName.value.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '-',
      );
      importedZipName.value = '${clean.isEmpty ? "portfolio" : clean}.zip';
      importedZipInfo.value = '2.4 MB · Imported just now';
      AppSnackbar.success(
        'site_settings_zip_imported'.trParams({'name': importedZipName.value}),
        title: 'site_settings_zip_imported_title'.tr,
      );
    } finally {
      isImportingZip.value = false;
    }
  }

  Future<bool> deleteWebsite() async {
    if (websiteId.isEmpty) return false;
    isDeleting.value = true;
    try {
      final targetId = websiteId.value;
      final targetSlug = currentWebsite.value?.slug;

      // 1. Delete on backend (resolves by UUID, slug, or showcase ID, and treats 404 gracefully)
      await ApiClient.deleteWebsite(targetId);

      // 2. Persist deleted ID locally so showcase cards never reappear on dashboard
      await SessionManager.markWebsiteDeleted(targetId);
      if (targetSlug != null && targetSlug.isNotEmpty) {
        await SessionManager.markWebsiteDeleted(targetSlug);
      }

      // 3. Update DashboardController if registered
      if (Get.isRegistered<DashboardController>()) {
        final dc = Get.find<DashboardController>();
        dc.deletedWebsiteIds.add(targetId);
        if (targetSlug != null && targetSlug.isNotEmpty) {
          dc.deletedWebsiteIds.add(targetSlug);
        }
        dc.websites.removeWhere(
          (w) =>
              w.id == targetId ||
              w.slug == targetId ||
              (targetSlug != null &&
                  (w.id == targetSlug || w.slug == targetSlug)),
        );
        dc.loadData();
      }

      // 4. Update current controller website list
      allWebsites.removeWhere(
        (w) =>
            w.id == targetId ||
            w.slug == targetId ||
            (targetSlug != null &&
                (w.id == targetSlug || w.slug == targetSlug)),
      );

      // 5. Navigate safely back to Dashboard or previous view
      if (Get.previousRoute == AppRoutes.editor || Get.previousRoute.isEmpty) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.back();
      }

      AppSnackbar.success('site_settings_delete_success'.tr);
      return true;
    } catch (e) {
      AppSnackbar.error(
        e.toString().replaceFirst('Exception: ', ''),
        title: 'common_error'.tr,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  String getExportCode() {
    final title = websiteName.value.isNotEmpty
        ? websiteName.value
        : 'Landing Page';
    final siteDoc = currentWebsite.value?.document;

    switch (selectedExportFormat.value) {
      case 0:
        // Static Production ZIP / HTML
        return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <link rel="stylesheet" href="assets/style.css">
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white text-slate-900 antialiased font-sans">
  <main id="app">
    <!-- Generated by AI Landing Page Builder -->
    <header class="py-6 px-8 flex justify-between items-center border-b border-slate-100">
      <h1 class="text-xl font-bold tracking-tight">$title</h1>
      <nav class="space-x-6 text-sm font-medium text-slate-600">
        <a href="#features" class="hover:text-black">Features</a>
        <a href="#contact" class="hover:text-black">Contact</a>
      </nav>
    </header>
  </main>
  <script src="assets/main.js"></script>
</body>
</html>''';

      case 1:
        // React + Tailwind JSX
        return '''import React from 'react';

export default function ${title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}Page() {
  return (
    <div className="min-h-screen bg-white text-slate-900 selection:bg-indigo-500 selection:text-white">
      <header className="max-w-6xl mx-auto px-6 py-6 flex justify-between items-center">
        <span className="text-xl font-extrabold tracking-tight">$title</span>
        <button className="bg-slate-900 text-white text-sm font-semibold px-4 py-2 rounded-full hover:bg-slate-800 transition">
          Get Started
        </button>
      </header>
    </div>
  );
}''';

      case 2:
        // Single-File Inline HTML
        return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>$title</title>
  <style>
    body { margin:0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background:#fff; color:#0f172a; }
    .hero { padding: 80px 24px; text-align: center; }
  </style>
</head>
<body>
  <div class="hero">
    <h1>$title</h1>
  </div>
</body>
</html>''';

      case 3:
      default:
        // JSON Document
        return siteDoc != null
            ? const JsonEncoder.withIndent('  ').convert(siteDoc)
            : '{\n  "name": "$title",\n  "schema_version": 1\n}';
    }
  }

  void copyExportCode() {
    Clipboard.setData(ClipboardData(text: getExportCode()));
    AppSnackbar.copied(message: 'site_settings_code_copied'.tr);
  }

  Future<void> exportProjectZip() async {
    if (!isPremium) {
      SubscriptionView.open();
      AppSnackbar.info(
        'site_settings_premium_req_desc'.tr,
        title: 'sub_premium'.tr,
      );
      return;
    }

    isExportingZip.value = true;
    try {
      final result = await ProjectExportService.instance.exportProjectZip(
        websiteId: websiteId.value,
        websiteName: websiteName.value.isNotEmpty
            ? websiteName.value
            : 'Website',
        isPremium: isPremium,
        document: currentWebsite.value?.document,
        customHtml: getExportCode(),
      );

      if (result.success) {
        AppSnackbar.success(
          'site_settings_export_zip_saved'.trParams({
            'name': result.fileName ?? 'archive.zip',
          }),
          title: 'site_settings_export_zip_complete'.tr,
        );
      } else if (result.isPremiumRequired) {
        SubscriptionView.open();
        AppSnackbar.info(
          result.errorMessage ?? 'site_settings_premium_req_desc'.tr,
          title: 'sub_premium'.tr,
        );
      } else {
        AppSnackbar.error(
          result.errorMessage ?? 'Failed to export project.',
          title: 'common_error'.tr,
        );
      }
    } catch (e) {
      AppSnackbar.error('Export failed: $e', title: 'common_error'.tr);
    } finally {
      isExportingZip.value = false;
    }
  }

  @override
  void onClose() {
    domainInputController.dispose();
    nameController.dispose();
    subdomainController.dispose();
    faviconController.dispose();
    logoController.dispose();
    super.onClose();
  }
}
