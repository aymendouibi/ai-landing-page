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

# StartApp / Start.io SDK Rules
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, SourceFile, LineNumberTable, *Annotation*, EnclosingMethod
-dontwarn com.startapp.**
-keep class com.startapp.** { *; }
-keep interface com.startapp.** { *; }

# RevenueCat Purchases SDK Rules
-dontwarn com.revenuecat.purchases.**
-keep class com.revenuecat.purchases.** { *; }
-keep interface com.revenuecat.purchases.** { *; }
