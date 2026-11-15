import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2CUCgKJkHqzLvG4LHZRLTQFPOXQU1lHo',
    appId: '1:810241219942:web:f099c8cd656e5104813ca7',
    messagingSenderId: '810241219942',
    projectId: 'website-generator-ce422',
    authDomain: 'website-generator-ce422.firebaseapp.com',
    storageBucket: 'website-generator-ce422.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcQdM1hVJoih8c9LkogfVs2ibgysO8eKU',
    appId: '1:810241219942:android:f099c8cd656e5104813ca7',
    messagingSenderId: '810241219942',
    projectId: 'website-generator-ce422',
    storageBucket: 'website-generator-ce422.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2CUCgKJkHqzLvG4LHZRLTQFPOXQU1lHo',
    appId: '1:810241219942:ios:f099c8cd656e5104813ca7',
    messagingSenderId: '810241219942',
    projectId: 'website-generator-ce422',
    storageBucket: 'website-generator-ce422.appspot.com',
    iosClientId:
        '810241219942-7iknljf99skdolpvbh9l69iktqsqgdr0.apps.googleusercontent.com',
    iosBundleId: 'com.douibi.landing.ai',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC2CUCgKJkHqzLvG4LHZRLTQFPOXQU1lHo',
    appId: '1:810241219942:ios:f099c8cd656e5104813ca7',
    messagingSenderId: '810241219942',
    projectId: 'website-generator-ce422',
    storageBucket: 'website-generator-ce422.appspot.com',
    iosClientId:
        '810241219942-7iknljf99skdolpvbh9l69iktqsqgdr0.apps.googleusercontent.com',
    iosBundleId: 'com.douibi.landing.ai',
  );
}
