import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('Configura iOS si vas a compilar para iOS.');
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError('Plataforma no soportada.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCxjdS8wjCQeo-z50-Vfvh5kGvxdXIGkG8',
    appId: '1:262250945867:web:4da3a0994b44a8410f9cce',
    messagingSenderId: '262250945867',
    projectId: 'bochica-55981',
    authDomain: 'bochica-55981.firebaseapp.com',
    storageBucket: 'bochica-55981.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDu1MOcxfGZtrID0zX8BFsZVcG8DEqWVsU',
    appId: '1:262250945867:android:1ce6be573e7f6f040f9cce',
    messagingSenderId: '262250945867',
    projectId: 'bochica-55981',
    storageBucket: 'bochica-55981.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions( 
    apiKey: 'AIzaSyDu1MOcxfGZtrID0zX8BFsZVcG8DEqWVsU',
    appId: '1:262250945867:android:1ce6be573e7f6f040f9cce',
    messagingSenderId: '262250945867',
    projectId: 'bochica-55981',
    storageBucket: 'bochica-55981.firebasestorage.app',
  );
}
