import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';
import 'package:invoicemaker/core/utils/id.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/domain/document_totals.dart';

/// An invoice or an estimate.
///
/// Both are the same document with a different label, end-date meaning and
/// status vocabulary, so they share one model, one store and one PDF pipeline.
///
/// The record holds only what the user entered. Money figures are derived by
/// [totals] and the two parties are frozen snapshots, so a saved document
/// never changes because the business profile or a customer was edited later.
@immutable
class SalesDocument {
  const SalesDocument({
    required this.id,
    required this.kind,
    required this.number,
    required this.issueDate,
    required this.endDate,
    required this.issuer,
    required this.recipient,
    required this.lines,
    required this.currency,
    required this.status,
    required this.template,
    required this.createdAt,
    required this.updatedAt,
    this.title = '',
    this.reference = '',
    this.customerId,
    this.issuerLogoPath,
    this.signaturePath,
    this.discount = const Adjustment.none(),
    this.taxLabel = '',
    this.taxPercent = 0,
    this.shipping = 0,
    this.amountPaid = 0,
    this.notes = '',
    this.paymentTerms = '',
    this.paymentDetails = '',
  });

  /// A blank document, seeded from the caller's defaults.
  factory SalesDocument.draft({
    required DocumentKind kind,
    required String number,
    required PartySnapshot issuer,
    required Currency currency,
    required InvoiceTemplate template,
    required int termDays,
    String? issuerLogoPath,
    String? signaturePath,
    String taxLabel = '',
    double taxPercent = 0,
    String paymentTerms = '',
    String paymentDetails = '',
    String notes = '',
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final issued = timestamp.dateOnly;

    return SalesDocument(
      id: Id.generate(),
      kind: kind,
      number: number,
      issueDate: issued,
      endDate: issued.add(Duration(days: termDays < 0 ? 0 : termDays)),
      issuer: issuer,
      recipient: const PartySnapshot.empty(),
      lines: const [],
      currency: currency,
      status: DocumentStatus.initialFor(kind),
      template: template,
      createdAt: timestamp,
      updatedAt: timestamp,
      issuerLogoPath: issuerLogoPath,
      signaturePath: signaturePath,
      taxLabel: taxLabel,
      taxPercent: taxPercent,
      paymentTerms: paymentTerms,
      paymentDetails: paymentDetails,
      notes: notes,
    );
  }

  final String id;
  final DocumentKind kind;

  /// User-visible reference, e.g. `INV-0007`. Unique within its kind.
  final String number;

  /// Heading printed on the document; falls back to the kind's default.
  final String title;

  /// Purchase order or job reference supplied by the customer.
  final String reference;

  final DateTime issueDate;

  /// Due date for an invoice, valid-until date for an estimate.
  final DateTime endDate;

  /// The business details as they were when this document was issued.
  final PartySnapshot issuer;

  /// The customer details as they were when this document was issued.
  final PartySnapshot recipient;

  /// Link back to the saved customer, for filtering. Null when the recipient
  /// was typed in directly or the customer has since been deleted.
  final String? customerId;

  final String? issuerLogoPath;
  final String? signaturePath;

  final List<LineItem> lines;

  final Adjustment discount;

  /// Name of the tax, e.g. `VAT` or `GST`.
  final String taxLabel;

  /// Default tax rate for rows that do not set their own.
  final double taxPercent;

  final double shipping;
  final Currency currency;
  final DocumentStatus status;

  /// Amount received so far; only meaningful for a part-paid invoice.
  final double amountPaid;

  final String notes;
  final String paymentTerms;

  /// How to pay, e.g. bank details. Printed on the document.
  final String paymentDetails;

  final InvoiceTemplate template;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInvoice => kind.isInvoice;

  /// Every money figure, derived from the inputs above.
  DocumentTotals get totals => DocumentTotals.compute(
        lines: lines,
        discount: discount,
        taxPercent: taxPercent,
        shipping: shipping,
        currency: currency,
        amountPaid: status.tracksPartialPayment ? amountPaid : 0,
        isFullyPaid: status == DocumentStatus.paid,
      );

  /// The heading to print.
  String get displayTitle =>
      title.trim().isEmpty ? kind.printedTitle : title.trim();

  /// The customer name, or a placeholder when none was set.
  String get recipientName =>
      recipient.name.trim().isEmpty ? 'No customer' : recipient.name.trim();

  bool get hasRecipient => recipient.isNotEmpty;

  /// True once the due or valid-until date has passed and the document is
  /// still awaiting a response.
  bool get isPastEndDate => !status.isSettled && endDate.isBeforeToday;

  /// How the status should be labelled right now.
  DocumentStatusPresentation get statusPresentation =>
      DocumentStatusPresentation.of(status, isPastEndDate: isPastEndDate);

  /// Days between the issue date and the end date.
  int get termDays => issueDate.daysTo(endDate);

  bool get isDueOnReceipt => issueDate.isSameDate(endDate);

  /// True when [query] appears in any searchable field.
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return number.toLowerCase().contains(needle) ||
        recipient.name.toLowerCase().contains(needle) ||
        reference.toLowerCase().contains(needle) ||
        title.toLowerCase().contains(needle) ||
        notes.toLowerCase().contains(needle) ||
        lines.any((line) => line.name.toLowerCase().contains(needle)) ||
        totals.total.toStringAsFixed(currency.decimalDigits).contains(needle);
  }

  SalesDocument copyWith({
    String? number,
    String? title,
    String? reference,
    DateTime? issueDate,
    DateTime? endDate,
    PartySnapshot? issuer,
    PartySnapshot? recipient,
    String? customerId,
    bool clearCustomerId = false,
    String? issuerLogoPath,
    bool clearIssuerLogo = false,
    String? signaturePath,
    bool clearSignature = false,
    List<LineItem>? lines,
    Adjustment? discount,
    String? taxLabel,
    double? taxPercent,
    double? shipping,
    Currency? currency,
    DocumentStatus? status,
    double? amountPaid,
    String? notes,
    String? paymentTerms,
    String? paymentDetails,
    InvoiceTemplate? template,
    DateTime? updatedAt,
  }) {
    return SalesDocument(
      id: id,
      kind: kind,
      number: number ?? this.number,
      title: title ?? this.title,
      reference: reference ?? this.reference,
      issueDate: issueDate ?? this.issueDate,
      endDate: endDate ?? this.endDate,
      issuer: issuer ?? this.issuer,
      recipient: recipient ?? this.recipient,
      customerId: clearCustomerId ? null : (customerId ?? this.customerId),
      issuerLogoPath:
          clearIssuerLogo ? null : (issuerLogoPath ?? this.issuerLogoPath),
      signaturePath:
          clearSignature ? null : (signaturePath ?? this.signaturePath),
      lines: lines ?? this.lines,
      discount: discount ?? this.discount,
      taxLabel: taxLabel ?? this.taxLabel,
      taxPercent: taxPercent ?? this.taxPercent,
      shipping: shipping ?? this.shipping,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      template: template ?? this.template,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// An unsaved copy of this document under [number], reset to a new draft.
  ///
  /// Rows get fresh ids so editing the copy cannot touch the original, and
  /// the dates and payment state start again.
  SalesDocument duplicateAs({
    required String number,
    required int termDays,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final issued = timestamp.dateOnly;

    return SalesDocument(
      id: Id.generate(),
      kind: kind,
      number: number,
      title: title,
      reference: reference,
      issueDate: issued,
      endDate: issued.add(Duration(days: termDays < 0 ? 0 : termDays)),
      issuer: issuer,
      recipient: recipient,
      customerId: customerId,
      issuerLogoPath: issuerLogoPath,
      signaturePath: signaturePath,
      lines: lines.map((line) => line.withNewId()).toList(growable: false),
      discount: discount,
      taxLabel: taxLabel,
      taxPercent: taxPercent,
      shipping: shipping,
      currency: currency,
      status: DocumentStatus.initialFor(kind),
      template: template,
      notes: notes,
      paymentTerms: paymentTerms,
      paymentDetails: paymentDetails,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// This estimate as a new, unsaved invoice.
  SalesDocument asInvoice({
    required String number,
    required int termDays,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final issued = timestamp.dateOnly;

    return SalesDocument(
      id: Id.generate(),
      kind: DocumentKind.invoice,
      number: number,
      reference: reference,
      issueDate: issued,
      endDate: issued.add(Duration(days: termDays < 0 ? 0 : termDays)),
      issuer: issuer,
      recipient: recipient,
      customerId: customerId,
      issuerLogoPath: issuerLogoPath,
      signaturePath: signaturePath,
      lines: lines.map((line) => line.withNewId()).toList(growable: false),
      discount: discount,
      taxLabel: taxLabel,
      taxPercent: taxPercent,
      shipping: shipping,
      currency: currency,
      status: DocumentStatus.initialFor(DocumentKind.invoice),
      template: template,
      notes: notes,
      paymentTerms: paymentTerms,
      paymentDetails: paymentDetails,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  factory SalesDocument.fromJson(JsonMap json) {
    final kind = DocumentKind.fromName(Json.string(json, 'kind'));
    final created = Json.date(json, 'createdAt');
    final issued = Json.date(json, 'issueDate', or: created);

    return SalesDocument(
      id: Json.stringOrNull(json, 'id') ?? Id.generate(),
      kind: kind,
      number: Json.string(json, 'number'),
      title: Json.string(json, 'title'),
      reference: Json.string(json, 'reference'),
      issueDate: issued,
      endDate: Json.date(json, 'endDate', or: issued),
      issuer: PartySnapshot.fromJson(Json.object(json, 'issuer') ?? const {}),
      recipient: PartySnapshot.fromJson(
        Json.object(json, 'recipient') ?? const {},
      ),
      customerId: Json.stringOrNull(json, 'customerId'),
      issuerLogoPath: Json.stringOrNull(json, 'issuerLogoPath'),
      signaturePath: Json.stringOrNull(json, 'signaturePath'),
      lines: Json.objects(json, 'lines')
          .map(LineItem.fromJson)
          .toList(growable: false),
      discount: Adjustment.fromJson(
        Json.object(json, 'discount') ?? const {},
      ),
      taxLabel: Json.string(json, 'taxLabel'),
      taxPercent: Json.number(json, 'taxPercent'),
      shipping: Json.number(json, 'shipping'),
      currency: Currency.fromCode(Json.string(json, 'currency')),
      status: DocumentStatus.resolve(Json.string(json, 'status'), kind),
      amountPaid: Json.number(json, 'amountPaid'),
      notes: Json.string(json, 'notes'),
      paymentTerms: Json.string(json, 'paymentTerms'),
      paymentDetails: Json.string(json, 'paymentDetails'),
      template: InvoiceTemplate.fromName(Json.string(json, 'template')),
      createdAt: created,
      updatedAt: Json.date(json, 'updatedAt', or: created),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'kind': kind.name,
        'number': number,
        'title': title,
        'reference': reference,
        'issueDate': issueDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'issuer': issuer.toJson(),
        'recipient': recipient.toJson(),
        'customerId': customerId,
        'issuerLogoPath': issuerLogoPath,
        'signaturePath': signaturePath,
        'lines': lines.map((line) => line.toJson()).toList(growable: false),
        'discount': discount.toJson(),
        'taxLabel': taxLabel,
        'taxPercent': taxPercent,
        'shipping': shipping,
        'currency': currency.code,
        'status': status.name,
        'amountPaid': amountPaid,
        'notes': notes,
        'paymentTerms': paymentTerms,
        'paymentDetails': paymentDetails,
        'template': template.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is SalesDocument && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SalesDocument(${kind.name} $number)';
}
