import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImagePreview extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImagePreview({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:')) {
      final commaIndex = url.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(url.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Container(
              width: width,
              height: height,
              color: const Color(0xFFE2E8F0),
              child: const Icon(LucideIcons.image, color: Color(0xFF94A3B8)),
            ),
          );
        } catch (_) {}
      }
    }

    final safeUrl = url.isNotEmpty
        ? url
        : 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80';
    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, u) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
      ),
      errorWidget: (context, u, error) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE2E8F0),
        child: const Icon(LucideIcons.image, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

