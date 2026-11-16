import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/social_auth_service.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isRegisterMode = false.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isLoadingGoogle = false.obs;
  final isLoadingApple = false.obs;
  final RxBool isAppleSupported;
  final errorMessage = RxnString();

  AuthController({bool? appleSupported})
      : isAppleSupported = (appleSupported ?? true).obs;

  bool get isAnyLoading =>
      isLoading.value || isLoadingGoogle.value || isLoadingApple.value;

  @override
  void onInit() {
    super.onInit();
    _checkAppleSupport();
  }

  void toggleMode() {
    isRegisterMode.toggle();
    errorMessage.value = null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> submit() async {
    if (isRegisterMode.value) {
      await register();
    } else {
      await login();
    }
  }

  Future<void> _checkAppleSupport() async {
    try {
      final supported = await SocialAuthService.isAppleSignInSupported();
      isAppleSupported.value = supported;
    } catch (_) {
      isAppleSupported.value = false;
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter both email and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await ApiClient.login(email, password);
      debugPrint('✅ [AUTH LOGIN]: Login successful for $email');
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('❌ [AUTH LOGIN ERROR]: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }
    if (password.length < 8) {
      errorMessage.value = 'Password must be at least 8 characters long';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await ApiClient.register(name, email, password);
      debugPrint('✅ [AUTH REGISTER]: Registered user successfully: $email');
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('❌ [AUTH REGISTER ERROR]: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.snackbar(
      'Forgot Password',
      'Password reset instructions will be sent to ${emailController.text.trim().isNotEmpty ? emailController.text.trim() : 'your email'}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E2235),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> signInWithGoogle() async {
    if (isAnyLoading) return;
    isLoadingGoogle.value = true;
    errorMessage.value = null;

    try {
      final result = await SocialAuthService.signInWithGoogle();
      if (result.cancelled) {
        debugPrint('ℹ️ [AUTH CONTROLLER]: Google sign-in cancelled.');
        return;
      }
      if (result.success) {
        debugPrint('✅ [AUTH CONTROLLER]: Google sign-in successful.');
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        debugPrint('❌ [AUTH CONTROLLER]: Google sign-in failed: ${result.errorMessage}');
        errorMessage.value = result.errorMessage ?? 'Google sign-in failed.';
      }
    } catch (e) {
      debugPrint('❌ [AUTH CONTROLLER]: Google sign-in uncaught exception: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingGoogle.value = false;
    }
  }

  Future<void> signInWithApple() async {
    if (isAnyLoading) return;
    isLoadingApple.value = true;
    errorMessage.value = null;

    try {
      final result = await SocialAuthService.signInWithApple();
      if (result.cancelled) {
        debugPrint('ℹ️ [AUTH CONTROLLER]: Apple sign-in cancelled.');
        return;
      }
      if (result.success) {
        debugPrint('✅ [AUTH CONTROLLER]: Apple sign-in successful.');
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        debugPrint('❌ [AUTH CONTROLLER]: Apple sign-in failed: ${result.errorMessage}');
        errorMessage.value = result.errorMessage ?? 'Apple sign-in failed.';
      }
    } catch (e) {
      debugPrint('❌ [AUTH CONTROLLER]: Apple sign-in uncaught exception: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingApple.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.logout();
    } finally {
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

