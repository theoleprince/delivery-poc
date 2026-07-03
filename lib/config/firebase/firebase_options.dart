// TODO(firebase): Ce fichier est un PLACEHOLDER. Remplace-le en exécutant
// `flutterfire configure` à la racine du projet une fois un vrai projet
// Firebase créé — voir README.md § "Connecter un vrai projet Firebase".
// Les valeurs ci-dessous ne fonctionneront avec aucun projet réel.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Options de configuration Firebase par plateforme.
///
/// Généré normalement par `flutterfire configure`. Ici, placeholder
/// explicite pour permettre au projet de compiler avant la configuration
/// d'un vrai projet Firebase.
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
          'DefaultFirebaseOptions n\'a pas été configuré pour cette '
          'plateforme. Exécute `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TODO-replace-with-flutterfire-configure',
    appId: 'TODO-replace-with-flutterfire-configure',
    messagingSenderId: 'TODO-replace-with-flutterfire-configure',
    projectId: 'poc-uber-placeholder',
    authDomain: 'poc-uber-placeholder.firebaseapp.com',
    storageBucket: 'poc-uber-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO-replace-with-flutterfire-configure',
    appId: 'TODO-replace-with-flutterfire-configure',
    messagingSenderId: 'TODO-replace-with-flutterfire-configure',
    projectId: 'poc-uber-placeholder',
    storageBucket: 'poc-uber-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO-replace-with-flutterfire-configure',
    appId: 'TODO-replace-with-flutterfire-configure',
    messagingSenderId: 'TODO-replace-with-flutterfire-configure',
    projectId: 'poc-uber-placeholder',
    storageBucket: 'poc-uber-placeholder.appspot.com',
    iosBundleId: 'com.pocuber.pocUber',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO-replace-with-flutterfire-configure',
    appId: 'TODO-replace-with-flutterfire-configure',
    messagingSenderId: 'TODO-replace-with-flutterfire-configure',
    projectId: 'poc-uber-placeholder',
    storageBucket: 'poc-uber-placeholder.appspot.com',
    iosBundleId: 'com.pocuber.pocUber',
  );
}
