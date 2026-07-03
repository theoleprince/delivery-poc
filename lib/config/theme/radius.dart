import 'package:flutter/material.dart';

/// Échelle de rayons de bordure du Design System.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double full = 999;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
}
