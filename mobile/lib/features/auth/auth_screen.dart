import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../profile/components/privacy_policy_sheet.dart';
import '../profile/components/terms_of_service_sheet.dart';
import 'auth_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Ambient atmospheric mesh gradient background
          _AtmosphericAuthBackground(isDark: isDark),

          // Foreground Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Obx(() {
                  final isRegister = controller.isRegisterMode.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Brand Overline
                      Text(
                        'auth_category'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDark
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF5B45E0),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Headline
                      Text(
                        isRegister
                            ? 'auth_register_title'.tr
                            : 'auth_welcome_title'.tr,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.8,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        isRegister
                            ? 'auth_register_subtitle'.tr
                            : 'auth_login_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Error message banner
                      if (controller.errorMessage.value != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF450A0A)
                                    .withValues(alpha: 0.6)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF991B1B)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.circleAlert,
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFDC2626),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value!,
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFFCA5A5)
                                        : const Color(0xFFB91C1C),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Full name input (Register Mode only)
                      if (isRegister) ...[
                        _FieldLabel(
                          textKey: 'auth_name_label',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: controller.nameController,
                          hintText: 'auth_name_hint'.tr,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Email input
                      _FieldLabel(
                        textKey: 'auth_email_label',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: controller.emailController,
                        hintText: 'auth_email_hint'.tr,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),

                      // Password input
                      _FieldLabel(
                        textKey: 'auth_password_label',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: controller.passwordController,
                        hintText: 'auth_password_hint'.tr,
                        obscureText: !controller.isPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => controller.submit(),
                        isDark: isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            size: 20,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),

                      // Forgot password (Login Mode only)
                      if (!isRegister) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: controller.forgotPassword,
                            child: Text(
                              'auth_forgot_password'.tr,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF818CF8)
                                    : const Color(0xFF5B45E0),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Primary Button ("Log in" or "Create account")
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isAnyLoading
                              ? null
                              : controller.submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? Colors.white : const Color(0xFF181B26),
                            foregroundColor:
                                isDark ? const Color(0xFF0F172A) : Colors.white,
                            disabledBackgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : const Color(0xFF181B26)
                                    .withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isRegister
                                      ? 'auth_register_btn'.tr
                                      : 'auth_login_btn'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Divider "or continue with"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'auth_or_continue_with'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Continue with Google Button
                      _SocialButton(
                        onPressed: controller.isAnyLoading
                            ? null
                            : controller.signInWithGoogle,
                        isLoading: controller.isLoadingGoogle.value,
                        icon: Image.asset(
                          'assets/icons/google_logo.png',
                          width: 22,
                          height: 22,
                        ),
                        label: 'auth_continue_google'.tr,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),

                      // Continue with Apple Button
                      if (controller.isAppleSupported.value) ...[
                        _SocialButton(
                          onPressed: controller.isAnyLoading
                              ? null
                              : controller.signInWithApple,
                          isLoading: controller.isLoadingApple.value,
                          icon: Icon(
                            Icons.apple,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            size: 24,
                          ),
                          label: 'auth_continue_apple'.tr,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 18),

                      // Mode Switcher ("New here? Create an account")
                      Center(
                        child: GestureDetector(
                          key: const Key('auth_mode_toggle'),
                          onTap: controller.toggleMode,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isRegister
                                      ? 'auth_already_have_account'.tr
                                      : 'auth_new_here'.tr,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isRegister
                                      ? 'auth_log_in'.tr
                                      : 'auth_create_account'.tr,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: isDark
                                        ? const Color(0xFF818CF8)
                                        : const Color(0xFF5B45E0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Legal footer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'auth_by_continuing'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  key: const Key('auth_terms_button'),
                                  onTap: () =>
                                      TermsOfServiceSheet.show(context),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      'auth_terms_of_service'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFF818CF8)
                                            : const Color(0xFF5B45E0),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  ' · ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                GestureDetector(
                                  key: const Key('auth_privacy_button'),
                                  onTap: () =>
                                      PrivacyPolicySheet.show(context),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      'auth_privacy_policy'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFF818CF8)
                                            : const Color(0xFF5B45E0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Atmospheric mesh background glow (soft cyan at top-left, lavender at top-right)
typedef _AtmosphericAuthBackground = AtmosphericBackground;

/// Bold field label placed outside above the input field
class _FieldLabel extends StatelessWidget {
  final String textKey;
  final bool isDark;

  const _FieldLabel({required this.textKey, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      textKey.tr,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Styled card input field with subtle border & shadow matching the design
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final bool isDark;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.suffixIcon,
    this.onSubmitted,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF243046) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0x080F172A),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color:
                  isDark ? const Color(0xFF818CF8) : const Color(0xFF5B45E0),
              width: 1.8,
            ),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

/// Clean card social authentication button
class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget icon;
  final String label;
  final bool isDark;

  const _SocialButton({
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF243046) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0x060F172A),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
