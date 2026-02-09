import 'package:flutter/material.dart';

class Ui {
  // Spacing scale (8-pt system)
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;


  // Radii
  static const double r14 = 14;
    static const double r16 = 16;
  static const double r18 = 18;
  static const double r22 = 22;
  static const double r28 = 28;

  // Page padding
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: s16);

  // Subtle border (instead of heavy shadows)
  static Border subtleBorder(ColorScheme cs) => Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.45),
        width: 1,
      );
}
