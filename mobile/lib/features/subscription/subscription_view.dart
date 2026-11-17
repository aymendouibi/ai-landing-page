import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/designsystem/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/stripe_service.dart';
import '../dashboard/dashboard_controller.dart';
import 'past_subscriptions_view.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  /// Navigates to the full-screen subscription view.
  static Future<void> open([BuildContext? context]) async {
    if (Get.key.currentState != null) {
      await Get.toNamed(AppRoutes.subscription);
    } else if (context != null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SubscriptionView()));
    }
  }

  /// Alias for backward compatibility with modal sheet callers.
  static Future<void> show(BuildContext context) => open(context);

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  bool isYearly = false;
  bool isProcessing = false;

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if ((Get.isDialogOpen ?? false) ||
        (Get.isBottomSheetOpen ?? false)) {
      Get.back();
    } else {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().activeTab.value = 'Profile';
      }
      Get.offAllNamed(AppRoutes.profile);
    }
  }

  Future<void> _handleUpgrade(DashboardController controller) async {
    setState(() => isProcessing = true);
    try {
      final success = await StripeService.instance.processPayment(
        context: context,
        isYearly: isYearly,
        controller: controller,
      );

      if (!mounted) return;
      if (success) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _handleDowngrade(DashboardController controller) async {
    setState(() => isProcessing = true);
    try {
      await controller.switchPlan('free');
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      AppSnackbar.info('sub_switched_free'.tr, context: context);
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: Stack(
        children: [
          // Ethereal pastel gradient wash matching design mockup
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF090D16),
                          const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                          const Color(0xFF1E293B).withValues(alpha: 0.4),
                          const Color(0xFF090D16),
                        ]
                      : [
                          const Color(0xFFBAE6FD).withValues(alpha: 0.85),
                          const Color(0xFFE9D5FF).withValues(alpha: 0.70),
                          const Color(0xFFF8FAFC),
                          const Color(0xFFF8FAFC),
                        ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 36),
              children: [
                // Top Navigation: Normal back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      key: const Key('subscription_back_button'),
                      tooltip: 'common_back'.tr,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        size: 20,
                        color: AppColors.inkOf(context),
                      ),
                      onPressed: _handleBack,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Eyebrow Tag
                Text(
                  'sub_eyebrow'.tr,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                // Main Headline
                Text(
                  'sub_headline'.tr,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.inkOf(context),
                    letterSpacing: -1.0,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'sub_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 22),

                // Dark Card: "Everything in Premium"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181726),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'sub_everything_premium'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow('profile_feature_generations'.tr),
                      _buildFeatureRow('profile_feature_ai_models'.tr),
                      _buildFeatureRow('profile_feature_domains'.tr),
                      _buildFeatureRow('profile_feature_templates'.tr),
                      _buildFeatureRow(
                        'profile_feature_ad_free'.tr,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // "Choose your billing" Title
                Text(
                  'sub_choose_billing'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkOf(context),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Segmented Toggle Pill (Monthly / Yearly)
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEDE9FE).withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Monthly Tab
                      Expanded(
                        child: GestureDetector(
                          key: const Key('billing_monthly_tab'),
                          onTap: () => setState(() => isYearly = false),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isYearly
                                  ? (isDark
                                        ? const Color(0xFF334155)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !isYearly
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.25 : 0.06,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'sub_monthly'.tr,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: !isYearly
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: !isYearly
                                    ? const Color(0xFF6D28D9)
                                    : (isDark
                                          ? Colors.white60
                                          : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Yearly Tab
                      Expanded(
                        child: GestureDetector(
                          key: const Key('billing_yearly_tab'),
                          onTap: () => setState(() => isYearly = true),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isYearly
                                  ? (isDark
                                        ? const Color(0xFF334155)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isYearly
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.25 : 0.06,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'sub_yearly'.tr,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isYearly
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isYearly
                                    ? const Color(0xFF6D28D9)
                                    : (isDark
                                          ? Colors.white60
                                          : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Pricing Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0).withValues(alpha: 0.90),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.03,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            isYearly ? '€59.88' : '€4.99',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkOf(context),
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isYearly ? 'sub_per_year'.tr : 'sub_per_month'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isYearly
                            ? 'sub_billed_yearly'.tr
                            : 'sub_billed_monthly'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Due Today Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'sub_due_today'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                      ),
                    ),
                    Text(
                      isYearly ? '€59.88' : '€4.99',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkOf(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isYearly ? 'sub_yearly_renews'.tr : 'sub_monthly_renews'.tr,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Continue to payment Button / Upgrade Button
                Obx(() {
                  final isAlreadyPro = controller.isPremium;
                  final currentInterval = controller.subscriptionInterval.value;
                  final isUpgradingToYearly =
                      isAlreadyPro && currentInterval == 'monthly' && isYearly;

                  String buttonLabel = 'sub_continue_payment'.tr;
                  if (isUpgradingToYearly) {
                    buttonLabel = 'sub_upgrade_yearly'.tr;
                  } else if (isAlreadyPro &&
                      !isYearly &&
                      currentInterval == 'monthly') {
                    buttonLabel = 'sub_renew_monthly'.tr;
                  } else if (isAlreadyPro &&
                      isYearly &&
                      currentInterval == 'yearly') {
                    buttonLabel = 'sub_renew_yearly'.tr;
                  }

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () => _handleUpgrade(controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  buttonLabel,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Caption
                      Center(
                        child: Text(
                          isYearly
                              ? 'sub_yearly_plan'.tr
                              : 'sub_monthly_plan'.tr,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),

                      // View past subscriptions & billing history link
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: () => PastSubscriptionsView.open(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.receipt,
                                size: 15,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'sub_view_past'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // If user is already Pro, offer cancel / switch to Free option
                      if (isAlreadyPro) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: isProcessing
                              ? null
                              : () => _handleDowngrade(controller),
                          child: Text(
                            'sub_switch_free'.tr,
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 14, color: Color(0xFFA78BFA)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
