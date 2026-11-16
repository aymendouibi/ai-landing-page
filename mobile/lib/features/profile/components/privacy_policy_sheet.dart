import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';

class PrivacyPolicySheet extends StatelessWidget {
  const PrivacyPolicySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const PrivacyPolicySheet(),
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
            // Drag Handle
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

            // Top Header: Title + Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'privacy_title'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'privacy_updated'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceMutedOf(context),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Scrollable Policy Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: '1. Information We Collect',
                      body:
                          'We collect information necessary to provide you with the AI Landing Page, publishing, and hosting services. This includes:\n\n'
                          '• Account Information: Name, email address, password hash, and OAuth credentials (when signing in with Google or Apple).\n'
                          '• Website Content & Media: Site configurations, page layouts, text copy, images, uploaded branding assets, and custom domain DNS records.\n'
                          '• AI Interactions: Prompts, edit instructions, and generation history sent to our AI pipeline to draft and remix website sections.\n'
                          '• Technical & Device Data: IP address, operating system, browser type, and diagnostic logs to ensure high availability and prevent abuse.',
                    ),
                    _buildSection(
                      context,
                      title: '2. How We Use Your Data',
                      body:
                          'Your data is strictly used to deliver, maintain, and enhance the AI Landing Page platform:\n\n'
                          '• Compiling and rendering your website HTML, CSS, and modern responsive components.\n'
                          '• Managing live deployments, edge CDN hosting, and SSL certificates.\n'
                          '• Processing subscription billing, invoices, and entitlements via Stripe.\n'
                          '• Restoring revisions, draft history, and synchronizing state across your devices.',
                    ),
                    _buildSection(
                      context,
                      title: '3. AI Generation & Privacy Safeguards',
                      body:
                          'We respect your creative work and intellectual property:\n\n'
                          '• Zero Training on User Data: Your website copy, prompts, private drafts, and uploaded media are never used to train public AI foundation models.\n'
                          '• Isolated Context: Prompts passed to OpenRouter and our LLM endpoints exist solely for the duration of the generation request.\n'
                          '• Human Oversight: You retain full editorial control to review, accept, reject, or undo any AI-generated layout.',
                    ),
                    _buildSection(
                      context,
                      title: '4. Storage & Security',
                      body:
                          'All data is protected using industry-standard security measures:\n\n'
                          '• Encryption in Transit: All API traffic, file transfers, and editing sessions are encrypted using TLS 1.3 / HTTPS.\n'
                          '• Encryption at Rest: User records, site documents, and media assets are stored in encrypted databases and secure cloud buckets.\n'
                          '• Access Controls: Principle of least privilege is enforced for all infrastructure access.',
                    ),
                    _buildSection(
                      context,
                      title: '5. Third-Party Service Providers',
                      body:
                          'We partner with vetted, secure infrastructure providers to operate the platform:\n\n'
                          '• Cloudflare & Edge Networks: For global DNS routing, DDoS protection, and SSL termination.\n'
                          '• Stripe: For PCI-compliant subscription payment processing.\n'
                          '• Image & Asset Storage: For serving high-speed responsive imagery and uploads.',
                    ),
                    _buildSection(
                      context,
                      title: '6. Your Rights & Data Portability',
                      body:
                          'You maintain total ownership of your websites and uploaded media:\n\n'
                          '• Export Your Code: Export your sites into standalone static HTML/CSS/JS at any time.\n'
                          '• Delete Your Data: You may delete individual websites, pages, uploaded images, or request account deletion at any time via Edit Profile.\n'
                          '• Access & Rectification: Update your profile name, email, or language preferences directly from the Profile settings.',
                    ),
                    _buildSection(
                      context,
                      title: '7. Contact & Data Controller',
                      body:
                          'If you have questions, privacy inquiries, or data requests, please contact our Data Protection team at privacy@aibuilder.app.',
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
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSection(BuildContext context, {required String title, required String body}) {
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

