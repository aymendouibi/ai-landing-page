import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../network/api_client.dart';
import '../storage/session_manager.dart';
import '../../features/dashboard/dashboard_controller.dart';

class RevenueCatService extends GetxService {
  /// Toggle to enable / disable RevenueCat throughout the app.
  /// Set to false to completely hide RevenueCat and rely exclusively on Stripe.
  static const bool isEnabled = false;

  /// RevenueCat API Key
  static const String apiKey = 'test_GaewqXEHwrnTFIWFpJtMNJylUWD';
  static const String appleApiKey = apiKey;
  static const String googleApiKey = apiKey;

  /// Primary Entitlement Identifier configured in RevenueCat dashboard
  static const String proEntitlementId = 'ai_landing_page_pro';
  static const String fallbackProEntitlementId = 'pro';

  /// Standard Package Identifiers configured in RevenueCat Offerings
  static const String monthlyPackageId = '\$rc_monthly';
  static const String yearlyPackageId = '\$rc_annual';
  static const String lifetimePackageId = '\$rc_lifetime';

  final RxBool isConfigured = false.obs;
  final RxBool isProcessing = false.obs;
  final Rx<Offerings?> currentOfferings = Rx<Offerings?>(null);
  final Rx<CustomerInfo?> customerInfo = Rx<CustomerInfo?>(null);

  static RevenueCatService get instance {
    if (Get.isRegistered<RevenueCatService>()) {
      return Get.find<RevenueCatService>();
    }
    return Get.put(RevenueCatService(), permanent: true);
  }

  /// Whether RevenueCat is running with a non-placeholder API key
  bool get hasValidKey {
    if (!isEnabled) return false;
    final key = Platform.isIOS
        ? appleApiKey
        : (Platform.isAndroid ? googleApiKey : apiKey);
    return key.isNotEmpty && !key.contains('YOUR_REVENUECAT');
  }

  /// Initialize the RevenueCat SDK
  Future<void> init() async {
    if (!isEnabled || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    try {
      final activeKey = Platform.isIOS
          ? appleApiKey
          : (Platform.isAndroid ? googleApiKey : apiKey);

      if (!hasValidKey) {
        debugPrint('RevenueCat Notice: API key not set or using placeholder ($activeKey).');
        return;
      }

      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);

      final configuration = PurchasesConfiguration(activeKey);
      final userId = await SessionManager.getUserId();
      if (userId != null && userId.isNotEmpty) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);
      isConfigured.value = true;

      // Listen for customer entitlement updates in background
      Purchases.addCustomerInfoUpdateListener((info) {
        customerInfo.value = info;
        _handleCustomerInfoUpdate(info);
      });

      // Fetch initial CustomerInfo and pre-cache Offerings
      final info = await Purchases.getCustomerInfo();
      customerInfo.value = info;
      await loadOfferings();
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
    }
  }

  /// Check whether the customer has an active Pro entitlement
  bool hasProEntitlement([CustomerInfo? info]) {
    final target = info ?? customerInfo.value;
    if (target == null) return false;
    final active = target.entitlements.active;
    return active.containsKey(proEntitlementId) ||
        active.containsKey(fallbackProEntitlementId);
  }

  /// Retrieve the latest customer info from RevenueCat servers
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!isConfigured.value) return null;
    try {
      final info = await Purchases.getCustomerInfo();
      customerInfo.value = info;
      return info;
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      return customerInfo.value;
    }
  }

  /// Associate purchases with the authenticated user ID
  Future<void> logIn(String userId) async {
    if (!isConfigured.value) return;
    try {
      final result = await Purchases.logIn(userId);
      customerInfo.value = result.customerInfo;
      await loadOfferings();
    } catch (e) {
      debugPrint('RevenueCat logIn error: $e');
    }
  }

  /// Log out from RevenueCat when the user signs out
  Future<void> logOut() async {
    if (!isConfigured.value) return;
    try {
      final info = await Purchases.logOut();
      customerInfo.value = info;
    } catch (e) {
      debugPrint('RevenueCat logOut error: $e');
    }
  }

  /// Load available Offerings (Monthly, Yearly, Lifetime)
  Future<Offerings?> loadOfferings() async {
    if (!isConfigured.value) return null;
    try {
      final offerings = await Purchases.getOfferings();
      currentOfferings.value = offerings;
      return offerings;
    } catch (e) {
      debugPrint('RevenueCat loadOfferings error: $e');
      return null;
    }
  }

  /// Present RevenueCat Pre-built Paywall UI
  Future<PaywallResult> presentPaywall({
    required DashboardController controller,
    Offering? offering,
  }) async {
    if (!isConfigured.value) {
      return PaywallResult.notPresented;
    }

    try {
      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
        displayCloseButton: true,
      );

      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        final info = await getCustomerInfo();
        if (hasProEntitlement(info)) {
          await _syncWithBackend(info!, controller: controller);
        }
      }

      return result;
    } catch (e) {
      debugPrint('RevenueCatUI.presentPaywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present RevenueCat Paywall only if user does not already have ai_landing_page_pro
  Future<PaywallResult> presentPaywallIfNeeded({
    required DashboardController controller,
  }) async {
    if (!isConfigured.value) {
      return PaywallResult.notPresented;
    }

    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        proEntitlementId,
        displayCloseButton: true,
      );

      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        final info = await getCustomerInfo();
        if (hasProEntitlement(info)) {
          await _syncWithBackend(info!, controller: controller);
        }
      }

      return result;
    } catch (e) {
      debugPrint('RevenueCatUI.presentPaywallIfNeeded error: $e');
      return PaywallResult.error;
    }
  }

  /// Present RevenueCat Customer Center (Manage subscription, change plan, request refund)
  Future<void> presentCustomerCenter({
    required DashboardController controller,
  }) async {
    if (!isConfigured.value) return;

    try {
      await RevenueCatUI.presentCustomerCenter(
        onRestoreCompleted: (info) async {
          customerInfo.value = info;
          if (hasProEntitlement(info)) {
            await _syncWithBackend(info, controller: controller);
          }
        },
      );
    } catch (e) {
      debugPrint('RevenueCatUI.presentCustomerCenter error: $e');
    }
  }

  /// Purchase a package directly by interval ('monthly', 'yearly', or 'lifetime')
  Future<bool> purchasePro({
    required String interval,
    required DashboardController controller,
  }) async {
    if (!isEnabled) {
      throw Exception('RevenueCat is currently disabled. Please use Stripe.');
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      await controller.switchPlan(
        'pro',
        interval: interval,
        provider: 'in_app',
      );
      return true;
    }

    if (!isConfigured.value) {
      throw Exception('RevenueCat is not configured. Please check your API key.');
    }

    isProcessing.value = true;
    try {
      final offerings = currentOfferings.value ?? await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        debugPrint('======================================================');
        debugPrint('🚨 [RevenueCat Error] current offering is null.');
        debugPrint('   Available offerings: ${offerings.all.keys.toList()}');
        debugPrint('======================================================');
        throw Exception('No active subscription offerings found in RevenueCat.');
      }

      Package? package;
      if (interval == 'lifetime') {
        package = current.lifetime;
      } else if (interval == 'yearly' || interval == 'annual') {
        package = current.annual;
      } else {
        package = current.monthly;
      }

      if (package == null) {
        debugPrint('======================================================');
        debugPrint('🚨 [RevenueCat Error] Package for "$interval" not found.');
        debugPrint('   Available in current offering: ${current.availablePackages.map((p) => p.identifier).toList()}');
        debugPrint('======================================================');
        throw Exception(
          'Subscription package for "$interval" not found in current offering.',
        );
      }

      debugPrint('💳 [RevenueCat] Purchasing package: ${package.identifier} (${package.storeProduct.identifier})...');
      final purchaseResult = await Purchases.purchasePackage(package);
      customerInfo.value = purchaseResult.customerInfo;

      if (hasProEntitlement(purchaseResult.customerInfo)) {
        await _syncWithBackend(
          purchaseResult.customerInfo,
          controller: controller,
          intervalOverride: interval,
          transactionId: purchaseResult.storeTransaction.transactionIdentifier,
        );
        return true;
      }

      return false;
    } on PlatformException catch (e, stack) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('ℹ️ [RevenueCat] Purchase cancelled by user.');
        return false;
      }
      debugPrint('======================================================');
      debugPrint('🚨 [RevenueCat PlatformException]');
      debugPrint('   ErrorCode: $errorCode');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.details}');
      debugPrint('   Code: ${e.code}');
      debugPrint('   StackTrace:\n$stack');
      debugPrint('======================================================');
      rethrow;
    } catch (e, stack) {
      debugPrint('======================================================');
      debugPrint('🚨 [RevenueCat Unexpected Error]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace:\n$stack');
      debugPrint('======================================================');
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Restore existing In-App Purchases (Required by Apple App Store Guideline 3.1.1)
  Future<bool> restorePurchases({required DashboardController controller}) async {
    if (!isEnabled) {
      return false;
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }

    if (!isConfigured.value) {
      throw Exception('RevenueCat is not configured.');
    }

    isProcessing.value = true;
    try {
      final info = await Purchases.restorePurchases();
      customerInfo.value = info;

      if (hasProEntitlement(info)) {
        await _syncWithBackend(info, controller: controller);
        return true;
      }
      return false;
    } on PlatformException catch (e, stack) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('======================================================');
      debugPrint('🚨 [RevenueCat Restore Error]');
      debugPrint('   ErrorCode: $errorCode');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.details}');
      debugPrint('   StackTrace:\n$stack');
      debugPrint('======================================================');
      rethrow;
    } catch (e, stack) {
      debugPrint('🚨 [RevenueCat Unexpected Restore Error]: $e\n$stack');
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Sync active entitlement state with Laravel backend API
  Future<void> _syncWithBackend(
    CustomerInfo info, {
    required DashboardController controller,
    String? intervalOverride,
    String? transactionId,
  }) async {
    final active = info.entitlements.active;
    final entitlement = active[proEntitlementId] ?? active[fallbackProEntitlementId];
    if (entitlement == null) return;

    final expirationDate = entitlement.expirationDate;
    final expirationMs = expirationDate != null
        ? DateTime.tryParse(expirationDate)?.millisecondsSinceEpoch
        : null;

    String interval = intervalOverride ?? 'monthly';
    if (intervalOverride == null) {
      final prodId = entitlement.productIdentifier.toLowerCase();
      if (prodId.contains('lifetime')) {
        interval = 'lifetime';
      } else if (prodId.contains('year') || prodId.contains('annual')) {
        interval = 'yearly';
      }
    }

    final txnId = transactionId ?? entitlement.latestPurchaseDate;

    // Switch plan using 'in_app' (supported on all backend environments)
    await controller.switchPlan(
      'pro',
      interval: interval,
      provider: 'in_app',
      paymentIntentId: txnId,
    );

    // Also notify the RevenueCat sync endpoint if present
    try {
      await ApiClient.syncRevenueCat(
        isPro: true,
        interval: interval,
        transactionId: txnId,
        expirationAtMs: expirationMs,
      );
    } catch (e) {
      debugPrint('ℹ️ [RevenueCatService] syncRevenueCat notice: $e');
    }

    await controller.loadSubscription();
  }

  /// Handle background customer info updates (e.g. renewal, cancellation)
  void _handleCustomerInfoUpdate(CustomerInfo info) async {
    customerInfo.value = info;
    final isPro = hasProEntitlement(info);
    if (Get.isRegistered<DashboardController>()) {
      final controller = Get.find<DashboardController>();
      if (isPro != controller.isPremium) {
        await controller.loadSubscription();
      }
    }
  }
}
