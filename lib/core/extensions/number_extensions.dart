import 'package:intl/intl.dart';
import 'package:invoicemaker/core/enums/app_date_format.dart';
import 'package:invoicemaker/core/enums/currency.dart';

extension NumberExtensions on num {
  /// `Rs1200` — the whole-unit form used throughout the UI and PDFs.
  String asCurrency(Currency currency) =>
      '${currency.symbol}${toStringAsFixed(0)}';

  /// Currency with grouped digits, e.g. `Rs1,200`.
  String asGroupedCurrency(Currency currency, AppNumberFormat format) =>
      '${currency.symbol}${grouped(format)}';

  String grouped(AppNumberFormat format) {
    final formatted = NumberFormat('#,##0').format(this);
    return format == AppNumberFormat.comma
        ? formatted
        : formatted.replaceAll(',', format.groupSeparator);
  }

  /// `12%` — percentages are always shown without decimals.
  String get asPercent => '${toStringAsFixed(0)}%';
}
