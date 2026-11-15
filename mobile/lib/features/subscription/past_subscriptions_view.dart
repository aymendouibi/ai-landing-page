import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../dashboard/dashboard_controller.dart';
import 'widgets/past_current_plan_card.dart';
import 'widgets/past_subscription_helper.dart';
import 'widgets/past_subscription_item_card.dart';
import 'widgets/past_subscriptions_header.dart';
import 'widgets/past_subscriptions_promo_card.dart';
import 'widgets/receipt_details_sheet.dart';

export 'widgets/past_current_plan_card.dart';
export 'widgets/past_subscription_helper.dart';
export 'widgets/past_subscription_item_card.dart';
export 'widgets/past_subscriptions_header.dart';
export 'widgets/past_subscriptions_promo_card.dart';
export 'widgets/receipt_details_sheet.dart';

class PastSubscriptionsView extends StatefulWidget {
  const PastSubscriptionsView({super.key});

  /// Navigates to the full Past Subscriptions screen.
  static Future<void> open([BuildContext? context]) async {
    if (Get.key.currentState != null) {
      await Get.toNamed(AppRoutes.pastSubscriptions);
    } else if (context != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PastSubscriptionsView()),
      );
    }
  }

  @override
  State<PastSubscriptionsView> createState() => _PastSubscriptionsViewState();
}

class _PastSubscriptionsViewState extends State<PastSubscriptionsView> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final list = await ApiClient.getBillingHistory();
      if (mounted) {
        setState(() {
          items = list;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = 'past_sub_unable_to_load'.tr;
          isLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : null;

    final groupedByYear = PastSubscriptionHelper.groupByYear(items);
    final sortedYears = groupedByYear.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: Stack(
        children: [
          // Background Gradient matching mockup
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F172A),
                          const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                          const Color(0xFF1E293B).withValues(alpha: 0.4),
                          const Color(0xFF0F172A),
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
                // Circular back button, Title & Subtitle
                PastSubscriptionsHeader(
                  onBack: _handleBack,
                  isDark: isDark,
                ),
                const SizedBox(height: 22),

                // "Your current plan" Dark Card
                PastCurrentPlanCard(controller: controller),
                const SizedBox(height: 24),

                // Year Sections
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('common_try_again'.tr),
                        ),
                      ],
                    ),
                  )
                else ...[
                  for (final year in sortedYears) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        year,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkOf(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    for (final item in groupedByYear[year]!)
                      PastSubscriptionItemCard(
                        item: item,
                        isDark: isDark,
                        onTap: () => ReceiptDetailsSheet.show(context, item),
                      ),
                  ],
                ],

                // "Ready to create more?" Promo Card
                PastSubscriptionsPromoCard(isDark: isDark),

                // Footer
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'past_sub_no_auto_renew'.tr,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
