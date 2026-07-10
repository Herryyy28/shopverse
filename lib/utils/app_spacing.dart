import 'package:flutter/material.dart';

/// 8dp grid spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(16, 24, 16, 8);
}

/// Consistent border radius constants
class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0;

  static BorderRadius get smBR => BorderRadius.circular(sm);
  static BorderRadius get mdBR => BorderRadius.circular(md);
  static BorderRadius get lgBR => BorderRadius.circular(lg);
  static BorderRadius get xlBR => BorderRadius.circular(xl);
  static BorderRadius get xxlBR => BorderRadius.circular(xxl);
  static BorderRadius get fullBR => BorderRadius.circular(full);
}

/// Pre-built box shadow levels
class AppShadow {
  static List<BoxShadow> get xs => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get sm => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> primary(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
  ];
}
