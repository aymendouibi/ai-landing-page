import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import 'editor_controller.dart';

class AskAiReviewSheet extends StatelessWidget {
  final EditorController controller;

  const AskAiReviewSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0x26000000),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row: Glowing AI Orb + "Ask AI" + Close (X)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Glowing sphere icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.3, -0.3),
                          radius: 0.8,
                          colors: [
                            Color(0xFF38BDF8),
                            Color(0xFF818CF8),
                            Color(0xFFC084FC),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF818CF8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'editor_ask_ai'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Close button
                    GestureDetector(
                      onTap: () {
                        if (controller.aiReviewStep.value == 'review') {
                          controller.discardAiProposal();
                        } else {
                          Get.back();
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.x,
                          size: 16,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scope Capsule: [ No selection | Entire website ]
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Obx(
                  () => Container(
                    height: 40,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.aiReviewScope.value = 'No selection',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: controller.aiReviewScope.value == 'No selection'
                                    ? (isDark ? const Color(0xFF334155) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: controller.aiReviewScope.value == 'No selection'
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'editor_ai_no_selection'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: controller.aiReviewScope.value == 'No selection'
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: controller.aiReviewScope.value == 'No selection'
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.aiReviewScope.value = 'Entire website',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: controller.aiReviewScope.value == 'Entire website'
                                    ? (isDark ? const Color(0xFF334155) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: controller.aiReviewScope.value == 'Entire website'
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'editor_ai_entire_website'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: controller.aiReviewScope.value == 'Entire website'
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: controller.aiReviewScope.value == 'Entire website'
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Body: Switches between Prompt state (Image 3) and Review state (Image 4)
              Obx(() {
                if (controller.aiReviewStep.value == 'prompt') {
                  return _buildPromptStep(context);
                } else {
                  return _buildReviewStep(context);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- STEP 1: Prompt Input & Suggestions (Image 3) ---
  Widget _buildPromptStep(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final suggestions = [
      'A neighborhood bakery with a menu and opening hours',
      'A portfolio for a ceramic artist',
      'A one-page site for a pop-up dinner',
      'Switch palette to Espresso dark mode',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'editor_ai_describe_site'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Purple tinted outline input field container
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC084FC).withValues(alpha: isDark ? 0.8 : 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.16 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: controller.aiCustomPromptController,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'editor_ai_prompt_hint'.tr,
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'editor_ai_suggestions'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Suggestions List
          Column(
            children: suggestions.map((s) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      controller.aiCustomPromptController.text = s;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.arrowUpRight,
                            size: 17,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Draft my site CTA Button
          Obx(
            () => GestureDetector(
              onTap: controller.isAiEditing.value
                  ? null
                  : () {
                      final text = controller.aiCustomPromptController.text.trim();
                      controller.submitAiPrompt(text.isEmpty ? 'Switch palette to Espresso dark mode' : text);
                    },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: controller.isAiEditing.value
                      ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: controller.isAiEditing.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      )
                    : Text(
                        'editor_ai_draft_button'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: Before & After Review (Image 4) ---
  Widget _buildReviewStep(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "Preview" header + [ Before | After ] Capsule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'editor_ai_preview'.tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Obx(
                () => Container(
                  height: 32,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPillToggleItem(
                        label: 'Before',
                        isSelected: controller.aiReviewMode.value == 'Before',
                        onTap: () => controller.toggleAiReviewMode('Before'),
                        isDark: isDark,
                      ),
                      _buildPillToggleItem(
                        label: 'After',
                        isSelected: controller.aiReviewMode.value == 'After',
                        onTap: () => controller.toggleAiReviewMode('After'),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Visual Preview Card (replicating the Lumen Coffee dark/light card in Image 4)
          Obx(() => _buildVisualPreviewCard()),

          const SizedBox(height: 16),

          // Changes Section
          Text(
            'editor_ai_changes'.tr,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          Obx(() {
            final diffs = controller.aiChangeDiffs;
            if (diffs.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: diffs.map((diff) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diff['type'] ?? 'Change',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: diff['old'] ?? '',
                              style: TextStyle(
                                fontSize: 13.5,
                                decoration: TextDecoration.lineThrough,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: ' → ',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: diff['new'] ?? '',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 8),

          // "Try another version" action link
          InkWell(
            onTap: controller.tryAnotherAiVersion,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.rotateCw,
                    size: 15,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'editor_ai_try_another'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Action Buttons: [ Discard ] and [ Apply change ]
          Row(
            children: [
              // Discard Button (reverts to old version)
              Expanded(
                child: GestureDetector(
                  onTap: controller.discardAiProposal,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'editor_ai_discard'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Apply change Button (keeps new version)
              Expanded(
                child: GestureDetector(
                  onTap: controller.applyAiProposal,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'editor_ai_apply_change'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillToggleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? const Color(0xFF64748B) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  // Preview card reflecting the website in Before (light) or After (dark) mode
  Widget _buildVisualPreviewCard() {
    final isAfter = controller.aiReviewMode.value == 'After';
    final targetDoc = isAfter
        ? (controller.stashedAiProposedDoc.value ?? controller.document.value)
        : (controller.stashedOriginalDoc.value ?? controller.document.value);

    // Check if palette diff is present to accurately render Before vs After
    String paletteName = controller.getPaletteNameForDoc(targetDoc);
    for (final diff in controller.aiChangeDiffs) {
      if (diff['type'] == 'Palette') {
        paletteName = isAfter ? (diff['new'] ?? paletteName) : (diff['old'] ?? paletteName);
        break;
      }
    }

    // Helper to parse hex colors
    Color hexToColor(String? hex, Color fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
      return fallback;
    }

    final site = targetDoc?['site'] as Map?;
    final theme = site?['theme'] as Map?;
    final themeColors = (theme?['colors'] as Map?) ?? {};
    final textColors = (themeColors['text'] as Map?) ?? {};

    // Match preset if possible
    ColorPreset? matchedPreset;
    for (final p in controller.colorPresets) {
      if (p.name.toLowerCase() == paletteName.toLowerCase()) {
        matchedPreset = p;
        break;
      }
    }

    Color bgColor;
    Color textColor;
    Color subtextColor;
    Color accentColor;

    if (matchedPreset != null) {
      bgColor = matchedPreset.bg;
      textColor = matchedPreset.aaColor;
      subtextColor = hexToColor(
        matchedPreset.themeColors['secondary'] as String?,
        const Color(0xFF78716C),
      );
      accentColor = hexToColor(
        matchedPreset.themeColors['accent'] as String?,
        matchedPreset.dot1,
      );
    } else {
      final isDark = paletteName == 'Espresso' || paletteName == 'Charcoal' || paletteName == 'Mono';
      bgColor = hexToColor(
        themeColors['background'] as String?,
        isDark ? const Color(0xFF1C1917) : const Color(0xFFFAF6F0),
      );
      textColor = hexToColor(
        textColors['primary'] as String?,
        isDark ? const Color(0xFFF5F5F4) : const Color(0xFF0F172A),
      );
      subtextColor = hexToColor(
        textColors['secondary'] as String?,
        isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C),
      );
      accentColor = hexToColor(
        themeColors['accent'] as String?,
        const Color(0xFFEA580C),
      );
    }

    final siteName = targetDoc?['site']?['name'] as String? ?? 'Lumen Coffee';

    // Check headline diff
    String headline = controller.getHeroHeadlineForDoc(targetDoc);
    for (final diff in controller.aiChangeDiffs) {
      if (diff['type'] == 'Headline') {
        headline = isAfter ? (diff['new'] ?? headline) : (diff['old'] ?? headline);
        break;
      }
    }
    final displayHeadline = headline.isNotEmpty
        ? headline
        : 'Small-batch coffee, roasted every Friday';

    String subheadline = controller.getHeroSubheadlineForDoc(targetDoc);
    for (final diff in controller.aiChangeDiffs) {
      if (diff['type'] == 'Description') {
        subheadline = isAfter ? (diff['new'] ?? subheadline) : (diff['old'] ?? subheadline);
        break;
      }
    }
    final displaySub = subheadline.isNotEmpty
        ? subheadline
        : 'Single-origin beans from farms we visit, roasted in our Alberta Street shop and shipped the same day.';

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Site title + hamburger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                siteName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                  color: textColor,
                ),
              ),
              Icon(
                LucideIcons.menu,
                size: 18,
                color: textColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subtitle / category
          Text(
            'Roastery and café in Portland',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6),

          // Headline
          Text(
            displayHeadline,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'serif',
              height: 1.15,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Body text
          Expanded(
            child: Text(
              displaySub,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: subtextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
