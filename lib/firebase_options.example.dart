
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Example Firebase configuration.
///
/// To use this project, create your own Firebase app
/// and replace these placeholder values with your own.
/// Never copy your real configuration into this example file.
class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'Firebase options for this platform are not configured.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PASTE_YOUR_API_KEY_HERE',
    appId: 'PASTE_YOUR_APP_ID_HERE',
    messagingSenderId: 'PASTE_YOUR_MESSAGING_SENDER_ID_HERE',
    projectId: 'PASTE_YOUR_PROJECT_ID_HERE',
    authDomain: 'PASTE_YOUR_AUTH_DOMAIN_HERE',
  );
}