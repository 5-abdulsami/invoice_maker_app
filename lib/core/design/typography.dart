import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/palette.dart';

/// The bundled typefaces.
sealed class AppFonts {
  /// Body and UI text.
  static const String sans = 'AppSans';

  /// Narrower companion, used for amounts, document numbers and headings that
  /// must hold long values without shrinking.
  static const String narrow = 'AppSansNarrow';
}

/// Builds the app's type scale.
///
/// Numerals use tabular figures so money columns align down a list and a
/// changing total does not shift the digits beside it.
sealed class AppTypography {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(AppPalette palette) {
    final primary = palette.textPrimary;
    final secondary = palette.textSecondary;

    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: AppFonts.narrow,
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 17,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: palette.textTertiary,
      ),
    );
  }

  /// Roles the Material text theme has no slot for.
  static AppTextRoles roles(AppPalette palette) {
    return AppTextRoles(
      amountHero: TextStyle(
        fontFamily: AppFonts.narrow,
        fontSize: 34,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFeatures: _tabular,
        color: palette.textPrimary,
      ),
      amountLarge: TextStyle(
        fontFamily: AppFonts.narrow,
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
        color: palette.textPrimary,
      ),
      amountMedium: TextStyle(
        fontFamily: AppFonts.narrow,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
        color: palette.textPrimary,
      ),
      amountSmall: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w500,
        fontFeatures: _tabular,
        color: palette.textSecondary,
      ),
      documentNumber: TextStyle(
        fontFamily: AppFonts.narrow,
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        fontFeatures: _tabular,
        color: palette.textPrimary,
      ),
      overline: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
        color: palette.textTertiary,
      ),
    );
  }
}

/// Extra text styles exposed through the theme.
@immutable
class AppTextRoles extends ThemeExtension<AppTextRoles> {
  const AppTextRoles({
    required this.amountHero,
    required this.amountLarge,
    required this.amountMedium,
    required this.amountSmall,
    required this.documentNumber,
    required this.overline,
  });

  /// The single headline figure on a detail screen.
  final TextStyle amountHero;

  /// Totals on cards and summary tiles.
  final TextStyle amountLarge;

  /// Row totals in a list.
  final TextStyle amountMedium;

  /// Secondary figures, such as a unit price.
  final TextStyle amountSmall;

  /// Monospaced-feeling document reference, e.g. `INV-0007`.
  final TextStyle documentNumber;

  /// Small all-caps section label.
  final TextStyle overline;

  @override
  AppTextRoles copyWith({
    TextStyle? amountHero,
    TextStyle? amountLarge,
    TextStyle? amountMedium,
    TextStyle? amountSmall,
    TextStyle? documentNumber,
    TextStyle? overline,
  }) {
    return AppTextRoles(
      amountHero: amountHero ?? this.amountHero,
      amountLarge: amountLarge ?? this.amountLarge,
      amountMedium: amountMedium ?? this.amountMedium,
      amountSmall: amountSmall ?? this.amountSmall,
      documentNumber: documentNumber ?? this.documentNumber,
      overline: overline ?? this.overline,
    );
  }

  @override
  AppTextRoles lerp(AppTextRoles? other, double t) {
    if (other == null) return this;
    return AppTextRoles(
      amountHero: TextStyle.lerp(amountHero, other.amountHero, t)!,
      amountLarge: TextStyle.lerp(amountLarge, other.amountLarge, t)!,
      amountMedium: TextStyle.lerp(amountMedium, other.amountMedium, t)!,
      amountSmall: TextStyle.lerp(amountSmall, other.amountSmall, t)!,
      documentNumber: TextStyle.lerp(
        documentNumber,
        other.documentNumber,
        t,
      )!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}
