import 'dart:io';

import 'app_environment.dart';

class FirebaseConfig {
  static const AppEnvironment environment = AppEnvironment.development;

  static const String physicalDeviceIP = '192.168.1.5';

  static bool get useEmulators => environment == AppEnvironment.development;

  static String get emulatorHost {
    if (Platform.isAndroid) {
      return physicalDeviceIP;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      return "localhost";
    }

    return "localhost";
  }
}
