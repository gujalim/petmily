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
    apiKey: 'AIzaSyDIte1HDNc3030nYNUBSE79uEqz48u5jCI',
    appId: '1:184434000180:web:35bbf4569ef170adeee561',
    messagingSenderId: '184434000180',
    projectId: 'petmily-app',
    authDomain: 'petmily-app.firebaseapp.com',
    storageBucket: 'petmily-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIte1HDNc3030nYNUBSE79uEqz48u5jCI',
    appId: '1:184434000180:android:35bbf4569ef170adeee561',
    messagingSenderId: '184434000180',
    projectId: 'petmily-app',
    storageBucket: 'petmily-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIte1HDNc3030nYNUBSE79uEqz48u5jCI',
    appId: '1:184434000180:ios:35bbf4569ef170adeee561',
    messagingSenderId: '184434000180',
    projectId: 'petmily-app',
    storageBucket: 'petmily-app.firebasestorage.app',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.petmily',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDIte1HDNc3030nYNUBSE79uEqz48u5jCI',
    appId: '1:184434000180:macos:35bbf4569ef170adeee561',
    messagingSenderId: '184434000180',
    projectId: 'petmily-app',
    storageBucket: 'petmily-app.firebasestorage.app',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.petmily',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDIte1HDNc3030nYNUBSE79uEqz48u5jCI',
    appId: '1:184434000180:windows:35bbf4569ef170adeee561',
    messagingSenderId: '184434000180',
    projectId: 'petmily-app',
    storageBucket: 'petmily-app.firebasestorage.app',
  );
} 