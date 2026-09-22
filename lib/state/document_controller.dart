import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/repositories/business_repository.dart';
import 'package:invoicemaker/data/repositories/document_repository.dart';
import 'package:invoicemaker/domain/numbering.dart';
import 'package:invoicemaker/state/optimistic_notifier.dart';
import 'package:invoicemaker/state/settings_controller.dart';

/// Totals shown on the home screen.
@immutable
class DocumentSummary {
  const DocumentSummary({
    required this.invoiceCount,
    required this.estimateCount,
    required this.outstanding,
    required this.overdue,
    required this.collected,
    required this.overdueCount,
  });

  static const DocumentSummary empty = DocumentSummary(
    invoiceCount: 0,
    estimateCount: 0,
    outstanding: 0,
    overdue: 0,
    collected: 0,
    overdueCount: 0,
  );

  final int invoiceCount;
  final int estimateCount;

  /// Money still owed across unsettled invoices.
  final double outstanding;

  /// Money owed on invoices whose due date has passed.
  final double overdue;

  /// Money received: paid invoices in full, plus part payments.
  final double collected;

  final int overdueCount;

  bool get hasInvoices => invoiceCount > 0;
}

/// Owns the stored documents: reading, saving, numbering and status changes.
class DocumentController extends ChangeNotifier with OptimisticNotifier {
  DocumentController({
    required DocumentRepository documents,
    required BusinessRepository business,
    required SettingsController settings,
  })  : _documents = documents,
        _business = business,
        _settings = settings;

  final DocumentRepository _documents;
  final BusinessRepository _business;
  final SettingsController _settings;

  List<SalesDocument> get all => _documents.all;

  List<SalesDocument> ofKind(DocumentKind kind) => _documents.ofKind(kind);

  SalesDocument? byId(String? id) => _documents.byId(id);

  int countOfKind(DocumentKind kind) => _documents.countOfKind(kind);

  /// The most recently updated documents, for the home screen.
  List<SalesDocument> recent({int limit = 4}) {
    final documents = _documents.all;
    return documents.take(limit).toList(growable: false);
  }

  /// Money totals across every invoice.
  DocumentSummary get summary {
    var outstanding = 0.0;
    var overdue = 0.0;
    var collected = 0.0;
    var invoiceCount = 0;
    var estimateCount = 0;
    var overdueCount = 0;

    for (final document in _documents.all) {
      if (!document.isInvoice) {
        estimateCount++;
        continue;
      }

      invoiceCount++;
      final totals = document.totals;
      collected += totals.amountPaid;

      if (document.status == DocumentStatus.paid) continue;

      outstanding += totals.balanceDue;
      if (document.isPastEndDate) {
        overdue += totals.balanceDue;
        overdueCount++;
      }
    }

    return DocumentSummary(
      invoiceCount: invoiceCount,
      estimateCount: estimateCount,
      outstanding: outstanding,
      overdue: overdue,
      collected: collected,
      overdueCount: overdueCount,
    );
  }

  /// A new unsaved document, seeded from the settings and business profile.
  SalesDocument newDraft(DocumentKind kind) {
    final settings = _settings.settings;
    final profile = _business.profile;
    final numbering = _nextNumber(kind);

    return SalesDocument.draft(
      kind: kind,
      number: numbering.number,
      issuer: profile.toSnapshot(),
      currency: settings.defaultCurrency,
      template: settings.defaultTemplate,
      termDays: settings.defaultTermDays,
      issuerLogoPath: profile.logoPath,
      signaturePath: profile.signaturePath,
      taxLabel: settings.defaultTaxLabel,
      taxPercent: settings.defaultTaxPercent,
      paymentTerms: settings.defaultPaymentTerms,
      paymentDetails: settings.defaultPaymentDetails,
      notes: settings.defaultNotes,
    );
  }

  /// The next free number for [kind].
  String nextNumberFor(DocumentKind kind) => _nextNumber(kind).number;

  bool isNumberAvailable(
    String number, {
    required DocumentKind kind,
    String? exceptId,
  }) =>
      _documents.isNumberAvailable(number, kind: kind, exceptId: exceptId);

  /// Saves [document] and advances the numbering sequence when its number
  /// came from the generator.
  Future<void> save(SalesDocument document) => commit(
        Future.wait([
          _documents.save(document),
          _advanceSequenceIfGenerated(document),
        ]),
      );

  Future<void> delete(String id) => commit(_documents.delete(id));

  /// Saves a copy of [document] under a fresh number and returns it.
  Future<SalesDocument> duplicate(SalesDocument document) async {
    final numbering = _nextNumber(document.kind);
    final copy = document.duplicateAs(
      number: numbering.number,
      termDays: _settings.settings.defaultTermDays,
    );
    await save(copy);
    return copy;
  }

  /// Saves [estimate] as a new invoice and returns it.
  Future<SalesDocument> convertToInvoice(SalesDocument estimate) async {
    final numbering = _nextNumber(DocumentKind.invoice);
    final invoice = estimate.asInvoice(
      number: numbering.number,
      termDays: _settings.settings.defaultTermDays,
    );
    await save(invoice);
    return invoice;
  }

  /// Changes the payment or approval state of a stored document.
  Future<void> setStatus(
    String id,
    DocumentStatus status, {
    double amountPaid = 0,
  }) async {
    final document = byId(id);
    if (document == null) return;

    await save(
      document.copyWith(
        status: status,
        amountPaid: status.tracksPartialPayment ? amountPaid : 0,
      ),
    );
  }

  Future<void> setTemplate(String id, InvoiceTemplate template) async {
    final document = byId(id);
    if (document == null) return;
    await save(document.copyWith(template: template));
  }

  void refresh() => notifyListeners();

  ({String number, int sequence}) _nextNumber(DocumentKind kind) =>
      DocumentNumbering.next(
        kind: kind,
        settings: _settings.settings,
        usedNumbers: _documents.usedNumbers(kind),
      );

  /// Keeps the stored counter ahead of the numbers actually used, so the next
  /// generated number is free even after a restart.
  Future<void> _advanceSequenceIfGenerated(SalesDocument document) async {
    final settings = _settings.settings;
    final sequence = settings.sequenceFor(document.kind);
    final expected = settings.formatNumber(document.kind, sequence);

    if (document.number.trim().toLowerCase() == expected.trim().toLowerCase()) {
      await _settings.advanceSequence(document.kind, sequence);
    }
  }
}
