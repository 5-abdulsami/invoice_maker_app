import 'package:intl/intl.dart';
import 'package:invoicemaker/core/enums/formats.dart';

extension DateFormatting on DateTime {
  /// The date with the time component dropped.
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDate(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Whole days from this date to [other]; negative when [other] is earlier.
  int daysTo(DateTime other) => other.dateOnly.difference(dateOnly).inDays;

  /// True when this date is strictly before today.
  bool get isBeforeToday => dateOnly.isBefore(DateTime.now().dateOnly);

  /// Formats with the user's chosen pattern, e.g. `31 Dec 2026`.
  String formatWith(DateFormatOption option) =>
      DateFormat(option.pattern).format(this);

  /// A short form for dense rows, e.g. `31 Dec`.
  String get shortDate => DateFormat('d MMM').format(this);

  /// A file-name-safe stamp, e.g. `2026-09-16-1432`.
  String get fileStamp => DateFormat('yyyy-MM-dd-HHmm').format(this);
}

/// Describes a due date in words relative to today.
sealed class DueDateLabel {
  /// e.g. `Due today`, `Due in 7 days`, `12 days overdue`.
  static String describe(DateTime dueDate, {required bool isSettled}) {
    if (isSettled) return 'Settled';

    final days = DateTime.now().daysTo(dueDate);
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    if (days > 1) return 'Due in $days days';

    final overdue = -days;
    return overdue == 1 ? '1 day overdue' : '$overdue days overdue';
  }

  /// e.g. `Valid today`, `Valid for 7 days`, `Expired 3 days ago`.
  static String describeValidity(DateTime validUntil) {
    final days = DateTime.now().daysTo(validUntil);
    if (days == 0) return 'Valid today';
    if (days == 1) return 'Valid until tomorrow';
    if (days > 1) return 'Valid for $days days';

    final expired = -days;
    return expired == 1 ? 'Expired yesterday' : 'Expired $expired days ago';
  }
}
