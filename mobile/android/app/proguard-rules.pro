# Proguard / R8 rules for Stripe and Flutter

# Suppress warnings for Stripe Push Provisioning optional classes
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.stripe.android.**

# Keep Stripe SDK classes
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }

# Keep React Native Stripe SDK bridge classes (used by flutter_stripe)
-dontwarn com.reactnativestripesdk.**
-keep class com.reactnativestripesdk.** { *; }
