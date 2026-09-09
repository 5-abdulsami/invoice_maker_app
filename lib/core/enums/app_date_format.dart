/// Date presentation styles offered in settings.
enum AppDateFormat {
  dayMonthYear('dd/MM/yyyy', '31/12/2024'),
  monthDayYear('MM/dd/yyyy', '12/31/2024'),
  yearMonthDay('yyyy-MM-dd', '2024-12-31'),
  mediumDate('yMMMd', 'Dec 31, 2024');

  const AppDateFormat(this.pattern, this.example);

  final String pattern;
  final String example;
}

/// Thousands-separator styles offered in settings.
enum AppNumberFormat {
  comma('1,000,000', ',', '.'),
  dot('1.000.000', '.', ','),
  space('1 000 000', ' ', '.');

  const AppNumberFormat(this.example, this.groupSeparator, this.decimalSeparator);

  final String example;
  final String groupSeparator;
  final String decimalSeparator;
}
