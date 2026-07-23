import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (FirebaseConfig.useEmulators) {
    final host = FirebaseConfig.emulatorHost;

    await FirebaseAuth.instance.useAuthEmulator(host, 9099);

    FirebaseFirestore.instance.useFirestoreEmulator(host, 8085);

    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

    debugPrint('==============================');
    debugPrint('PAYVERA DEVELOPMENT MODE');
    debugPrint('Firebase Emulator Host: $host');
    debugPrint('==============================');
  }

  runApp(const PayveraApp());
}

class PayveraApp extends StatelessWidget {
  const PayveraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payvera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
