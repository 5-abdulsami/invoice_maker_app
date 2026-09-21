import 'package:flutter/material.dart';

/// The app's scroll behaviour.
///
/// Material 3's stretch overscroll effect calls setState from inside layout
/// when a scroll view resizes mid-drag, which happens whenever a sheet lifts
/// above the keyboard, and fails with "Build scheduled during frame". The glow
/// effect repaints through a notifier instead, so it is used everywhere.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          axisDirection: details.direction,
          color: Theme.of(context).colorScheme.primary,
          child: child,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
    }
  }
}
