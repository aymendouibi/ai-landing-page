import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/social_auth_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController(text: 'user@aibuilder.local');
  final passwordController = TextEditingController(text: 'UserSecret123!');
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
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (isAnyLoading) return;
    isLoadingGoogle.value = true;
    errorMessage.value = null;

    try {
      final result = await SocialAuthService.signInWithGoogle();
      if (result.cancelled) {
        return;
      }
      if (result.success) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        errorMessage.value = result.errorMessage ?? 'Google sign-in failed.';
      }
    } catch (e) {
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
        return;
      }
      if (result.success) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        errorMessage.value = result.errorMessage ?? 'Apple sign-in failed.';
      }
    } catch (e) {
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

