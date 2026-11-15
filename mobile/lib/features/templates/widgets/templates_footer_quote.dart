import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplatesFooterQuote extends StatelessWidget {
  final bool isDark;

  const TemplatesFooterQuote({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      child: Text(
        'templates_footer_quote'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.2,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
