import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/gradients.dart';
import '../../../core/designsystem/typography.dart';

class NewWebsiteBottomSheet extends StatelessWidget {
  final VoidCallback onDescribeToAi;
  final VoidCallback onStartFromTemplate;
  final VoidCallback onBlankWebsite;

  const NewWebsiteBottomSheet({
    super.key,
    required this.onDescribeToAi,
    required this.onStartFromTemplate,
    required this.onBlankWebsite,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDescribeToAi,
    required VoidCallback onStartFromTemplate,
    required VoidCallback onBlankWebsite,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => NewWebsiteBottomSheet(
        onDescribeToAi: () {
          Navigator.pop(context);
          onDescribeToAi();
        },
        onStartFromTemplate: () {
          Navigator.pop(context);
          onStartFromTemplate();
        },
        onBlankWebsite: () {
          Navigator.pop(context);
          onBlankWebsite();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row: "New website" + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New website',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),

                  // Circular Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceNeutral,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Option 1: "Describe it to AI"
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDescribeToAi,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.aiCardGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    // 3D Luminous AI Orb
                    const _LuminousAiOrb(size: 52),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Describe it to AI', style: AppTypography.itemTitle),
                          SizedBox(height: 3),
                          Text(
                            'Get a full first draft from one sentence',
                            style: AppTypography.helper,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Option 2: "Start from a template"
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onStartFromTemplate,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    // Template Stack Thumbnail
                    const _TemplateStackThumbnail(size: 52),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Start from a template', style: AppTypography.itemTitle),
                          SizedBox(height: 3),
                          Text(
                            'Browse designs by category',
                            style: AppTypography.helper,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Option 3: "Blank website"
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBlankWebsite,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    // Dashed Box with '+'
                    const _DashedPlusBox(size: 52),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Blank website', style: AppTypography.itemTitle),
                          SizedBox(height: 3),
                          Text(
                            'Build it section by section',
                            style: AppTypography.helper,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _LuminousAiOrb extends StatelessWidget {
  final double size;
  const _LuminousAiOrb({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AiOrbPainter(),
      ),
    );
  }
}

class _AiOrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Soft Outer Atmosphere Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.atmosphereViolet.withValues(alpha: 0.35),
          AppColors.atmosphereCyan.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glowPaint);

    // 2. 3D Luminous Sphere body
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFEDE9FE),
          AppColors.atmosphereViolet,
          AppColors.atmospherePink,
          AppColors.atmosphereCyan,
        ],
        center: const Alignment(-0.25, -0.3),
        radius: 0.95,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    // 3. Specular Highlight Reflection
    final highlightCenter = Offset(size.width * 0.34, size.height * 0.30);
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: highlightCenter, radius: radius * 0.45));
    canvas.drawCircle(highlightCenter, radius * 0.45, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TemplateStackThumbnail extends StatelessWidget {
  final double size;
  const _TemplateStackThumbnail({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background card tilted
          Positioned(
            left: 4,
            top: 6,
            child: Container(
              width: 32,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 0.5),
              ),
            ),
          ),

          // Foreground card with mock web content
          Positioned(
            left: 12,
            top: 8,
            child: Container(
              width: 34,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF475569), width: 0.8),
              ),
              padding: const EdgeInsets.all(2.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 2.5,
                    width: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Container(
                    height: 3.5,
                    width: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedPlusBox extends StatelessWidget {
  final double size;
  const _DashedPlusBox({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DashedBorderPainter(),
          ),
          const Icon(
            Icons.add,
            size: 20,
            color: AppColors.inkSecondary,
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD0DE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(10),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    double distance = 0;
    while (distance < totalLength) {
      final extractLength = math.min(dashWidth, totalLength - distance);
      final segment = metrics.extractPath(distance, distance + extractLength);
      canvas.drawPath(segment, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
