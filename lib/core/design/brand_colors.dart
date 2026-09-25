import 'package:flutter/painting.dart';

/// Brand colours that sit outside the light and dark themes.
///
/// The splash is the brand's moment, so it looks the same in both modes and
/// matches the app icon's teal rather than the theme canvas.
sealed class BrandColors {
  /// Deep teal behind the launch logo.
  ///
  /// Must equal `splash_background` in
  /// `android/app/src/main/res/values/colors.xml`: the native launch screen
  /// and the Flutter splash then meet without a visible seam.
  static const Color splashBackground = Color(0xFF0B4E53);

  /// Lighter teal glowing behind the logo as the splash settles.
  static const Color splashGlow = Color(0xFF1E8C92);

  static const Color onSplash = Color(0xFFFFFFFF);
  static const Color onSplashMuted = Color(0xB3FFFFFF);
}
