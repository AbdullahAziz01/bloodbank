// File generated from google-services.json configuration
// Project: bloodbank-a266d

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCGrDvvsFiKenm7pMTblGr_CoOAw0Am94c',
    appId: '1:390883439930:web:PLACEHOLDER',
    messagingSenderId: '390883439930',
    projectId: 'bloodbank-a266d',
    authDomain: 'bloodbank-a266d.firebaseapp.com',
    storageBucket: 'bloodbank-a266d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGrDvvsFiKenm7pMTblGr_CoOAw0Am94c',
    appId: '1:390883439930:android:967fa6278595bd0e1b0c03',
    messagingSenderId: '390883439930',
    projectId: 'bloodbank-a266d',
    storageBucket: 'bloodbank-a266d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGrDvvsFiKenm7pMTblGr_CoOAw0Am94c',
    appId: '1:390883439930:ios:PLACEHOLDER',
    messagingSenderId: '390883439930',
    projectId: 'bloodbank-a266d',
    storageBucket: 'bloodbank-a266d.firebasestorage.app',
    iosBundleId: 'com.example.bloodbank',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCGrDvvsFiKenm7pMTblGr_CoOAw0Am94c',
    appId: '1:390883439930:ios:PLACEHOLDER',
    messagingSenderId: '390883439930',
    projectId: 'bloodbank-a266d',
    storageBucket: 'bloodbank-a266d.firebasestorage.app',
    iosBundleId: 'com.example.bloodbank',
  );
}
