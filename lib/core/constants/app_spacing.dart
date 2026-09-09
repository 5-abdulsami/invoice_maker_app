import 'package:flutter/widgets.dart';

/// Spacing scale. Use these instead of ad-hoc numbers.
sealed class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screen = EdgeInsets.all(md);
  static const EdgeInsets card = EdgeInsets.all(md);

  /// Fills the available width inside an AlertDialog.
  static const double dialogWidth = double.maxFinite;

  /// Radius shared by cards, fields and chips.
  static const double radius = 10;
  static const double radiusSm = 7;
}

/// Vertical gaps, used to avoid repeating `SizedBox(height: ...)`.
sealed class Gap {
  static const Widget xs = SizedBox(height: AppSpacing.xs);
  static const Widget sm = SizedBox(height: AppSpacing.sm);
  static const Widget md = SizedBox(height: AppSpacing.md);
  static const Widget lg = SizedBox(height: AppSpacing.lg);
  static const Widget xl = SizedBox(height: AppSpacing.xl);

  static const Widget wSm = SizedBox(width: AppSpacing.sm);
  static const Widget wMd = SizedBox(width: AppSpacing.md);
  static const Widget wLg = SizedBox(width: AppSpacing.lg);
}
