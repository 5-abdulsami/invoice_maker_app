import 'package:flutter/widgets.dart';

/// Spacing scale. Every gap and padding in the app comes from here.
///
/// The scale is a 4pt grid; [md] is the default gutter between related
/// elements and [gutter] is the screen edge inset.
sealed class Insets {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;

  /// Horizontal inset from the screen edge to content.
  static const double gutter = 16;

  /// Extra bottom padding on scrollables so the last row clears a FAB.
  static const double scrollBottom = 96;
}

/// Corner radii. Larger surfaces get larger radii.
sealed class Radii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// Top-only radius, for bottom sheets.
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}

/// Border widths.
sealed class Strokes {
  static const double hairline = 1;
  static const double thick = 1.5;

  /// Width of the accent rail that marks a selected card.
  static const double accentRail = 3;
}

/// Icon sizes, so icons stay optically consistent with their labels.
sealed class IconSizes {
  static const double xs = 14;
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 28;
  static const double xl = 40;

  /// Large glyph used by empty states.
  static const double illustration = 56;
}

/// Animation durations and curves.
sealed class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}

/// Layout constraints and breakpoints, in logical pixels.
sealed class Layout {
  /// Below this width, two-column rows must collapse to one.
  static const double compactWidth = 360;

  /// At or above this width the layout may use tablet affordances.
  static const double mediumWidth = 600;

  /// At or above this width forms may sit side by side.
  static const double expandedWidth = 900;

  /// Reading width cap for forms and detail screens on large displays.
  static const double readableWidth = 640;

  /// Width cap for list screens on large displays.
  static const double listWidth = 760;

  /// Minimum touch target, per platform accessibility guidance.
  static const double minTapTarget = 48;

  /// Height of the primary action bar pinned to the bottom of forms.
  static const double actionBarHeight = 56;

  /// Aspect ratio of an A4 page (width / height), for page previews.
  static const double pageAspectRatio = 1 / 1.4142;

  /// Largest text scale the layouts are tuned for; beyond this, text is
  /// clamped so fixed-height rows cannot clip their labels.
  static const double maxTextScale = 1.6;
}

/// Fixed-size gap widgets, so layouts never inline a `SizedBox`.
sealed class Gap {
  static const Widget h2 = SizedBox(height: Insets.xxs);
  static const Widget h4 = SizedBox(height: Insets.xs);
  static const Widget h8 = SizedBox(height: Insets.sm);
  static const Widget h12 = SizedBox(height: Insets.md);
  static const Widget h16 = SizedBox(height: Insets.lg);
  static const Widget h20 = SizedBox(height: Insets.xl);
  static const Widget h28 = SizedBox(height: Insets.xxl);
  static const Widget h40 = SizedBox(height: Insets.xxxl);

  static const Widget w4 = SizedBox(width: Insets.xs);
  static const Widget w8 = SizedBox(width: Insets.sm);
  static const Widget w12 = SizedBox(width: Insets.md);
  static const Widget w16 = SizedBox(width: Insets.lg);
  static const Widget w20 = SizedBox(width: Insets.xl);
}
