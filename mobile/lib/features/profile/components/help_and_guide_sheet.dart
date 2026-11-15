import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/storage/session_manager.dart';

class HelpAndGuideSheet extends StatelessWidget {
  const HelpAndGuideSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const HelpAndGuideSheet(),
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
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'help_title'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'help_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
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
            const SizedBox(height: 18),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    'help_recipes'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPromptCard(
                    context,
                    title: 'Minimalist Architecture Studio',
                    industry: 'Architecture · Copenhagen',
                    prompt:
                        'A quiet, architectural studio in Copenhagen featuring warm neutral tones, restrained typography, and a showcase grid of civic projects.',
                  ),
                  _buildPromptCard(
                    context,
                    title: 'Specialty Coffee Roastery',
                    industry: 'Food & Beverage · Seattle',
                    prompt:
                        'A boutique coffee roaster with single-origin bean subscriptions, warm amber accents, and an interactive brewing guide section.',
                  ),
                  _buildPromptCard(
                    context,
                    title: 'Handcrafted Ceramic Atelier',
                    industry: 'Craft & Retail · Kyoto',
                    prompt:
                        'Wabi-sabi pottery studio highlighting wood-fired vessels, workshop registration calendar, and an editorial gallery of artisanal wares.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'help_faq'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFaqItem(
                    context,
                    question: 'Can I export the code and host it anywhere?',
                    answer:
                        'Yes! All websites can be exported as clean, standalone HTML, CSS, and JS bundles or deployed directly to Vercel and Netlify.',
                  ),
                  _buildFaqItem(
                    context,
                    question: 'How do custom domains work?',
                    answer:
                        'Map an A record to our IP or CNAME to our proxy. We automatically issue and renew zero-configuration SSL certificates.',
                  ),
                  _buildFaqItem(
                    context,
                    question: 'Can I edit the generated copy manually?',
                    answer:
                        'Yes, every heading, paragraph, image, and CTA button is fully editable through the mobile page inspector.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMutedOf(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderSubtleOf(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'help_tours'.tr,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkOf(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'help_tours_desc'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMutedOf(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await SessionManager.resetShowcases();
                            if (context.mounted) {
                              Navigator.pop(context);
                              AppSnackbar.success(
                                'Walkthrough reset. The guided tour will appear on your next visit.',
                                context: context,
                              );
                            }
                          },
                          icon: const Icon(LucideIcons.rotateCcw, size: 15),
                          label: Text(
                            'help_replay_btn'.tr,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.inkOf(context),
                            side: BorderSide(
                              color: AppColors.borderSubtleOf(context),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.only(top: 12),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inkOf(context),
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'help_got_it'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(
    BuildContext context, {
    required String title,
    required String industry,
    required String prompt,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtleOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: prompt));
                  AppSnackbar.copied(
                    message: 'Prompt copied to clipboard!',
                    context: context,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            industry,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C5CFF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prompt,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.inkSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.inkSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
