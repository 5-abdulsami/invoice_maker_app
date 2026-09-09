import 'package:intl/intl.dart';
import 'package:invoicemaker/core/enums/app_date_format.dart';

extension DateExtensions on DateTime {
  /// Default medium date used across lists and PDFs.
  String get formatted => DateFormat('yMMMd').format(this);

  String formattedWith(AppDateFormat format) =>
      DateFormat(format.pattern).format(this);

  /// Same calendar day, ignoring the time component.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get dateOnly => DateTime(year, month, day);

  /// Whole days between two dates, never negative.
  int daysUntil(DateTime other) {
    final difference = other.dateOnly.difference(dateOnly).inDays;
    return difference < 0 ? 0 : difference;
  }
}
