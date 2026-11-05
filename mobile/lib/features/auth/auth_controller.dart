import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController(text: 'user@aibuilder.local');
  final passwordController = TextEditingController(text: 'UserSecret123!');
  final isLoading = false.obs;
  final errorMessage = RxnString();

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

