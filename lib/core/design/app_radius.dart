import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 100;

  static BorderRadius get small =>
      BorderRadius.circular(sm);

  static BorderRadius get medium =>
      BorderRadius.circular(md);

  static BorderRadius get large =>
      BorderRadius.circular(lg);

  static BorderRadius get extraLarge =>
      BorderRadius.circular(xl);
}