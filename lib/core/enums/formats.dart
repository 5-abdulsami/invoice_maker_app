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

/// Digit grouping styles offered in settings.
enum NumberGroupingOption {
  comma('1,234.56', ',', '.'),
  dot('1.234,56', '.', ','),
  space('1 234.56', ' ', '.'),
  none('1234.56', '', '.');

  const NumberGroupingOption(
    this.example,
    this.groupSeparator,
    this.decimalSeparator,
  );

  final String example;

  /// Thousands separator; empty when digits are not grouped.
  final String groupSeparator;

  final String decimalSeparator;

  static const NumberGroupingOption fallback = NumberGroupingOption.comma;

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
