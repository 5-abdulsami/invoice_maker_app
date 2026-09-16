import 'package:flutter/material.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/app_settings.dart';
import 'package:invoicemaker/data/repositories/settings_repository.dart';

/// Exposes the user's preferences and persists every change.
class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  AppSettings get settings => _repository.settings;

  /// Formatter for the default currency.
  MoneyFormat get moneyFormat => settings.moneyFormat;

  /// Formatter for a document that may use a different currency.
  MoneyFormat moneyFormatFor(Currency currency) =>
      settings.moneyFormatFor(currency);

  DateFormatOption get dateFormat => settings.dateFormat;

  ThemeMode get themeMode => switch (settings.themeOption) {
        AppThemeOption.system => ThemeMode.system,
        AppThemeOption.light => ThemeMode.light,
        AppThemeOption.dark => ThemeMode.dark,
      };

  /// Whether the first-run introduction still needs showing.
  bool get shouldShowWelcome => !settings.hasSeenWelcome;

  Future<void> setTheme(AppThemeOption option) =>
      _update(settings.copyWith(themeOption: option));

  Future<void> setDefaultCurrency(Currency currency) =>
      _update(settings.copyWith(defaultCurrency: currency));

  Future<void> setDefaultTemplate(InvoiceTemplate template) =>
      _update(settings.copyWith(defaultTemplate: template));

  Future<void> setDateFormat(DateFormatOption option) =>
      _update(settings.copyWith(dateFormat: option));

  Future<void> setNumberGrouping(NumberGroupingOption option) =>
      _update(settings.copyWith(numberGrouping: option));

  Future<void> setDefaultTax({required String label, required double percent}) =>
      _update(
        settings.copyWith(defaultTaxLabel: label, defaultTaxPercent: percent),
      );

  Future<void> setDefaultTermDays(int days) =>
      _update(settings.copyWith(defaultTermDays: days < 0 ? 0 : days));

  Future<void> setDefaultPaymentTerms(String terms) =>
      _update(settings.copyWith(defaultPaymentTerms: terms));

  Future<void> setDefaultPaymentDetails(String details) =>
      _update(settings.copyWith(defaultPaymentDetails: details));

  Future<void> setDefaultNotes(String notes) =>
      _update(settings.copyWith(defaultNotes: notes));

  Future<void> setNumbering({
    String? invoicePrefix,
    String? estimatePrefix,
    int? padding,
    int? nextInvoiceSequence,
    int? nextEstimateSequence,
  }) {
    return _update(
      settings.copyWith(
        invoicePrefix: invoicePrefix,
        estimatePrefix: estimatePrefix,
        numberPadding: padding,
        nextInvoiceSequence: nextInvoiceSequence,
        nextEstimateSequence: nextEstimateSequence,
      ),
    );
  }

  Future<void> markWelcomeSeen() {
    if (settings.hasSeenWelcome) return Future.value();
    return _update(settings.copyWith(hasSeenWelcome: true));
  }

  /// Moves the numbering sequence past [sequence] once it has been used.
  Future<void> advanceSequence(DocumentKind kind, int sequence) {
    if (sequence < settings.sequenceFor(kind)) return Future.value();
    return _update(settings.withSequenceAdvanced(kind, sequence));
  }

  /// Re-reads the repository after a restore replaced the stored settings.
  void refresh() => notifyListeners();

  Future<void> _update(AppSettings updated) async {
    await _repository.save(updated);
    notifyListeners();
  }
}
