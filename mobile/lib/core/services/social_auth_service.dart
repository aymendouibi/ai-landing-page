import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../network/api_client.dart';

class SocialAuthResult {
  final bool success;
  final bool cancelled;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const SocialAuthResult._({
    required this.success,
    this.cancelled = false,
    this.errorMessage,
    this.data,
  });

  factory SocialAuthResult.success(Map<String, dynamic> data) =>
      SocialAuthResult._(success: true, data: data);

  factory SocialAuthResult.cancelled() =>
      const SocialAuthResult._(success: false, cancelled: true);

  factory SocialAuthResult.failure(String error) =>
      SocialAuthResult._(success: false, errorMessage: error);
}

class SocialAuthService {
  static const String serverClientId =
      '810241219942-mo6ne66u4221qokjcf4l1scutpmf39u7.apps.googleusercontent.com';

  static const String iosClientId =
      '810241219942-7iknljf99skdolpvbh9l69iktqsqgdr0.apps.googleusercontent.com';

  static bool _isGoogleInitialized = false;

  /// Ensure Google Sign-In instance is initialized exactly once.
  static Future<void> ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
        clientId: (!kIsWeb && Platform.isIOS) ? iosClientId : null,
      );
      _isGoogleInitialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn initialize notice: $e');
      _isGoogleInitialized = true;
    }
  }

  /// Sign in using Google Sign-In and authenticate with the Laravel backend.
  static Future<SocialAuthResult> signInWithGoogle() async {
    try {
      await ensureGoogleInitialized();

      // Sign out first if needed to allow account switching
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();

      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        return SocialAuthResult.failure(
          'Could not retrieve Google ID token. Please try again.',
        );
      }

      final deviceName = kIsWeb
          ? 'Web Client'
          : (Platform.isIOS ? 'iOS Device' : 'Android Device');

      final data = await ApiClient.signInWithGoogle(
        idToken,
        deviceName: deviceName,
      );

      return SocialAuthResult.success(data);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('ℹ️ [AUTH GOOGLE]: Sign-in was cancelled by user.');
        return SocialAuthResult.cancelled();
      }
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('❌ [AUTH GOOGLE ERROR]: ${e.description ?? e.code.toString()}');
      debugPrint('   Exception Code: ${e.code}');
      debugPrint('   Description: ${e.description}');
      debugPrint('   Details: ${e.details}');
      debugPrint('════════════════════════════════════════════════════════════');
      final displayMessage = (e.description?.contains('keychain') ?? false)
          ? 'Google Sign-In configuration error: Bundle ID or client ID mismatch in GoogleService-Info.plist.'
          : (e.description ?? 'Google sign-in was interrupted. Please try again.');
      return SocialAuthResult.failure(displayMessage);
    } catch (e, stack) {
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('❌ [AUTH GOOGLE EXCEPTION]: $e');
      debugPrint('   Stack trace: $stack');
      debugPrint('════════════════════════════════════════════════════════════');
      final msg = e.toString().replaceFirst('Exception: ', '');
      return SocialAuthResult.failure(msg);
    }
  }

  /// Sign in using Sign in with Apple and authenticate with the Laravel backend.
  static Future<SocialAuthResult> signInWithApple() async {
    try {
      final isAvailable = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
      if (!isAvailable) {
        final available = await SignInWithApple.isAvailable();
        if (!available) {
          debugPrint('⚠️ [AUTH APPLE]: Sign in with Apple not supported on this device/platform.');
          return SocialAuthResult.failure(
            'Sign in with Apple is not supported on this device.',
          );
        }
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        debugPrint('❌ [AUTH APPLE ERROR]: Missing identity token in Apple credential.');
        return SocialAuthResult.failure(
          'Could not retrieve Apple identity token.',
        );
      }

      // Format name if provided on first authorization
      final nameParts = [credential.givenName, credential.familyName]
          .where((s) => s != null && s.trim().isNotEmpty)
          .cast<String>()
          .toList();
      final fullName = nameParts.isNotEmpty ? nameParts.join(' ') : null;

      final deviceName = kIsWeb
          ? 'Web Client'
          : (Platform.isIOS ? 'iOS Device' : 'Apple Device');

      final data = await ApiClient.signInWithApple(
        identityToken,
        name: fullName,
        deviceName: deviceName,
      );

      return SocialAuthResult.success(data);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint('ℹ️ [AUTH APPLE]: User cancelled authorization.');
        return SocialAuthResult.cancelled();
      }
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('❌ [AUTH APPLE ERROR]: ${e.message}');
      debugPrint('   Code: ${e.code}');
      debugPrint('════════════════════════════════════════════════════════════');
      final isNotEntitled = e.message.contains('-7026') ||
          e.code == AuthorizationErrorCode.unknown ||
          e.message.toLowerCase().contains('unknown');
      final displayMessage = isNotEntitled
          ? 'Apple Sign-In is unavailable on the simulator without an Apple Developer provisioning profile and iCloud sign-in.'
          : 'Apple sign-in: ${e.message}';
      return SocialAuthResult.failure(displayMessage);
    } catch (e, stack) {
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('❌ [AUTH APPLE EXCEPTION]: $e');
      debugPrint('   Stack trace: $stack');
      debugPrint('════════════════════════════════════════════════════════════');
      final msg = e.toString().replaceFirst('Exception: ', '');
      return SocialAuthResult.failure(msg);
    }
  }

  /// Optional override for automated test environments
  static bool? mockAppleSignInSupported;

  /// Check whether Apple sign in is supported on the current device
  static Future<bool> isAppleSignInSupported() async {
    if (mockAppleSignInSupported != null) {
      return mockAppleSignInSupported!;
    }
    if (kIsWeb) return false;
    if (Platform.isIOS || Platform.isMacOS) return true;
    try {
      return await SignInWithApple.isAvailable();
    } catch (_) {
      return false;
    }
  }
}
