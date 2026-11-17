import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/services/project_export_service.dart';
import '../../../core/services/ad_service.dart';
import '../../dashboard/dashboard_controller.dart';
import '../../subscription/subscription_view.dart';

class CodeExportSheet extends StatefulWidget {
  const CodeExportSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const CodeExportSheet(),
    );
  }

  @override
  State<CodeExportSheet> createState() => _CodeExportSheetState();
}

class _CodeExportSheetState extends State<CodeExportSheet> {
  int _selectedFormat = 0; // 0: Static ZIP, 1: React/Tailwind, 2: Single HTML
  bool _isExporting = false;

  bool get _isPremium {
    if (Get.isRegistered<DashboardController>()) {
      return Get.find<DashboardController>().isPremium;
    }
    return false;
  }

  final _formats = [
    {
      'title': 'Static Production ZIP',
      'desc':
          'index.html, styles.css, script.js & assets folder in a ZIP archive',
      'badge': 'ZIP BUNDLE',
    },
    {
      'title': 'React + Tailwind JSX',
      'desc':
          'Full component package ready for Next.js or Vite in a ZIP archive',
      'badge': 'DEVELOPER',
    },
    {
      'title': 'Single-File Inline HTML',
      'desc':
          'Self-contained HTML with embedded styles bundled in a ZIP archive',
      'badge': 'EMBED',
    },
  ];

  Future<void> _handleDownloadZip() async {
    if (!_isPremium) {
      Navigator.pop(context);
      SubscriptionView.open();
      AppSnackbar.info(
        'Project export as a ZIP archive is a Premium feature. Upgrade to unlock.',
        title: 'Premium Required',
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final result = await ProjectExportService.instance.exportProjectZip(
        websiteId: '',
        websiteName: 'Landing Page',
        isPremium: true,
        customHtml: _getFormatTemplate(_selectedFormat),
      );

      if (mounted) {
        Navigator.pop(context);
        if (result.success) {
          AdService.instance.showInterstitialAd(adTag: 'export_project_zip');
          AppSnackbar.success(
            'Project exported successfully to ${result.fileName}',
            title: 'ZIP Export Complete',
          );
        } else {
          AppSnackbar.error(
            result.errorMessage ?? 'Failed to export project ZIP',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        AppSnackbar.error('Export failed: $e');
      }
    }
  }

  void _handleCopyCode() {
    Clipboard.setData(ClipboardData(text: _getFormatTemplate(_selectedFormat)));
    Navigator.pop(context);
    AdService.instance.showInterstitialAd(adTag: 'copy_export_code');
    AppSnackbar.copied(
      message: 'Snippet copied to clipboard. ZIP download requires Premium.',
      context: context,
    );
  }

  String _getFormatTemplate(int format) {
    switch (format) {
      case 1:
        return '''import React from 'react';

export default function ExportedLandingPage() {
  return (
    <div className="min-h-screen bg-white text-slate-900">
      <header className="py-6 px-8 flex justify-between items-center border-b">
        <h1 className="text-xl font-bold">Exported Website</h1>
      </header>
    </div>
  );
}''';
      case 2:
        return '<!DOCTYPE html><html><head><title>Export</title></head><body><h1>Exported Landing Page</h1></body></html>';
      case 0:
      default:
        return '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title>Exported Landing Page</title>\n  <script src="https://cdn.tailwindcss.com"></script>\n</head>\n<body class="bg-white text-slate-900">\n  <!-- AI Landing Page Export -->\n</body>\n</html>';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'export_title'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'export_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMutedOf(context),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text(
              'export_select_format'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.inkOf(context),
              ),
            ),
            const SizedBox(height: 10),

            // Format List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _formats.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _formats[index];
                  final isSelected = _selectedFormat == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedFormat = index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9))
                            : AppColors.surfaceMutedOf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.inkOf(context)
                              : AppColors.borderSubtleOf(context),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? LucideIcons.checkCircle2
                                : LucideIcons.circle,
                            size: 20,
                            color: isSelected
                                ? const Color(0xFF7C5CFF)
                                : AppColors.inkMutedOf(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item['title']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.inkOf(context),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF7C5CFF,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['badge']!,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF7C5CFF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['desc']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkMutedOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Premium Alert banner if Free tier
            if (!_isPremium)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.lock,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'export_premium_notice'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleCopyCode,
                    icon: const Icon(LucideIcons.copy, size: 16),
                    label: Text('export_copy_code'.tr),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: AppColors.borderSubtleOf(context),
                      ),
                      foregroundColor: AppColors.inkOf(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleDownloadZip,
                    icon: _isExporting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          )
                        : Icon(
                            _isPremium
                                ? LucideIcons.download
                                : LucideIcons.lock,
                            size: 16,
                          ),
                    label: Text(_isExporting ? 'Exporting...' : 'Download ZIP'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _isPremium
                          ? AppColors.inkOf(context)
                          : const Color(0xFFD97706),
                      foregroundColor: _isPremium
                          ? (isDark ? Colors.black : Colors.white)
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
