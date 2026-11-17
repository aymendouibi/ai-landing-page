import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';

class TemplateCard extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onPreview;
  final VoidCallback? onUse;
  final bool isLocked;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onPreview,
    this.onUse,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final name = template['name'] ?? 'Template';
    final industry = template['industry'] ?? 'Food & drink';
    final badge = template['badge'] ?? "EDITOR'S PICK";
    final desc = template['description'] ?? '';

    // Extract document & preview details
    final doc = template['active_version']?['document'];
    final rawHeadline =
        template['headline'] ??
        doc?['pages']?[0]?['sections']?[0]?['props']?['headline'] ??
        'Good coffee.\nBetter mornings.';
    final headline = rawHeadline
        .toString()
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n');
    final ctaText =
        template['ctaText'] ??
        doc?['pages']?[0]?['sections']?[0]?['props']?['ctaText'] ??
        'Explore our coffee';
    final previewList = template['preview_images'] as List?;
    final imageUrl = (previewList != null && previewList.isNotEmpty)
        ? previewList.first as String
        : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=1200&q=80';

    // Theme tokens
    final primaryColorHex =
        template['primaryColor'] ??
        doc?['site']?['theme']?['colors']?['primary'] ??
        '#0F172A';
    final primaryColor = _parseColor(
      primaryColorHex,
      isDark ? Colors.white : const Color(0xFF0F172A),
    );

    final bgColorHex =
        template['bgColor'] ?? doc?['site']?['theme']?['colors']?['background'];

    final isWedding =
        name.toString().toLowerCase().contains('ana') ||
        name.toString().toLowerCase().contains('wedding') ||
        name.toString().toLowerCase().contains('elysian') ||
        name.toString().toLowerCase().contains('botanical') ||
        name.toString().toLowerCase().contains('vows') ||
        industry.toString().toLowerCase().contains('wedding');
    final isLumen = name.toString().toLowerCase().contains('lumen');
    final isMarlow = name.toString().toLowerCase().contains('marlow');
    final isYoga = name.toString().toLowerCase().contains('yoga');

    Color canvasBg;
    if (bgColorHex != null && bgColorHex.toString().isNotEmpty) {
      canvasBg = _parseColor(
        bgColorHex,
        isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF6EE),
      );
    } else if (isLumen) {
      canvasBg = const Color(0xFFFAF7F2);
    } else if (isMarlow) {
      canvasBg = const Color(0xFFFAF8F5);
    } else if (isYoga) {
      canvasBg = const Color(0xFFFAF8F4);
    } else if (isWedding) {
      canvasBg = const Color(0xFFFAF5F5);
    } else {
      canvasBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF6EE);
    }
    final isCardDark = canvasBg.computeLuminance() < 0.45;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Badge Pill (▸ EDITOR'S PICK, ▸ QUIETLY BOLD, ▸ ROOM TO BREATHE, etc.)
        Row(
          children: [
            const Text(
              '▸',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              badge.toString().toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF3B82F6),
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C5CFF), Color(0xFFE46BFF)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.lock, size: 9, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 9),

        // 2. Mockup Canvas Frame
        GestureDetector(
          onTap: onPreview,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: canvasBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFF0F172A).withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Website Header Bar (Brand Name + Hamburger Menu)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: isCardDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.menu,
                        size: 16,
                        color: isCardDark
                            ? Colors.white70
                            : const Color(0xFF1E293B),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Mini Website Hero Headline (Editorial Serif Typography)
                  Container(
                    width: double.infinity,
                    alignment: isWedding ? Alignment.center : Alignment.centerLeft,
                    child: Text(
                      headline,
                      textAlign: isWedding ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.4,
                        color: isCardDark
                            ? Colors.white
                            : (isWedding
                                  ? const Color(0xFF2D1F23)
                                  : (isLumen
                                        ? const Color(0xFF2C241E)
                                        : const Color(0xFF18181B))),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mini Website Hero Image
                  ClipRRect(
                    borderRadius: isWedding
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(88),
                            topRight: Radius.circular(88),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          )
                        : BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 36,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mini Website CTA Pill Button
                  Align(
                    alignment: isWedding ? Alignment.center : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8.5,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ctaText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Card Footer Row (Title + Industry, Preview ↗ button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    industry,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Preview ↗ Pill Button
            GestureDetector(
              onTap: onPreview,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'templates_preview'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      LucideIcons.arrowUpRight,
                      size: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 4. Description Text
        Text(
          desc,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  static Color _parseColor(dynamic hex, Color fallback) {
    if (hex == null || hex is! String || hex.isEmpty) return fallback;
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }
}
