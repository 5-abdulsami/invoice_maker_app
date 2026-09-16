import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/domain/document_totals.dart';

/// The document being edited.
///
/// Scoped to the editor screen rather than held app-wide, which is what lets
/// two documents be edited in sequence without one leaking into the other.
/// Nothing here touches storage: the screen hands the finished document to
/// `DocumentController` to save.
class DocumentEditor extends ChangeNotifier {
  DocumentEditor({required SalesDocument document, required this.isNew})
      : _document = document;

  SalesDocument _document;
  bool _isDirty = false;

  /// True when this is a document being created rather than edited.
  final bool isNew;

  SalesDocument get document => _document;

  DocumentKind get kind => _document.kind;

  bool get isInvoice => _document.isInvoice;

  /// True once the user has changed anything, so leaving can warn them.
  bool get isDirty => _isDirty;

  DocumentTotals get totals => _document.totals;

  List<LineItem> get lines => _document.lines;

  Currency get currency => _document.currency;

  // ------------------------------------------------------------- identity

  void setNumber(String number) =>
      _update((document) => document.copyWith(number: number.trim()));

  void setTitle(String title) =>
      _update((document) => document.copyWith(title: title.trim()));

  void setReference(String reference) =>
      _update((document) => document.copyWith(reference: reference.trim()));

  /// Sets the issue date, pushing the end date out to keep the same term.
  void setIssueDate(DateTime date) {
    _update((document) {
      final term = document.issueDate.daysTo(document.endDate);
      final issued = date.dateOnly;
      return document.copyWith(
        issueDate: issued,
        endDate: issued.add(Duration(days: term < 0 ? 0 : term)),
      );
    });
  }

  /// Sets the end date, never earlier than the issue date.
  void setEndDate(DateTime date) {
    _update((document) {
      final end = date.dateOnly;
      return document.copyWith(
        endDate: end.isBefore(document.issueDate) ? document.issueDate : end,
      );
    });
  }

  void setTermDays(int days) {
    _update(
      (document) => document.copyWith(
        endDate: document.issueDate.add(Duration(days: days < 0 ? 0 : days)),
      ),
    );
  }

  // --------------------------------------------------------------- parties

  /// Freezes [customer]'s current details onto the document.
  void setRecipientFromCustomer(Customer customer) {
    _update(
      (document) => document.copyWith(
        recipient: customer.toSnapshot(),
        customerId: customer.id,
      ),
    );
  }

  /// Uses a name typed straight into the document, with no saved customer.
  void setRecipientName(String name) {
    _update(
      (document) => document.copyWith(
        recipient: PartySnapshot(name: name.trim()),
        clearCustomerId: true,
      ),
    );
  }

  void clearRecipient() {
    _update(
      (document) => document.copyWith(
        recipient: const PartySnapshot.empty(),
        clearCustomerId: true,
      ),
    );
  }

  /// Re-reads the business details, for when the profile was just filled in.
  void setIssuer(PartySnapshot issuer, {String? logoPath}) {
    _update(
      (document) => document.copyWith(
        issuer: issuer,
        issuerLogoPath: logoPath,
        clearIssuerLogo: logoPath == null,
      ),
    );
  }

  // ----------------------------------------------------------------- lines

  void addLine(LineItem line) =>
      _update((document) => document.copyWith(lines: [...document.lines, line]));

  void updateLine(LineItem line) {
    _update((document) {
      final index = document.lines.indexWhere((item) => item.id == line.id);
      if (index == -1) return document;

      final lines = List<LineItem>.of(document.lines)..[index] = line;
      return document.copyWith(lines: lines);
    });
  }

  void removeLine(String lineId) {
    _update(
      (document) => document.copyWith(
        lines: document.lines
            .where((line) => line.id != lineId)
            .toList(growable: false),
      ),
    );
  }

  /// Moves a row, using the post-removal index a reorderable list reports.
  void reorderLines(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _document.lines.length) return;

    _update((document) {
      final lines = List<LineItem>.of(document.lines);
      final moved = lines.removeAt(oldIndex);
      lines.insert(newIndex.clamp(0, lines.length), moved);
      return document.copyWith(lines: lines);
    });
  }

  // ----------------------------------------------------------------- money

  void setCurrency(Currency currency) =>
      _update((document) => document.copyWith(currency: currency));

  void setDiscount(Adjustment discount) =>
      _update((document) => document.copyWith(discount: discount));

  void setTax({required String label, required double percent}) => _update(
        (document) =>
            document.copyWith(taxLabel: label.trim(), taxPercent: percent),
      );

  void setShipping(double amount) =>
      _update((document) => document.copyWith(shipping: amount));

  /// Sets the status, clearing the part-payment when it no longer applies.
  void setStatus(DocumentStatus status, {double amountPaid = 0}) {
    _update(
      (document) => document.copyWith(
        status: status,
        amountPaid: status.tracksPartialPayment ? amountPaid : 0,
      ),
    );
  }

  // ------------------------------------------------------------------ text

  void setNotes(String notes) =>
      _update((document) => document.copyWith(notes: notes));

  void setPaymentTerms(String terms) =>
      _update((document) => document.copyWith(paymentTerms: terms));

  void setPaymentDetails(String details) =>
      _update((document) => document.copyWith(paymentDetails: details));

  void setTemplate(InvoiceTemplate template) =>
      _update((document) => document.copyWith(template: template));

  /// Attaches or removes the signature printed on this document.
  void setSignaturePath(String? path) {
    _update(
      (document) => document.copyWith(
        signaturePath: path,
        clearSignature: path == null,
      ),
    );
  }

  // ------------------------------------------------------------ validation

  /// The first problem stopping a save, or null when the document is valid.
  String? validate({required bool isNumberAvailable}) {
    if (_document.number.trim().isEmpty) {
      return '${_document.kind.label} number cannot be empty';
    }
    if (!isNumberAvailable) return AppCopy.numberTaken;
    if (!_document.hasRecipient) return AppCopy.needsCustomer;
    if (_document.lines.isEmpty) return AppCopy.needsOneItem;

    return null;
  }

  /// The document to store, with its modified time brought up to date.
  SalesDocument buildForSave() =>
      _document.copyWith(updatedAt: DateTime.now());

  void _update(SalesDocument Function(SalesDocument current) change) {
    final updated = change(_document);
    _document = updated;
    _isDirty = true;
    notifyListeners();
  }
}
