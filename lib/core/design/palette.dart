import 'package:flutter/material.dart';

/// Semantic colour roles for the app, resolved per theme brightness.
///
/// Widgets read roles (`palette.textSecondary`) rather than raw colours, so
/// light and dark mode stay in step and no colour is declared inline.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.onPrimary,
    required this.primarySurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.onInverse,
    required this.inverseSurface,
    required this.success,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.danger,
    required this.dangerSurface,
    required this.neutralStatus,
    required this.neutralStatusSurface,
    required this.overlay,
    required this.shadow,
  });

  final Brightness brightness;

  /// Page background behind all content.
  final Color canvas;

  /// Default card and sheet background.
  final Color surface;

  /// Recessed background for read-only rows and table headers.
  final Color surfaceMuted;

  /// Background for a surface that sits above another surface.
  final Color surfaceRaised;

  final Color border;
  final Color borderStrong;

  final Color primary;
  final Color onPrimary;

  /// Tinted background for selected states and primary-tinted chips.
  final Color primarySurface;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Text drawn on [inverseSurface].
  final Color onInverse;

  /// High-contrast surface used by the totals block and snackbars.
  final Color inverseSurface;

  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color danger;
  final Color dangerSurface;

  /// Status colour for a neutral state such as "unpaid" or "draft".
  final Color neutralStatus;
  final Color neutralStatusSurface;

  /// Scrim behind modals and loading overlays.
  final Color overlay;
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  /// Light theme roles.
  ///
  /// The identity is a deep teal primary on warm neutral paper, with status
  /// colours kept clearly distinct from the primary so a "paid" badge never
  /// reads as a branded element.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF6F6F4),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1F1EE),
    surfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE3E3DE),
    borderStrong: Color(0xFFC9C9C2),
    primary: Color(0xFF0E6F76),
    onPrimary: Color(0xFFFFFFFF),
    primarySurface: Color(0xFFE2F1F2),
    textPrimary: Color(0xFF17201F),
    textSecondary: Color(0xFF5B6664),
    textTertiary: Color(0xFF8A9491),
    onInverse: Color(0xFFF4F7F6),
    inverseSurface: Color(0xFF1B2523),
    success: Color(0xFF1A7F4B),
    successSurface: Color(0xFFE2F3E9),
    warning: Color(0xFF9A5B00),
    warningSurface: Color(0xFFFBEEDB),
    danger: Color(0xFFB3261E),
    dangerSurface: Color(0xFFFBE7E5),
    neutralStatus: Color(0xFF5B6664),
    neutralStatusSurface: Color(0xFFEBEBE7),
    overlay: Color(0x8A17201F),
    shadow: Color(0x1417201F),
  );

  /// Dark theme roles, tuned for contrast rather than a simple inversion.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF121716),
    surface: Color(0xFF1B2220),
    surfaceMuted: Color(0xFF232B29),
    surfaceRaised: Color(0xFF263030),
    border: Color(0xFF313B39),
    borderStrong: Color(0xFF465250),
    primary: Color(0xFF64CFD3),
    onPrimary: Color(0xFF00312F),
    primarySurface: Color(0xFF1C3634),
    textPrimary: Color(0xFFF0F3F2),
    textSecondary: Color(0xFFB2BDBA),
    textTertiary: Color(0xFF859390),
    onInverse: Color(0xFF17201F),
    inverseSurface: Color(0xFFE8EDEB),
    success: Color(0xFF6BD397),
    successSurface: Color(0xFF17352A),
    warning: Color(0xFFE5B168),
    warningSurface: Color(0xFF3A2C15),
    danger: Color(0xFFF2938C),
    dangerSurface: Color(0xFF3D211F),
    neutralStatus: Color(0xFFB2BDBA),
    neutralStatusSurface: Color(0xFF2A3331),
    overlay: Color(0xA6000000),
    shadow: Color(0x33000000),
  );

  /// Background and foreground pair for a status badge.
  ({Color background, Color foreground}) statusColors(AppStatusTone tone) {
    return switch (tone) {
      AppStatusTone.neutral => (
          background: neutralStatusSurface,
          foreground: neutralStatus,
        ),
      AppStatusTone.positive => (
          background: successSurface,
          foreground: success,
        ),
      AppStatusTone.caution => (
          background: warningSurface,
          foreground: warning,
        ),
      AppStatusTone.critical => (
          background: dangerSurface,
          foreground: danger,
        ),
      AppStatusTone.accent => (
          background: primarySurface,
          foreground: primary,
        ),
    };
  }

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceRaised,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? onPrimary,
    Color? primarySurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? onInverse,
    Color? inverseSurface,
    Color? success,
    Color? successSurface,
    Color? warning,
    Color? warningSurface,
    Color? danger,
    Color? dangerSurface,
    Color? neutralStatus,
    Color? neutralStatusSurface,
    Color? overlay,
    Color? shadow,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySurface: primarySurface ?? this.primarySurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      onInverse: onInverse ?? this.onInverse,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      danger: danger ?? this.danger,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      neutralStatus: neutralStatus ?? this.neutralStatus,
      neutralStatusSurface: neutralStatusSurface ?? this.neutralStatusSurface,
      overlay: overlay ?? this.overlay,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      primarySurface: mix(primarySurface, other.primarySurface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      onInverse: mix(onInverse, other.onInverse),
      inverseSurface: mix(inverseSurface, other.inverseSurface),
      success: mix(success, other.success),
      successSurface: mix(successSurface, other.successSurface),
      warning: mix(warning, other.warning),
      warningSurface: mix(warningSurface, other.warningSurface),
      danger: mix(danger, other.danger),
      dangerSurface: mix(dangerSurface, other.dangerSurface),
      neutralStatus: mix(neutralStatus, other.neutralStatus),
      neutralStatusSurface: mix(
        neutralStatusSurface,
        other.neutralStatusSurface,
      ),
      overlay: mix(overlay, other.overlay),
      shadow: mix(shadow, other.shadow),
    );
  }
}

/// How a status should read to the user, independent of its label.
enum AppStatusTone { neutral, positive, caution, critical, accent }
