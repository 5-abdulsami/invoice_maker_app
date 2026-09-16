import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/formats.dart';

/// Rounding and formatting of money amounts.
///
/// Amounts are held as doubles but every arithmetic result is rounded to the
/// currency's minor units before it is stored or compared, so a total never
/// drifts by a fraction of a cent.
sealed class Money {
  /// Rounds [value] to [decimalDigits].
  ///
  /// Goes through the decimal string form rather than multiplying by a power
  /// of ten, which avoids the drift multiplication introduces. A halfway
  /// value rounds away from zero when it is exactly representable, so 2.5
  /// becomes 3; a literal such as 1.005 is stored as slightly less than that
  /// and rounds down to match the value actually held.
  static double round(double value, int decimalDigits) {
    if (!value.isFinite) return 0;
    return double.parse(value.toStringAsFixed(decimalDigits));
  }

  /// Rounds [value] to the minor units of [currency].
  static double roundFor(double value, Currency currency) =>
      round(value, currency.decimalDigits);

  /// Clamps [value] into `0..max`, guarding against NaN.
  static double clampPositive(double value, {double? max}) {
    if (!value.isFinite || value < 0) return 0;
    if (max != null && value > max) return max;
    return value;
  }
}

/// Formats amounts and percentages using the user's chosen separators.
///
/// Separators come from settings rather than the device locale so the numbers
/// on screen always match the numbers printed on the PDF.
class MoneyFormat {
  const MoneyFormat({required this.currency, required this.grouping});

  /// A default used before settings have loaded.
  const MoneyFormat.fallback()
      : currency = Currency.fallback,
        grouping = NumberGroupingOption.comma;

  final Currency currency;
  final NumberGroupingOption grouping;

  /// `$1,234.56` — the standard form used across the app and the PDFs.
  String format(num value, {bool withSymbol = true}) {
    final digits = _digits(value.toDouble(), currency.decimalDigits);
    if (!withSymbol) return digits;
    return currency.symbolNeedsSpace
        ? '${currency.symbol} $digits'
        : '${currency.symbol}$digits';
  }

  /// `-$40.00` — a deduction, with the sign before the symbol.
  String formatNegated(num value) {
    if (value == 0) return format(0);
    return '-${format(value.abs())}';
  }

  /// `12.5%`, with no trailing zeros.
  String percent(num value) {
    final rounded = Money.round(value.toDouble(), _percentDigits);
    final text = rounded
        .toStringAsFixed(_percentDigits)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$text%';
  }

  /// The digits only, grouped and with the decimal separator applied.
  String _digits(double value, int decimalDigits) {
    final rounded = Money.round(value, decimalDigits);
    final isNegative = rounded < 0;
    final fixed = rounded.abs().toStringAsFixed(decimalDigits);

    final parts = fixed.split('.');
    final grouped = _group(parts.first);
    final body = parts.length > 1
        ? '$grouped${grouping.decimalSeparator}${parts[1]}'
        : grouped;

    return isNegative ? '-$body' : body;
  }

  /// Inserts the group separator every three digits from the right.
  String _group(String integerDigits) {
    final separator = grouping.groupSeparator;
    if (separator.isEmpty || integerDigits.length < 4) return integerDigits;

    final buffer = StringBuffer();
    final firstGroup = integerDigits.length % 3;
    if (firstGroup > 0) buffer.write(integerDigits.substring(0, firstGroup));

    for (var i = firstGroup; i < integerDigits.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(separator);
      buffer.write(integerDigits.substring(i, i + 3));
    }
    return buffer.toString();
  }

  static const int _percentDigits = 2;

  MoneyFormat copyWith({
    Currency? currency,
    NumberGroupingOption? grouping,
  }) {
    return MoneyFormat(
      currency: currency ?? this.currency,
      grouping: grouping ?? this.grouping,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyFormat &&
      other.currency == currency &&
      other.grouping == grouping;

  @override
  int get hashCode => Object.hash(currency, grouping);
}
