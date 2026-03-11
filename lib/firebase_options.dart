// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🔥 กูแก้ iOS ให้ตรงกับไฟล์ GoogleService-Info.plist ตัวล่าสุดของมึงเป๊ะๆ แล้ว!
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDxSfHvFoVvs7Ppq7SdnfF-Mdc1fCtaFg',
    appId: '1:650158918328:ios:7f8fba7ac746422045c24d',
    messagingSenderId: '650158918328',
    projectId: 'flutter-chat-app-7c14c',
    storageBucket: 'flutter-chat-app-7c14c.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMKfTJ3x0zkFgeeV98Zy1e0bP2w6fNn30',
    appId: '1:1042571644091:android:3eec1a5a406cc9b96eed9e',
    messagingSenderId: '1042571644091',
    projectId: 'flutter-chat-app-352e6', // ของ Android ปล่อยไว้ก่อน เราเทสต์บน iOS
    storageBucket: 'flutter-chat-app-352e6.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAc6t-UctmnStlX_3mVMXfRz_08NE12BM',
    appId: '1:1042571644091:web:0b904b4e8ef32ad86eed9e',
    messagingSenderId: '1042571644091',
    projectId: 'flutter-chat-app-352e6',
    authDomain: 'flutter-chat-app-352e6.firebaseapp.com',
    storageBucket: 'flutter-chat-app-352e6.firebasestorage.app',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
}