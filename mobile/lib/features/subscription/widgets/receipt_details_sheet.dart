import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
import '../../../core/designsystem/colors.dart';
import 'past_subscription_helper.dart';

class ReceiptDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isBold;
  final bool isHighlight;

  const ReceiptDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    this.isBold = false,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13.5,
            fontWeight: isBold || isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight
                ? const Color(0xFF10B981)
                : (isBold
                    ? AppColors.inkOf(context)
                    : (isDark ? Colors.white : const Color(0xFF1E293B))),
          ),
        ),
      ],
    );
  }
}

class ReceiptDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const ReceiptDetailsSheet({
    super.key,
    required this.item,
  });

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptDetailsSheet(item: item),
    );
  }

  void _copyReference(BuildContext context, String reference) {
    if (reference.isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference));
    AppSnackbar.copied(
      message: 'Transaction reference copied: $reference',
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final title = PastSubscriptionHelper.getItemTitle(item);
    final formattedAmount = item['formatted_amount']?.toString() ??
        '€${item['amount'] ?? '4.99'}';
    final date = PastSubscriptionHelper.getItemDate(item);
    final time = PastSubscriptionHelper.getItemTime(item);
    final status = item['status']?.toString() ?? 'Expired';
    final reference = item['reference']?.toString() ?? '';
    final provider = item['provider']?.toString() ?? 'stripe';
    final interval = item['interval']?.toString() ?? 'monthly';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'past_sub_receipt_details'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkOf(context),
                    letterSpacing: -0.4,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  ReceiptDetailRow(
                    label: 'past_sub_receipt_plan'.tr,
                    value: title,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  ReceiptDetailRow(
                    label: 'past_sub_receipt_cycle'.tr,
                    value: interval.capitalizeFirst ?? interval,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  ReceiptDetailRow(
                    label: 'past_sub_receipt_period'.tr,
                    value: date,
                    isDark: isDark,
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ReceiptDetailRow(
                      label: 'past_sub_receipt_time'.tr,
                      value: time,
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 10),
                  ReceiptDetailRow(
                    label: 'past_sub_receipt_processor'.tr,
                    value: provider.toUpperCase(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  ReceiptDetailRow(
                    label: 'past_sub_receipt_status'.tr,
                    value: status,
                    isDark: isDark,
                    isHighlight: status.toLowerCase() == 'active',
                  ),
                  const Divider(height: 24, thickness: 1),
                  ReceiptDetailRow(
                    label: 'past_sub_receipt_total'.tr,
                    value: formattedAmount,
                    isDark: isDark,
                    isBold: true,
                  ),
                ],
              ),
            ),
            if (reference.isNotEmpty) ...[
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _copyReference(context, reference),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.copy,
                        size: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reference,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      Text(
                        'common_copy'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
}
