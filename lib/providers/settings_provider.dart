import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/app_date_format.dart';
import 'package:invoicemaker/core/enums/app_language.dart';
import 'package:invoicemaker/core/enums/currency.dart';

/// App-wide preferences that seed each new invoice.
///
/// Held in memory only, matching the rest of the app's storage model.
class SettingsProvider extends ChangeNotifier {
  Currency _defaultCurrency = Currency.pkr;
  AppLanguage _language = AppLanguage.english;
  AppDateFormat _dateFormat = AppDateFormat.dayMonthYear;
  AppNumberFormat _numberFormat = AppNumberFormat.comma;
  int _defaultDueTerms = 7;
  bool _showPaidOnInvoice = true;

  Currency get defaultCurrency => _defaultCurrency;
  AppLanguage get language => _language;
  AppDateFormat get dateFormat => _dateFormat;
  AppNumberFormat get numberFormat => _numberFormat;

  /// Days between creation and due date on a new invoice.
  int get defaultDueTerms => _defaultDueTerms;

  /// Whether a paid invoice shows its "paid" marker on the PDF.
  bool get showPaidOnInvoice => _showPaidOnInvoice;

  void setDefaultCurrency(Currency currency) {
    if (_defaultCurrency == currency) return;
    _defaultCurrency = currency;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  void setDateFormat(AppDateFormat format) {
    if (_dateFormat == format) return;
    _dateFormat = format;
    notifyListeners();
  }

  void setNumberFormat(AppNumberFormat format) {
    if (_numberFormat == format) return;
    _numberFormat = format;
    notifyListeners();
  }

  void setDefaultDueTerms(int days) {
    final clamped = days < 0 ? 0 : days;
    if (_defaultDueTerms == clamped) return;
    _defaultDueTerms = clamped;
    notifyListeners();
  }

  void setShowPaidOnInvoice(bool value) {
    if (_showPaidOnInvoice == value) return;
    _showPaidOnInvoice = value;
    notifyListeners();
  }
}
