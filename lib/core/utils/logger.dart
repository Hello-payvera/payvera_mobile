import 'package:flutter/foundation.dart';

class Logger {
  static void info(Object message) {
    debugPrint("🟢 $message");
  }

  static void warning(Object message) {
    debugPrint("🟡 $message");
  }

  static void error(Object message) {
    debugPrint("🔴 $message");
  }

  static void success(Object message) {
    debugPrint("✅ $message");
  }
}
