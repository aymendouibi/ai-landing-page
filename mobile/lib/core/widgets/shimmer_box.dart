import 'package:flutter/material.dart';

/// Direction of the shimmer light sweep.
enum ShimmerDirection {
  ltr, // Left to right
  rtl, // Right to left
  ttb, // Top to bottom
  btt, // Bottom to top
  diagonalLtr, // Top-left to bottom-right (smooth natural diagonal)
  diagonalRtl, // Top-right to bottom-left
}

/// A master Shimmer wrapper that unifies shimmer effects across a tree of
/// [ShimmerBox] placeholders or arbitrary child widgets.
///
/// When [useShaderMask] is true (the default), a single hardware-accelerated
/// GPU shader sweeps across all descendant shapes simultaneously, providing
/// silky-smooth visual cohesion with zero per-box rebuild overhead.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final ShimmerDirection direction;
  final bool enabled;
  final bool useShaderMask;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.diagonalLtr,
    this.enabled = true,
    this.useShaderMask = true,
  });

  /// Factory constructor matching the standard `Shimmer.fromColors` API.
  const Shimmer.fromColors({
    super.key,
    required this.child,
    required Color baseColor,
    required Color highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.diagonalLtr,
    this.enabled = true,
  }) : baseColor = baseColor,
       highlightColor = highlightColor,
       useShaderMask = true;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBase = widget.baseColor ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final effectiveHighlight = widget.highlightColor ??
        (isDark ? const Color(0xFF384964) : const Color(0xFFFFFFFF));

    final gradientColors = [
      effectiveBase,
      Color.lerp(effectiveBase, effectiveHighlight, 0.4)!,
      effectiveHighlight,
      Color.lerp(effectiveBase, effectiveHighlight, 0.4)!,
      effectiveBase,
    ];
    const gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];

    Widget content = widget.child;

    if (widget.useShaderMask) {
      content = AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              if (bounds.isEmpty) {
                return const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                ).createShader(bounds);
              }

              final width = bounds.width;
              final height = bounds.height;
              final percent = _controller.value;

              final Rect rect;
              Alignment begin = Alignment.topLeft;
              Alignment end = Alignment.bottomRight;

              switch (widget.direction) {
                case ShimmerDirection.ltr:
                  final dx = -width * 1.5 + (percent * 3.0 * width);
                  rect = Rect.fromLTWH(dx, 0, width * 1.5, height);
                  begin = Alignment.centerLeft;
                  end = Alignment.centerRight;
                  break;
                case ShimmerDirection.rtl:
                  final dx = width * 1.5 - (percent * 3.0 * width);
                  rect = Rect.fromLTWH(dx, 0, width * 1.5, height);
                  begin = Alignment.centerRight;
                  end = Alignment.centerLeft;
                  break;
                case ShimmerDirection.ttb:
                  final dy = -height * 1.5 + (percent * 3.0 * height);
                  rect = Rect.fromLTWH(0, dy, width, height * 1.5);
                  begin = Alignment.topCenter;
                  end = Alignment.bottomCenter;
                  break;
                case ShimmerDirection.btt:
                  final dy = height * 1.5 - (percent * 3.0 * height);
                  rect = Rect.fromLTWH(0, dy, width, height * 1.5);
                  begin = Alignment.bottomCenter;
                  end = Alignment.topCenter;
                  break;
                case ShimmerDirection.diagonalLtr:
                  final dx = -width * 2.0 + (percent * 4.0 * width);
                  final dy = -height * 2.0 + (percent * 4.0 * height);
                  rect = Rect.fromLTWH(dx, dy, width * 2.0, height * 2.0);
                  begin = Alignment.topLeft;
                  end = Alignment.bottomRight;
                  break;
                case ShimmerDirection.diagonalRtl:
                  final dx = width * 2.0 - (percent * 4.0 * width);
                  final dy = -height * 2.0 + (percent * 4.0 * height);
                  rect = Rect.fromLTWH(dx, dy, width * 2.0, height * 2.0);
                  begin = Alignment.topRight;
                  end = Alignment.bottomLeft;
                  break;
              }

              return LinearGradient(
                begin: begin,
                end: end,
                colors: gradientColors,
                stops: gradientStops,
              ).createShader(rect);
            },
            child: child,
          );
        },
      );
    }

    return ShimmerScope(
      animation: _controller,
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      isMasked: widget.useShaderMask,
      direction: widget.direction,
      child: content,
    );
  }
}

/// InheritedWidget that provides shared shimmer configuration and timing
/// to descendant widgets.
class ShimmerScope extends InheritedWidget {
  final Animation<double> animation;
  final Color baseColor;
  final Color highlightColor;
  final bool isMasked;
  final ShimmerDirection direction;

  const ShimmerScope({
    super.key,
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
    required this.isMasked,
    required this.direction,
    required super.child,
  });

  static ShimmerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShimmerScope>();
  }

  static ShimmerScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No ShimmerScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant ShimmerScope oldWidget) {
    return animation != oldWidget.animation ||
        baseColor != oldWidget.baseColor ||
        highlightColor != oldWidget.highlightColor ||
        isMasked != oldWidget.isMasked ||
        direction != oldWidget.direction;
  }
}

/// A versatile, lightweight skeleton placeholder that supports:
/// - Standalone usage with smooth multi-stop specular gradient sweep
/// - Synchronized sweeping when nested under an ancestor [Shimmer]
/// - Built-in light/dark theme adaptation
/// - Multiple convenience constructors (.circle, .text, .button)
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shapeBorder;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.shapeBorder,
    this.baseColor,
    this.highlightColor,
    this.margin,
    this.padding,
  });

  const ShimmerBox.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
    this.margin,
    this.padding,
  }) : width = size,
       height = size,
       borderRadius = 0,
       shapeBorder = const CircleBorder();

  const ShimmerBox.text({
    super.key,
    required this.width,
    this.height = 14,
    this.borderRadius = 6,
    this.baseColor,
    this.highlightColor,
    this.margin,
    this.padding,
  }) : shapeBorder = null;

  const ShimmerBox.button({
    super.key,
    this.width = double.infinity,
    this.height = 48,
    this.borderRadius = 16,
    this.baseColor,
    this.highlightColor,
    this.margin,
    this.padding,
  }) : shapeBorder = null;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  AnimationController? _localController;

  AnimationController get _controller {
    _localController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    return _localController!;
  }

  @override
  void dispose() {
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ShimmerScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveBase = widget.baseColor ??
        scope?.baseColor ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));

    final effectiveHighlight = widget.highlightColor ??
        scope?.highlightColor ??
        (isDark ? const Color(0xFF384964) : const Color(0xFFFFFFFF));

    final decorationShape = widget.shapeBorder;
    final borderRadius = decorationShape == null
        ? BorderRadius.circular(widget.borderRadius)
        : null;

    // When inside a masked Shimmer, render a clean solid shape.
    // The parent's ShaderMask sweeps the shimmer across all boxes in a single GPU pass!
    if (scope != null && scope.isMasked) {
      return Container(
        margin: widget.margin,
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        decoration: decorationShape != null
            ? ShapeDecoration(shape: decorationShape, color: effectiveBase)
            : BoxDecoration(borderRadius: borderRadius, color: effectiveBase),
      );
    }

    final anim = scope?.animation ?? _controller;

    final gradientColors = [
      effectiveBase,
      Color.lerp(effectiveBase, effectiveHighlight, 0.4)!,
      effectiveHighlight,
      Color.lerp(effectiveBase, effectiveHighlight, 0.4)!,
      effectiveBase,
    ];
    const gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final t = anim.value;
        final gradient = LinearGradient(
          begin: Alignment(-2.5 + (t * 5.0), -1.2 + (t * 2.4)),
          end: Alignment(-0.5 + (t * 5.0), 0.0 + (t * 2.4)),
          colors: gradientColors,
          stops: gradientStops,
        );

        return Container(
          margin: widget.margin,
          padding: widget.padding,
          width: widget.width,
          height: widget.height,
          decoration: decorationShape != null
              ? ShapeDecoration(
                  shape: decorationShape,
                  gradient: gradient,
                )
              : BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: gradient,
                ),
        );
      },
    );
  }
}

/// A pre-styled skeleton card container matching the app's design system.
/// Automatically applies surface background, subtle border, rounded corners,
/// and wraps the child inside a synchronized [Shimmer].
class ShimmerCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const ShimmerCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 22,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: borderCol, width: 1.0),
      ),
      child: Shimmer(
        child: child,
      ),
    );
  }
}

/// Seamless cross-fade loader widget that switches smoothly from placeholder
/// to content when loading finishes.
class ShimmerLoading extends StatelessWidget {
  final bool isLoading;
  final Widget placeholder;
  final Widget child;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.placeholder,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: placeholder,
      secondChild: child,
      crossFadeState: isLoading
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: duration,
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
    );
  }
}
