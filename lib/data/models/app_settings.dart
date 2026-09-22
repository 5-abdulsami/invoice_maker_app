import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/json_read.dart';

/// User preferences and the defaults applied to each new document.
@immutable
class AppSettings {
  const AppSettings({
    this.defaultCurrency = Currency.fallback,
    this.defaultTemplate = InvoiceTemplate.fallback,
    this.dateFormat = DateFormatOption.fallback,
    this.numberGrouping = NumberGroupingOption.fallback,
    this.themeOption = AppThemeOption.fallback,
    this.defaultTaxLabel = '',
    this.defaultTaxPercent = 0,
    this.defaultTermDays = 14,
    this.defaultPaymentTerms = '',
    this.defaultPaymentDetails = '',
    this.defaultNotes = '',
    this.invoicePrefix = 'INV',
    this.estimatePrefix = 'EST',
    this.numberPadding = 4,
    this.nextInvoiceSequence = 1,
    this.nextEstimateSequence = 1,
    this.hasSeenWelcome = false,
  });

  static const AppSettings defaults = AppSettings();

  final Currency defaultCurrency;
  final InvoiceTemplate defaultTemplate;
  final DateFormatOption dateFormat;
  final NumberGroupingOption numberGrouping;
  final AppThemeOption themeOption;

  /// Tax name applied to a new document, e.g. `VAT`.
  final String defaultTaxLabel;

  /// Tax rate applied to a new document.
  final double defaultTaxPercent;

  /// Days between the issue date and the due date on a new document.
  final int defaultTermDays;

  final String defaultPaymentTerms;
  final String defaultPaymentDetails;
  final String defaultNotes;

  /// Prefix for generated invoice numbers.
  final String invoicePrefix;

  /// Prefix for generated estimate numbers.
  final String estimatePrefix;

  /// How many digits a generated sequence is padded to, e.g. 4 gives `0007`.
  final int numberPadding;

  /// Sequence the next generated invoice number will use.
  final int nextInvoiceSequence;

  /// Sequence the next generated estimate number will use.
  final int nextEstimateSequence;

  /// Whether the first-run introduction has been shown.
  final bool hasSeenWelcome;

  /// How money is rendered across the app and the PDFs.
  MoneyFormat get moneyFormat =>
      MoneyFormat(currency: defaultCurrency, grouping: numberGrouping);

  /// A money formatter for a document that may use another currency.
  MoneyFormat moneyFormatFor(Currency currency) =>
      MoneyFormat(currency: currency, grouping: numberGrouping);

  String prefixFor(DocumentKind kind) =>
      kind.isInvoice ? invoicePrefix : estimatePrefix;

  int sequenceFor(DocumentKind kind) =>
      kind.isInvoice ? nextInvoiceSequence : nextEstimateSequence;

  /// Formats [sequence] as a document number, e.g. `INV-0007`.
  String formatNumber(DocumentKind kind, int sequence) {
    final prefix = prefixFor(kind).trim();
    final digits = sequence.toString().padLeft(numberPadding.clamp(1, 10), '0');
    return prefix.isEmpty ? digits : '$prefix-$digits';
  }

  /// The settings with the sequence for [kind] advanced past [sequence].
  AppSettings withSequenceAdvanced(DocumentKind kind, int sequence) {
    final next = sequence + 1;
    return kind.isInvoice
        ? copyWith(nextInvoiceSequence: next)
        : copyWith(nextEstimateSequence: next);
  }

  AppSettings copyWith({
    Currency? defaultCurrency,
    InvoiceTemplate? defaultTemplate,
    DateFormatOption? dateFormat,
    NumberGroupingOption? numberGrouping,
    AppThemeOption? themeOption,
    String? defaultTaxLabel,
    double? defaultTaxPercent,
    int? defaultTermDays,
    String? defaultPaymentTerms,
    String? defaultPaymentDetails,
    String? defaultNotes,
    String? invoicePrefix,
    String? estimatePrefix,
    int? numberPadding,
    int? nextInvoiceSequence,
    int? nextEstimateSequence,
    bool? hasSeenWelcome,
  }) {
    return AppSettings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultTemplate: defaultTemplate ?? this.defaultTemplate,
      dateFormat: dateFormat ?? this.dateFormat,
      numberGrouping: numberGrouping ?? this.numberGrouping,
      themeOption: themeOption ?? this.themeOption,
      defaultTaxLabel: defaultTaxLabel ?? this.defaultTaxLabel,
      defaultTaxPercent: defaultTaxPercent ?? this.defaultTaxPercent,
      defaultTermDays: defaultTermDays ?? this.defaultTermDays,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      defaultPaymentDetails:
          defaultPaymentDetails ?? this.defaultPaymentDetails,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      estimatePrefix: estimatePrefix ?? this.estimatePrefix,
      numberPadding: numberPadding ?? this.numberPadding,
      nextInvoiceSequence: nextInvoiceSequence ?? this.nextInvoiceSequence,
      nextEstimateSequence: nextEstimateSequence ?? this.nextEstimateSequence,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
    );
  }

  factory AppSettings.fromJson(JsonMap json) {
    return AppSettings(
      defaultCurrency: Currency.fromCode(Json.string(json, 'defaultCurrency')),
      defaultTemplate: InvoiceTemplate.fromName(
        Json.string(json, 'defaultTemplate'),
      ),
      dateFormat: DateFormatOption.fromName(Json.string(json, 'dateFormat')),
      // Read from a new key: the old one held a single style forced on every
      // currency, so earlier installs start on "Match currency" instead.
      numberGrouping: NumberGroupingOption.fromName(
        Json.string(json, _numberFormatKey),
      ),
      themeOption: AppThemeOption.fromName(Json.string(json, 'themeOption')),
      defaultTaxLabel: Json.string(json, 'defaultTaxLabel'),
      defaultTaxPercent: Json.number(json, 'defaultTaxPercent'),
      defaultTermDays: Json.integer(json, 'defaultTermDays', or: 14),
      defaultPaymentTerms: Json.string(json, 'defaultPaymentTerms'),
      defaultPaymentDetails: Json.string(json, 'defaultPaymentDetails'),
      defaultNotes: Json.string(json, 'defaultNotes'),
      invoicePrefix: Json.string(json, 'invoicePrefix', or: 'INV'),
      estimatePrefix: Json.string(json, 'estimatePrefix', or: 'EST'),
      numberPadding: Json.integer(json, 'numberPadding', or: 4),
      nextInvoiceSequence: Json.integer(json, 'nextInvoiceSequence', or: 1),
      nextEstimateSequence: Json.integer(json, 'nextEstimateSequence', or: 1),
      hasSeenWelcome: Json.flag(json, 'hasSeenWelcome'),
    );
  }

  static const String _numberFormatKey = 'numberFormat';

  JsonMap toJson() => {
        'defaultCurrency': defaultCurrency.code,
        'defaultTemplate': defaultTemplate.name,
        'dateFormat': dateFormat.name,
        _numberFormatKey: numberGrouping.name,
        'themeOption': themeOption.name,
        'defaultTaxLabel': defaultTaxLabel,
        'defaultTaxPercent': defaultTaxPercent,
        'defaultTermDays': defaultTermDays,
        'defaultPaymentTerms': defaultPaymentTerms,
        'defaultPaymentDetails': defaultPaymentDetails,
        'defaultNotes': defaultNotes,
        'invoicePrefix': invoicePrefix,
        'estimatePrefix': estimatePrefix,
        'numberPadding': numberPadding,
        'nextInvoiceSequence': nextInvoiceSequence,
        'nextEstimateSequence': nextEstimateSequence,
        'hasSeenWelcome': hasSeenWelcome,
      };
}
