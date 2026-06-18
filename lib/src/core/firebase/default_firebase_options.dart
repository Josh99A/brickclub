import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA4uZVS3lgobVKZXBtNFEz_gsKDfsuusOo',
    appId: '1:336837478378:web:35ad116db920568c01d493',
    messagingSenderId: '336837478378',
    projectId: 'brickclub',
    authDomain: 'brickclub.firebaseapp.com',
    storageBucket: 'brickclub.firebasestorage.app',
    measurementId: 'G-Z6E45H9302',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2Ehts3Ogk--0nXH-pvC7qa8gjosLlqoQ',
    appId: '1:336837478378:android:1cffb136f80d5e6001d493',
    messagingSenderId: '336837478378',
    projectId: 'brickclub',
    storageBucket: 'brickclub.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZcyG-h6eL1lCH2wleKhK3Dqhbqy86Mis',
    appId: '1:336837478378:ios:220b86c73c3724ef01d493',
    messagingSenderId: '336837478378',
    projectId: 'brickclub',
    iosBundleId: 'com.example.brickclub',
    storageBucket: 'brickclub.firebasestorage.app',
  );
}
