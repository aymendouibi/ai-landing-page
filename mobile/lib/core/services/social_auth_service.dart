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
        return SocialAuthResult.cancelled();
      }
      debugPrint('GoogleSignInException: ${e.code} - ${e.description}');
      return SocialAuthResult.failure(
        e.description ?? 'Google sign-in was interrupted. Please try again.',
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
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
        return SocialAuthResult.cancelled();
      }
      return SocialAuthResult.failure('Apple sign-in: ${e.message}');
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
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
