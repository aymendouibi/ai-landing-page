import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/colors.dart';

class PaymentResultDialog extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String message;
  final String? planTitle;
  final String? endsAt;
  final String? paymentTime;
  final String buttonText;
  final VoidCallback onAction;

  const PaymentResultDialog({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    this.planTitle,
    this.endsAt,
    this.paymentTime,
    required this.buttonText,
    required this.onAction,
  });

  static Future<void> showSuccess({
    required BuildContext context,
    required String planTitle,
    required String interval,
    String? endsAt,
    String? paymentTime,
    VoidCallback? onDismiss,
  }) {
    final effectiveEndsAt = endsAt != null && endsAt.isNotEmpty
        ? endsAt
        : (interval == 'yearly'
              ? DateTime.now().add(const Duration(days: 365))
              : DateTime.now().add(const Duration(days: 30)));

    final formattedDate = effectiveEndsAt is DateTime
        ? '${_monthName(effectiveEndsAt.month)} ${effectiveEndsAt.day}, ${effectiveEndsAt.year}'
        : effectiveEndsAt.toString();

    final now = DateTime.now();
    final defaultTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final effectivePaymentTime = paymentTime ?? defaultTime;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentResultDialog(
        isSuccess: true,
        title: 'payment_successful'.tr,
        planTitle: planTitle,
        endsAt: formattedDate,
        paymentTime: effectivePaymentTime,
        message: 'payment_active_message'.trParams({'date': formattedDate}),
        buttonText: 'payment_start_building'.tr,
        onAction: () {
          Navigator.of(ctx).pop();
          onDismiss?.call();
        },
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => PaymentResultDialog(
        isSuccess: false,
        title: 'payment_unsuccessful'.tr,
        message: message,
        buttonText: 'common_dismiss'.tr,
        onAction: () {
          Navigator.of(ctx).pop();
          onRetry?.call();
        },
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Lottie Header
            SizedBox(
              width: 110,
              height: 110,
              child: Lottie.asset(
                isSuccess
                    ? 'assets/animation/success.json'
                    : 'assets/animation/error.json',
                repeat: false,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : const Color(0xFFEF4444).withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isSuccess ? LucideIcons.check : LucideIcons.alertTriangle,
                      color: isSuccess
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 48,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.inkOf(context),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),

            // Plan Pill badge if success
            if (isSuccess && planTitle != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.16)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  planTitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Message / Expiration Details
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),

            if (isSuccess && endsAt != null && endsAt!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.calendarCheck,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'sub_membership_active_until'.tr,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            endsAt!,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isSuccess &&
                paymentTime != null &&
                paymentTime!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${'payment_completed_at'.tr} $paymentTime',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
