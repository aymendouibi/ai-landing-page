import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/designsystem/app_snackbar.dart';
import '../../core/designsystem/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/revenue_cat_service.dart';
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
  // 'wallet' = Apple Pay (iOS) / Google Pay (Android) via RevenueCat
  // 'card' = Credit / Debit Card via Stripe
  late String selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // Default to Credit Card (Stripe) as requested
    selectedPaymentMethod = 'card';
  }

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
      bool success = false;
      if (selectedPaymentMethod == 'card') {
        debugPrint('💳 [PAYMENT] User selected Credit Card (Stripe)');
        success = await StripeService.instance.processPayment(
          context: context,
          isYearly: isYearly,
          controller: controller,
        );
      } else {
        debugPrint('🍏 [PAYMENT] User selected Apple / Google Pay (RevenueCat)');
        if (RevenueCatService.instance.hasValidKey) {
          success = await RevenueCatService.instance.purchasePro(
            interval: isYearly ? 'yearly' : 'monthly',
            controller: controller,
          );
        } else {
          // Fallback to Stripe in environments without in-app purchase credentials
          debugPrint('⚠️ [PAYMENT] RevenueCat key unconfigured, falling back to Stripe');
          success = await StripeService.instance.processPayment(
            context: context,
            isYearly: isYearly,
            controller: controller,
          );
        }
      }

      if (!mounted) return;
      if (success) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('======================================================');
      debugPrint('🚨 [PAYMENT ERROR - SubscriptionView._handleUpgrade]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace:\n$stackTrace');
      debugPrint('======================================================');
      if (mounted) {
        AppSnackbar.error(
          e.toString().replaceAll('Exception: ', ''),
          title: 'common_error'.tr,
        );
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _handleRestorePurchases(DashboardController controller) async {
    setState(() => isProcessing = true);
    try {
      debugPrint('🔄 [PAYMENT] Initiating restore purchases...');
      if (!RevenueCatService.instance.hasValidKey) {
        debugPrint('⚠️ [PAYMENT] RevenueCat key is empty or invalid.');
        AppSnackbar.info('sub_restore_empty'.tr, context: context);
        return;
      }

      final restored = await RevenueCatService.instance.restorePurchases(
        controller: controller,
      );
      debugPrint('🔄 [PAYMENT] Restore result: $restored');

      if (!mounted) return;
      if (restored) {
        AppSnackbar.success('sub_restore_success'.tr, context: context);
      } else {
        AppSnackbar.info('sub_restore_empty'.tr, context: context);
      }
    } catch (e, stackTrace) {
      debugPrint('======================================================');
      debugPrint('🚨 [PAYMENT ERROR - Restore Purchases]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace:\n$stackTrace');
      debugPrint('======================================================');
      if (mounted) {
        AppSnackbar.error(
          e.toString().replaceAll('Exception: ', ''),
          title: 'common_error'.tr,
        );
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
                        ? const Color(0xFF181528)
                        : const Color(0xFFEDE9FE).withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFDDD6FE).withValues(alpha: 0.60),
                    ),
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
                                        ? const Color(0xFF581C87)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: !isYearly && !isDark
                                  ? Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 0.8,
                                    )
                                  : null,
                              boxShadow: !isYearly
                                  ? [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(0xFF581C87).withValues(alpha: 0.40)
                                            : Colors.black.withValues(alpha: 0.06),
                                        blurRadius: isDark ? 8 : 6,
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
                                    ? (isDark
                                          ? Colors.white
                                          : const Color(0xFF581C87))
                                    : (isDark
                                          ? const Color(0xFF94A3B8)
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
                                        ? const Color(0xFF581C87)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isYearly && !isDark
                                  ? Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 0.8,
                                    )
                                  : null,
                              boxShadow: isYearly
                                  ? [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(0xFF581C87).withValues(alpha: 0.40)
                                            : Colors.black.withValues(alpha: 0.06),
                                        blurRadius: isDark ? 8 : 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'sub_yearly'.tr,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: isYearly
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isYearly
                                        ? (isDark
                                              ? Colors.white
                                              : const Color(0xFF581C87))
                                        : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.22)
                                        : const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-30%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
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
                            isYearly ? '€41.90' : '€4.99',
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
                      isYearly ? '€41.90' : '€4.99',
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
                const SizedBox(height: 18),

                // Payment Method Selector (Apple Pay / Google Pay vs Credit Card)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sub_payment_method'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Option 1: Apple Pay (iOS) or Google Pay (Android)
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => selectedPaymentMethod = 'wallet'),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: selectedPaymentMethod == 'wallet'
                                    ? (isDark
                                        ? const Color(0xFF581C87).withValues(alpha: 0.25)
                                        : const Color(0xFFEDE9FE))
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedPaymentMethod == 'wallet'
                                      ? (isDark
                                          ? const Color(0xFFA855F7)
                                          : const Color(0xFF7C3AED))
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFFE2E8F0)),
                                  width: selectedPaymentMethod == 'wallet' ? 1.8 : 1.0,
                                ),
                                boxShadow: selectedPaymentMethod == 'wallet'
                                    ? [
                                        BoxShadow(
                                          color: isDark
                                              ? const Color(0xFF581C87).withValues(alpha: 0.35)
                                              : const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Platform.isIOS ? Icons.apple : LucideIcons.smartphone,
                                    size: 20,
                                    color: selectedPaymentMethod == 'wallet'
                                        ? (isDark ? const Color(0xFFC4B5FD) : const Color(0xFF581C87))
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      Platform.isIOS ? 'sub_apple_pay'.tr : 'sub_google_pay'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: selectedPaymentMethod == 'wallet'
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: selectedPaymentMethod == 'wallet'
                                            ? (isDark ? Colors.white : const Color(0xFF581C87))
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Option 2: Credit Card
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => selectedPaymentMethod = 'card'),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: selectedPaymentMethod == 'card'
                                    ? (isDark
                                        ? const Color(0xFF581C87).withValues(alpha: 0.25)
                                        : const Color(0xFFEDE9FE))
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedPaymentMethod == 'card'
                                      ? (isDark
                                          ? const Color(0xFFA855F7)
                                          : const Color(0xFF7C3AED))
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFFE2E8F0)),
                                  width: selectedPaymentMethod == 'card' ? 1.8 : 1.0,
                                ),
                                boxShadow: selectedPaymentMethod == 'card'
                                    ? [
                                        BoxShadow(
                                          color: isDark
                                              ? const Color(0xFF581C87).withValues(alpha: 0.35)
                                              : const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.creditCard,
                                    size: 18,
                                    color: selectedPaymentMethod == 'card'
                                        ? (isDark ? const Color(0xFFC4B5FD) : const Color(0xFF581C87))
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'sub_credit_card'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: selectedPaymentMethod == 'card'
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: selectedPaymentMethod == 'card'
                                            ? (isDark ? Colors.white : const Color(0xFF581C87))
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Continue to payment Button / Upgrade Button
                Obx(() {
                  final isAlreadyPro = controller.isPremium;
                  final currentInterval = controller.subscriptionInterval.value;
                  final isUpgradingToYearly =
                      isAlreadyPro && currentInterval == 'monthly' && isYearly;

                  String buttonLabel = selectedPaymentMethod == 'card'
                      ? 'sub_pay_with_card'.tr
                      : (Platform.isIOS
                          ? 'sub_pay_with_apple'.tr
                          : 'sub_pay_with_google'.tr);

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
                            backgroundColor: const Color(0xFF581C87),
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isUpgradingToYearly
                                          ? LucideIcons.sparkles
                                          : (selectedPaymentMethod == 'card'
                                              ? LucideIcons.creditCard
                                              : (Platform.isIOS
                                                  ? Icons.apple
                                                  : LucideIcons.smartphone)),
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      buttonLabel,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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

                      // Links: View Past Subscriptions & Restore Purchases
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          InkWell(
                            onTap: () => PastSubscriptionsView.open(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.receipt,
                                    size: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'sub_view_past'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
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
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          InkWell(
                            onTap: isProcessing
                                ? null
                                : () => _handleRestorePurchases(controller),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.refreshCw,
                                    size: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'sub_restore_purchases'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
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
                        ],
                      ),

                      // If user is already Pro, offer Customer Center (manage subscription) or cancel
                      if (isAlreadyPro) ...[
                        const SizedBox(height: 10),
                        if (RevenueCatService.instance.hasValidKey) ...[
                          TextButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () => RevenueCatService.instance
                                      .presentCustomerCenter(
                                        controller: controller,
                                      ),
                            icon: const Icon(LucideIcons.settings2, size: 14),
                            label: const Text(
                              'Manage Subscription',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        TextButton(
                          onPressed: isProcessing
                              ? null
                              : () => _handleDowngrade(controller),
                          child: Text(
                            'sub_switch_free'.tr,
                            style: const TextStyle(
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
