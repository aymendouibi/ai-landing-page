import 'package:flutter/material.dart';

/// A lightweight, zero-dependency shimmer effect widget with smooth diagonal sweep.
/// Supports both light and dark mode automatically.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shapeBorder;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.shapeBorder,
    this.baseColor,
    this.highlightColor,
  });

  const ShimmerBox.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  })  : width = size,
        height = size,
        borderRadius = 0,
        shapeBorder = const CircleBorder();

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBase = widget.baseColor ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final effectiveHighlight = widget.highlightColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: widget.shapeBorder != null
              ? ShapeDecoration(
                  shape: widget.shapeBorder!,
                  gradient: LinearGradient(
                    begin: Alignment(-1.5 + (_controller.value * 3.0), -0.3),
                    end: Alignment(0.5 + (_controller.value * 3.0), 0.3),
                    colors: [
                      effectiveBase,
                      effectiveHighlight,
                      effectiveBase,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment(-1.5 + (_controller.value * 3.0), -0.3),
                    end: Alignment(0.5 + (_controller.value * 3.0), 0.3),
                    colors: [
                      effectiveBase,
                      effectiveHighlight,
                      effectiveBase,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
        );
      },
    );
  }
}
