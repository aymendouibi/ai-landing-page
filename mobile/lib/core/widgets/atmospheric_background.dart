import 'package:flutter/material.dart';

/// Atmospheric mesh background glow matching the login screen aesthetic.
/// Features a soft cyan radial blur at top-left, lavender at top-right,
/// and subtle violet tint at mid-left.
class AtmosphericBackground extends StatelessWidget {
  final bool? isDark;
  const AtmosphericBackground({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top-left cyan blur
            Positioned(
              top: -80,
              left: -80,
              width: 380,
              height: 380,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: dark
                        ? [
                            const Color(0xFF0284C7).withValues(alpha: 0.22),
                            const Color(0xFF0369A1).withValues(alpha: 0.08),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFBAE6FD).withValues(alpha: 0.60),
                            const Color(0xFFE0F2FE).withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Top-right lavender blur
            Positioned(
              top: -60,
              right: -90,
              width: 420,
              height: 420,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: dark
                        ? [
                            const Color(0xFF6366F1).withValues(alpha: 0.24),
                            const Color(0xFF4F46E5).withValues(alpha: 0.09),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFDDD6FE).withValues(alpha: 0.65),
                            const Color(0xFFEDE9FE).withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Mid-left soft violet tint
            Positioned(
              top: 240,
              left: -80,
              width: 300,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: dark
                        ? [
                            const Color(0xFF7C3AED).withValues(alpha: 0.16),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFC4B5FD).withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
