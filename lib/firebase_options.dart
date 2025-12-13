import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// **Nombre de la Clase: `firebase_options`**
///
/// **Descripción:** configuraciones de Firebase
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Gonzalo Alganza Luque
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se han hecho cambios de calidad
///


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    FirebaseOptions tipo;
    if (kIsWeb) {
      tipo = web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        tipo = android;
      case TargetPlatform.iOS:
        tipo = ios;
      case TargetPlatform.macOS:
        tipo = macos;
      case TargetPlatform.windows:
        tipo = windows;
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

    return tipo;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAk21WWgQ3DPLCdMxzGZTvS8Ejje0NKz2Y',
    appId: '1:933384322793:web:1f70e570f4bb03f444ba78',
    messagingSenderId: '933384322793',
    projectId: 'tato-matematico',
    authDomain: 'tato-matematico.firebaseapp.com',
    databaseURL: 'https://tato-matematico-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tato-matematico.firebasestorage.app',
    measurementId: 'G-HM67MQZPL4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkjqPd3tVQRWPtalMzLBH74K6KTHeKbhI',
    appId: '1:933384322793:android:6c8db878af981abb44ba78',
    messagingSenderId: '933384322793',
    projectId: 'tato-matematico',
    databaseURL: 'https://tato-matematico-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tato-matematico.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-lroHiyxjJ9tikoMvtV3bMPI0RW5zzOk',
    appId: '1:933384322793:ios:79427cac0ed5c27244ba78',
    messagingSenderId: '933384322793',
    projectId: 'tato-matematico',
    databaseURL: 'https://tato-matematico-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tato-matematico.firebasestorage.app',
    iosBundleId: 'com.example.tatoMatematico',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-lroHiyxjJ9tikoMvtV3bMPI0RW5zzOk',
    appId: '1:933384322793:ios:79427cac0ed5c27244ba78',
    messagingSenderId: '933384322793',
    projectId: 'tato-matematico',
    databaseURL: 'https://tato-matematico-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tato-matematico.firebasestorage.app',
    iosBundleId: 'com.example.tatoMatematico',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAk21WWgQ3DPLCdMxzGZTvS8Ejje0NKz2Y',
    appId: '1:933384322793:web:24e36e8ed65ca47644ba78',
    messagingSenderId: '933384322793',
    projectId: 'tato-matematico',
    authDomain: 'tato-matematico.firebaseapp.com',
    databaseURL: 'https://tato-matematico-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tato-matematico.firebasestorage.app',
    measurementId: 'G-97KDXQ53P1',
  );

}