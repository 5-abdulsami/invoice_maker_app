import 'package:flutter/material.dart';

/// Layout breakpoints, in logical pixels of screen width.
sealed class Breakpoints {
  static const double compact = 360;
  static const double tablet = 600;
  static const double desktop = 1024;
}

/// Screen-size helpers so widgets never reach for raw `MediaQuery` maths.
extension ContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Narrow phones, where two-column rows need to collapse.
  bool get isSmallScreen => screenWidth < Breakpoints.compact;
  bool get isTablet => screenWidth >= Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Picks a value for the current width, falling back to [compact].
  T responsive<T>({required T compact, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return compact;
  }

  /// Caps content width so forms stay readable on tablets.
  double get contentMaxWidth => isTablet ? Breakpoints.tablet : double.infinity;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
  }
}
