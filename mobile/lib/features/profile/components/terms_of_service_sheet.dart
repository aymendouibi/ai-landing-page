import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';

class TermsOfServiceSheet extends StatelessWidget {
  const TermsOfServiceSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const TermsOfServiceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'terms_title'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'terms_updated'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMutedOf(context),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.borderSubtleOf(context),
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: '1. Acceptance of Terms',
                      body:
                          'By accessing or using AI Landing Page Builder, you agree to be bound by these Terms of Service and all applicable local, national, and international laws. If you disagree with any part of these terms, you may not access the service.',
                    ),
                    _buildSection(
                      context,
                      title: '2. Ownership of Generated Content',
                      body:
                          'You retain full ownership, intellectual property rights, and copyright to all landing pages, websites, graphics, layouts, and copy created using this platform. We assert zero claim of ownership over websites published or exported by you.',
                    ),
                    _buildSection(
                      context,
                      title: '3. Acceptable Use Policy',
                      body:
                          'You agree not to use the builder to create websites that engage in deceptive phishing, distribute malicious software, promote illegal activities, or infringe on third-party trademarks or copyrighted content. Violation may result in immediate suspension.',
                    ),
                    _buildSection(
                      context,
                      title: '4. AI Generation & Limitations',
                      body:
                          'Our AI assistants generate website structure, copy, and layout recommendations based on your prompts. While we strive for high quality, generated copy should be reviewed for factual accuracy and compliance before publishing.',
                    ),
                    _buildSection(
                      context,
                      title: '5. Subscriptions & Billing',
                      body:
                          'Paid subscriptions grant access to additional AI generation credits, custom domain connections, and advanced code export features. Subscriptions renew automatically unless cancelled before the renewal date.',
                    ),
                    _buildSection(
                      context,
                      title: '6. Limitation of Liability',
                      body:
                          'The service is provided "as is" and "as available". In no event shall the platform be liable for indirect, incidental, or consequential damages resulting from downtime or lost business revenue.',
                    ),
                    _buildSection(
                      context,
                      title: '7. Governing Law',
                      body:
                          'These Terms are governed by and construed in accordance with applicable laws. For questions regarding these terms, reach out to legal@aibuilder.app.',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Close Button
            Container(
              padding: const EdgeInsets.only(top: 12),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'close'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.inkSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
