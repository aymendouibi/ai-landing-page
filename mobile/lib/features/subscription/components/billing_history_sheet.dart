import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/network/api_client.dart';

class BillingHistorySheet extends StatefulWidget {
  const BillingHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BillingHistorySheet(),
    );
  }

  @override
  State<BillingHistorySheet> createState() => _BillingHistorySheetState();
}

class _BillingHistorySheetState extends State<BillingHistorySheet> {
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
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Unable to load billing history.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.receipt,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'billing_hist_title'.tr,
                          style: TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkOf(context),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'billing_hist_subtitle'.tr,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Content body
            Flexible(
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : (errorMessage != null)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                              child: Text('common_try_again'.tr),
                            ),
                          ],
                        ),
                      ),
                    )
                  : items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.creditCard,
                              size: 48,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'billing_hist_empty'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkOf(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'billing_hist_empty_desc'.tr,
                              textAlign: TextAlign.center,
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
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final title =
                            item['title']?.toString() ?? 'Subscription';
                        final formattedAmount =
                            item['formatted_amount']?.toString() ??
                            '€${item['amount'] ?? '4.99'}';
                        final date = item['date']?.toString() ?? '';
                        final time =
                            item['time']?.toString() ??
                            (item['created_at'] != null
                                ? () {
                                    try {
                                      final dt = DateTime.parse(
                                        item['created_at'].toString(),
                                      ).toLocal();
                                      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                                    } catch (_) {
                                      return '';
                                    }
                                  }()
                                : '');
                        final status = item['status']?.toString() ?? 'Paid';
                        final reference = item['reference']?.toString() ?? '';
                        final isPaid =
                            status.toLowerCase() == 'paid' ||
                            status.toLowerCase() == 'active';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A).withValues(alpha: 0.7)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.inkOf(context),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 6,
                                          children: [
                                            Text(
                                              date,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                            if (time.isNotEmpty) ...[
                                              Text(
                                                '•',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? const Color(0xFF64748B)
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    LucideIcons.clock,
                                                    size: 11.5,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF94A3B8,
                                                          )
                                                        : const Color(
                                                            0xFF64748B,
                                                          ),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    time,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF94A3B8,
                                                            )
                                                          : const Color(
                                                              0xFF64748B,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formattedAmount,
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.inkOf(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? const Color(
                                                  0xFF10B981,
                                                ).withValues(alpha: 0.12)
                                              : Colors.orange.withValues(
                                                  alpha: 0.12,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isPaid
                                                ? const Color(0xFF10B981)
                                                : Colors.orange[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (reference.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFEEF2F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${'billing_hist_ref'.tr} $reference',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: isDark
                                          ? Colors.white60
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
