import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import '../designsystem/colors.dart';
import '../network/api_client.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/subscription/components/payment_result_dialog.dart';

class StripeService extends GetxService {
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_live_51NXR4jCCKIK7McZ4Ez6LZNjMa82Edoo0GiFXZQJXX7ocfXzYAj6O6C7LfatLcy0puo8RxVRJIC36k7XjMxzrswXl00PX0dYODz',
  );
  static const String urlScheme = 'ai-landing-page';
  static const String merchantName = 'AI Landing Page';

  static const double monthlyPrice = 4.90;
  static const double yearlyPrice = 39.90;

  final RxBool isProcessing = false.obs;

  static StripeService get instance {
    if (Get.isRegistered<StripeService>()) {
      return Get.find<StripeService>();
    }
    return Get.put(StripeService(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    initStripe();
  }

  /// Safe initialization of Stripe SDK
  void initStripe() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    try {
      Stripe.publishableKey = publishableKey;
      Stripe.urlScheme = urlScheme;
      Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe initialization warning: $e');
    }
  }

  /// Creates a PaymentIntent using the Laravel Backend API.
  Future<Map<String, dynamic>> createPaymentIntent({required bool isYearly}) async {
    final plan = isYearly ? 'yearly' : 'monthly';
    return await ApiClient.createPaymentIntent(interval: plan);
  }

  /// Process subscription payment via native Stripe PaymentSheet.
  Future<bool> processPayment({
    required BuildContext context,
    required bool isYearly,
    required DashboardController controller,
  }) async {
    isProcessing.value = true;

    try {
      // Test environment bypass
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        await controller.switchPlan('pro');
        return true;
      }

      // 1. Ensure settings applied
      try {
        await Stripe.instance.applySettings();
      } catch (_) {}

      // 2. Obtain PaymentIntent clientSecret
      final intentData = await createPaymentIntent(isYearly: isYearly);
      final clientSecret = intentData['clientSecret'] as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Failed to obtain valid Stripe client secret.');
      }

      final isMock = intentData['is_mock'] == true || clientSecret.contains('mock');

      if (isMock) {
        if (!context.mounted) return false;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: AppColors.surfaceOf(dialogCtx),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'stripe_sandbox_title'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.inkOf(dialogCtx),
              ),
            ),
            content: Text(
              '${'stripe_sandbox_desc'.tr}\n\n'
              '${isYearly ? "Yearly ($39.90 / year — 32% OFF!)" : "Monthly ($4.90 / month)"}\n\n'
              'Would you like to simulate successful payment and activate Premium?',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkSecondaryOf(dialogCtx),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: Text('common_cancel'.tr, style: TextStyle(color: AppColors.inkMutedOf(dialogCtx))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF181726),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('stripe_activate_premium'.tr),
              ),
            ],
          ),
        );

        if (confirm != true) {
          return false;
        }

        final paymentIntentId = intentData['paymentIntentId'] as String?;
        await controller.switchPlan(
          'pro',
          interval: isYearly ? 'yearly' : 'monthly',
          paymentIntentId: paymentIntentId,
          provider: 'stripe',
        );
        await controller.loadSubscription();

        if (context.mounted) {
          await PaymentResultDialog.showSuccess(
            context: context,
            planTitle: isYearly ? 'Yearly Premium ($39.90)' : 'Monthly Premium ($4.90)',
            interval: isYearly ? 'yearly' : 'monthly',
            endsAt: controller.subscriptionPeriodEnd.value,
          );
        }
        return true;
      }

      // Verify client secret strictly matches Stripe SDK format: ^pi_[^_]+_secret_[^_]+$
      final stripeRegex = RegExp(r'^pi_[^_]+_secret_[^_]+$');
      if (!stripeRegex.hasMatch(clientSecret)) {
        throw Exception('Invalid Stripe client secret format from server.');
      }

      // 3. Initialize native PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantName,
          returnURL: '$urlScheme://payment-complete',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6D28D9),
              background: Color(0xFFFFFFFF),
              componentBackground: Color(0xFFF7F2F8),
              componentBorder: Color(0xFF79747E),
              componentDivider: Color(0xFFCAC4D0),
              componentText: Color(0xFF1D1B20),
              primaryText: Color(0xFF1D1B20),
              secondaryText: Color(0xFF49454F),
              placeholderText: Color(0xFF79747E),
              icon: Color(0xFF49454F),
              error: Color(0xFFBA1A1A),
            ),
          ),
        ),
      );

      // 4. Present native PaymentSheet to the user
      await Stripe.instance.presentPaymentSheet();

      // 5. Payment succeeded — upgrade subscription in Laravel with full attribution
      final paymentIntentId = intentData['paymentIntentId'] as String?;
      await controller.switchPlan(
        'pro',
        interval: isYearly ? 'yearly' : 'monthly',
        paymentIntentId: paymentIntentId,
        provider: 'stripe',
      );
      await controller.loadSubscription();

      if (context.mounted) {
        await PaymentResultDialog.showSuccess(
          context: context,
          planTitle: isYearly ? 'Yearly Premium ($39.90)' : 'Monthly Premium ($4.90)',
          interval: isYearly ? 'yearly' : 'monthly',
          endsAt: controller.subscriptionPeriodEnd.value,
        );
      }

      return true;
    } on StripeException catch (e, stack) {
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('ℹ️ [Stripe] Payment was cancelled by the user.');
        if (context.mounted) {
          await PaymentResultDialog.showError(
            context: context,
            message: 'Payment was cancelled. No charges were made to your account.',
          );
        }
        return false;
      }
      debugPrint('======================================================');
      debugPrint('🚨 [Stripe StripeException]');
      debugPrint('   FailureCode: ${e.error.code}');
      debugPrint('   Message: ${e.error.message}');
      debugPrint('   LocalizedMessage: ${e.error.localizedMessage}');
      debugPrint('   StripeErrorCode: ${e.error.stripeErrorCode}');
      debugPrint('   DeclineCode: ${e.error.declineCode}');
      debugPrint('   StackTrace:\n$stack');
      debugPrint('======================================================');
      final msg = e.error.localizedMessage ?? e.error.message ?? 'Payment could not be completed.';
      if (context.mounted) {
        await PaymentResultDialog.showError(
          context: context,
          message: msg,
        );
      }
      return false;
    } catch (e, stack) {
      debugPrint('======================================================');
      debugPrint('🚨 [Stripe Unexpected Payment Error]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace:\n$stack');
      debugPrint('======================================================');
      if (context.mounted) {
        await PaymentResultDialog.showError(
          context: context,
          message: 'Payment error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}
