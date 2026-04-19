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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-key',
    appId: '1:000000000000:web:demo',
    messagingSenderId: '000000000000',
    projectId: 'groundwater-demo',
    authDomain: 'groundwater-demo.firebaseapp.com',
    storageBucket: 'groundwater-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-key',
    appId: '1:000000000000:android:demo',
    messagingSenderId: '000000000000',
    projectId: 'groundwater-demo',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-key',
    appId: '1:000000000000:ios:demo',
    messagingSenderId: '000000000000',
    projectId: 'groundwater-demo',
    iosBundleId: 'com.example.groundwater',
  );
}
