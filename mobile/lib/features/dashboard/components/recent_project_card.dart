import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';

class WebsitePreviewItem {
  final String id;
  final String title;
  final String category;
  final String headline;
  final String body;
  final String ctaText;
  final Color ctaColor;
  final String imageUrl;
  final bool isSerif;
  final Color bgCanvasColor;

  const WebsitePreviewItem({
    required this.id,
    required this.title,
    required this.category,
    required this.headline,
    required this.body,
    required this.ctaText,
    required this.ctaColor,
    required this.imageUrl,
    this.isSerif = true,
    this.bgCanvasColor = const Color(0xFFFAF8F5),
  });
}

class RecentProjectCard extends StatelessWidget {
  final WebsitePreviewItem item;
  final VoidCallback onClick;

  const RecentProjectCard({
    super.key,
    required this.item,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 225,
        height: 340,
        decoration: BoxDecoration(
          color: item.bgCanvasColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x181E1E50),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Preview Content
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Nav Bar (Title + Menu)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: item.isSerif ? 'serif' : null,
                          color: const Color(0xFF1E1E24),
                        ),
                      ),
                      const Icon(Icons.menu, size: 14, color: Color(0xFF1E1E24)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category Eyebrow
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF71717A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Hero Headline
                  Text(
                    item.headline,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                      fontFamily: item.isSerif ? 'serif' : null,
                      color: const Color(0xFF1E1E24),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Body Paragraph
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.35,
                      color: Color(0xFF71717A),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // CTA Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: item.ctaColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.ctaText,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Image Slice clipped to bottom rounded corners
            SizedBox(
              width: double.infinity,
              height: 115,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: const Color(0xFFE4E4E7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
