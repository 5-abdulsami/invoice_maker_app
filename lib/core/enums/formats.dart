import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/utils/number_style.dart';

/// Date presentation styles offered in settings.
enum DateFormatOption {
  dayMonthYear('dd/MM/yyyy', '31/12/2026'),
  monthDayYear('MM/dd/yyyy', '12/31/2026'),
  isoDate('yyyy-MM-dd', '2026-12-31'),
  mediumDate('d MMM yyyy', '31 Dec 2026'),
  longDate('MMMM d, yyyy', 'December 31, 2026');

  const DateFormatOption(this.pattern, this.example);

  /// `intl` pattern used to format a date.
  final String pattern;

  /// Sample rendering, shown in the settings picker.
  final String example;

  static const DateFormatOption fallback = DateFormatOption.mediumDate;

  static DateFormatOption fromName(String? name) {
    for (final option in values) {
      if (option.name == name) return option;
    }
    return fallback;
  }
}

/// The number styles offered in settings.
///
/// [automatic] follows each amount's own currency, so one document in rupees
/// and another in euros are each written the way their readers expect. The
/// others force one style everywhere, for users who prefer their own.
enum NumberGroupingOption {
  automatic(null),
  comma(NumberStyle.commaDot),
  dot(NumberStyle.dotComma),
  space(NumberStyle.spaceDot),
  none(NumberStyle.plainDot);

  const NumberGroupingOption(this._style);

  /// The forced style, or null to follow the currency.
  final NumberStyle? _style;

  /// The style an amount in [currency] is written in.
  NumberStyle styleFor(Currency currency) => _style ?? currency.numberStyle;

  /// Shown in settings, e.g. `1,234.56`.
  String get label => switch (_style) {
        null => 'Match currency',
        final style => style.apply('1234.56'),
      };

  static const NumberGroupingOption fallback = NumberGroupingOption.automatic;

  static NumberGroupingOption fromName(String? name) {
    for (final option in values) {
      if (option.name == name) return option;
    }
    return fallback;
  }
}

/// Which theme the user asked for.
enum AppThemeOption {
  system('Match system'),
  light('Light'),
  dark('Dark');

  const AppThemeOption(this.label);

  final String label;

  static const AppThemeOption fallback = AppThemeOption.system;

  static AppThemeOption fromName(String? name) {
    for (final option in values) {
      if (option.name == name) return option;
    }
    return fallback;
  }
}
