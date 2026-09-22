import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/utils/number_style.dart';

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

/// Formats amounts and percentages.
///
/// Separators follow the currency's own convention unless the user forces a
/// style in settings. They never come from the device locale, so the numbers
/// on screen always match the numbers printed on the PDF.
class MoneyFormat {
  const MoneyFormat({required this.currency, required this.grouping});

  /// A default used before settings have loaded.
  const MoneyFormat.fallback()
      : currency = Currency.fallback,
        grouping = NumberGroupingOption.fallback;

  final Currency currency;
  final NumberGroupingOption grouping;

  /// `$1,234.56` — the standard form used across the app and the PDFs.
  ///
  /// A negative amount carries its sign before the symbol: `-$40.00`.
  String format(num value, {bool withSymbol = true}) {
    final rounded = Money.round(value.toDouble(), currency.decimalDigits);
    final digits =
        style.apply(rounded.abs().toStringAsFixed(currency.decimalDigits));
    final sign = rounded < 0 ? '-' : '';

    if (!withSymbol) return '$sign$digits';
    return currency.symbolNeedsSpace
        ? '$sign${currency.symbol} $digits'
        : '$sign${currency.symbol}$digits';
  }

  /// `-$40.00` — a deduction, whatever the sign of [value].
  String formatNegated(num value) => format(-value.abs());

  /// `12.5%`, with no trailing zeros and the style's decimal separator.
  String percent(num value) {
    final rounded = Money.round(value.toDouble(), _percentDigits);
    final text = rounded
        .toStringAsFixed(_percentDigits)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '${style.apply(text)}%';
  }

  /// The separators amounts in [currency] are written with.
  NumberStyle get style => grouping.styleFor(currency);

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
