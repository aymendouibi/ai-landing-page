import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/designsystem/colors.dart';
import '../../profile/components/subscription_plan_sheet.dart';
import '../services/template_html_compiler.dart';
import '../templates_controller.dart';

class TemplateRealPreviewModal extends StatefulWidget {
  final Map<String, dynamic> template;
  final TemplatesController controller;

  const TemplateRealPreviewModal({
    super.key,
    required this.template,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> template,
    required TemplatesController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TemplateRealPreviewModal(
        template: template,
        controller: controller,
      ),
    );
  }

  @override
  State<TemplateRealPreviewModal> createState() => _TemplateRealPreviewModalState();
}

class _TemplateRealPreviewModalState extends State<TemplateRealPreviewModal> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _isUsing = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final doc = _extractDocument(widget.template);
    final compiledHtml = TemplateHtmlCompiler.compileHtml(doc);

    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..loadHtmlString(compiledHtml);
    } catch (_) {
      // In headless unit test environments
      _isLoading = false;
    }
  }

  Map<String, dynamic> _extractDocument(Map<String, dynamic> template) {
    final activeVersion = template['active_version'] as Map<String, dynamic>?;
    if (activeVersion != null && activeVersion['document'] is Map) {
      return activeVersion['document'] as Map<String, dynamic>;
    }
    if (template['document'] is Map) {
      return template['document'] as Map<String, dynamic>;
    }

    // Fallback template builder if document missing
    final name = template['name'] ?? 'Website';
    final previewList = template['preview_images'] as List?;
    final heroImgObj = (template['document']?['pages']?[0]?['sections']?[0]?['props']?['image']) ??
        (template['active_version']?['document']?['pages']?[0]?['sections']?[0]?['props']?['image']);
    final heroImgSrc = heroImgObj is Map ? heroImgObj['src']?.toString() : heroImgObj?.toString();
    final img = (previewList != null && previewList.isNotEmpty && previewList.first.toString().isNotEmpty)
        ? previewList.first.toString()
        : (heroImgSrc != null && heroImgSrc.isNotEmpty)
            ? heroImgSrc
            : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80';

    return {
      'schema_version': 1,
      'site': {
        'name': name,
        'theme': {
          'colors': {
            'primary': template['primaryColor'] ?? '#0F172A',
            'background': template['bgColor'] ?? '#FFFFFF',
            'surface': '#F8FAFC',
          },
        },
      },
      'pages': [
        {
          'id': 'page_home',
          'slug': '/',
          'title': 'Home',
          'sections': [
            {
              'id': 'sec_hero',
              'component': 'hero',
              'props': {
                'headline': template['headline'] ?? name,
                'subheadline': template['description'] ?? '',
                'ctaText': template['ctaText'] ?? 'Explore',
                'image': {'src': img},
              },
            },
          ],
        },
      ],
    };
  }

  Future<void> _handleUseTemplate() async {
    setState(() => _isUsing = true);
    try {
      Navigator.of(context).pop();
      await widget.controller.useTemplate(widget.template);
    } finally {
      if (mounted) setState(() => _isUsing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final name = widget.template['name'] ?? 'Template';
    final industry = widget.template['industry'] ?? 'Design';
    final rawBadge = (widget.template['badge'] ?? 'CURATED').toString().trim();
    final cleanBadge = (rawBadge.startsWith('✦') ? rawBadge.substring(1).trim() : rawBadge).toUpperCase();

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Grab Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 2. Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '✦',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              cleanBadge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        industry,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Live Preview Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.circleDot, size: 10, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        'templates_live_preview'.tr,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 3. Real Interactive WebView Body
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  child: WebViewWidget(
                    controller: _webViewController,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Sticky Bottom Action Bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Builder(
                  builder: (ctx) {
                    final isLocked = widget.controller.isTemplateLocked(widget.template);
                    return ElevatedButton(
                      onPressed: _isUsing
                          ? null
                          : () {
                              if (isLocked) {
                                Navigator.of(context).pop();
                                SubscriptionPlanSheet.show(context);
                              } else {
                                _handleUseTemplate();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLocked
                            ? const Color(0xFF7C5CFF)
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: _isUsing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isLocked ? LucideIcons.lock : LucideIcons.sparkles,
                                  size: 17,
                                  color: isLocked
                                      ? Colors.white
                                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isLocked
                                        ? 'templates_unlock_premium'.tr
                                        : 'use_template'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isLocked
                                          ? Colors.white
                                          : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
