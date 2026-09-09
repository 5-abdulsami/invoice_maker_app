import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/data/models/item.dart';

/// Holds the invoice being edited plus every saved invoice.
class InvoiceProvider extends ChangeNotifier {
  InvoiceProvider() {
    _draft = _createDraft();
  }

  final List<Invoice> _invoices = [];
  late Invoice _draft;
  int _nextInvoiceNumber = 1;

  /// The invoice currently being created or edited.
  Invoice get invoice => _draft;

  /// All saved invoices, newest last.
  List<Invoice> get invoices => List.unmodifiable(_invoices);

  bool get hasInvoices => _invoices.isNotEmpty;

  /// Applies [updater] to the draft in one notification.
  ///
  /// Prefer this over a setter per field:
  /// `updateDraft((invoice) => invoice.copyWith(terms: text))`.
  void updateDraft(Invoice Function(Invoice current) updater) {
    _draft = updater(_draft);
    notifyListeners();
  }

  /// Replaces the draft outright.
  void setDraft(Invoice invoice) => updateDraft((_) => invoice);

  /// Starts a fresh draft with the next free invoice number.
  void resetDraft({Currency currency = Currency.pkr, int dueTermDays = 7}) {
    _draft = _createDraft(currency: currency, dueTermDays: dueTermDays);
    notifyListeners();
  }

  Invoice _createDraft({
    Currency currency = Currency.pkr,
    int dueTermDays = 7,
  }) =>
      Invoice.blank(
        invoiceNumber: nextInvoiceNumber(),
        currency: currency,
        dueTermDays: dueTermDays,
      );

  /// The next unused invoice number, e.g. `INV00003`.
  String nextInvoiceNumber() {
    var candidate = _nextInvoiceNumber;
    String format(int value) => 'INV${value.toString().padLeft(5, '0')}';
    while (_invoices.any((invoice) => invoice.invoiceNumber == format(candidate))) {
      candidate++;
    }
    return format(candidate);
  }

  /// True when [number] is free, ignoring the invoice with [exceptId].
  bool isInvoiceNumberUnique(String number, {String? exceptId}) =>
      !_invoices.any(
        (invoice) => invoice.id != exceptId && invoice.invoiceNumber == number,
      );

  // ---------------------------------------------------------------- draft

  void setDueDate(DateTime dueDate) => updateDraft(
        (invoice) => invoice.copyWith(
          dueDate: dueDate,
          dueTerms: dueDate.difference(invoice.creationDate).inDays,
        ),
      );

  void setCreationDate(DateTime creationDate) => updateDraft((invoice) {
        final dueDate = creationDate.isAfter(invoice.dueDate)
            ? creationDate
            : invoice.dueDate;
        return invoice.copyWith(
          creationDate: creationDate,
          dueDate: dueDate,
          dueTerms: dueDate.difference(creationDate).inDays,
        );
      });

  void setItems(List<Item> items) =>
      updateDraft((invoice) => _recalculated(invoice.copyWith(items: items)));

  void addItem(Item item) =>
      setItems([..._draft.items, item]);

  void removeItem(Item item) =>
      setItems(_draft.items.where((current) => current.id != item.id).toList());

  void updateItem(String itemId, Item updated) {
    final index = _draft.items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;
    final items = List<Item>.of(_draft.items)..[index] = updated;
    setItems(items);
  }

  /// Moves the item at [oldIndex] to [newIndex] in the draft.
  ///
  /// [newIndex] is the destination in the list *after* the item is removed,
  /// which is what `ReorderableListView.onReorderItem` reports.
  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _draft.items.length) return;
    final items = List<Item>.of(_draft.items);
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex.clamp(0, items.length), moved);
    setItems(items);
  }

  /// Recomputes the draft's subtotal and total from its lines.
  void recalculateTotals() => updateDraft(_recalculated);

  Invoice _recalculated(Invoice invoice) {
    final subTotal = invoice.items.fold<double>(
      0,
      (sum, item) => sum + item.subAmount,
    );
    final withSubTotal = invoice.copyWith(subTotal: subTotal);
    return withSubTotal.copyWith(total: withSubTotal.computedTotal);
  }

  // ----------------------------------------------------------------- list

  /// Saves [invoice], adding it or replacing the existing entry with its id.
  void saveInvoice(Invoice invoice) {
    final index = _invoices.indexWhere((current) => current.id == invoice.id);
    if (index == -1) {
      _invoices.add(invoice);
      _nextInvoiceNumber++;
    } else {
      _invoices[index] = invoice;
    }
    notifyListeners();
  }

  void updateInvoice(Invoice invoice) {
    final index = _invoices.indexWhere((current) => current.id == invoice.id);
    if (index == -1) return;
    _invoices[index] = invoice;
    notifyListeners();
  }

  void removeInvoice(Invoice invoice) {
    final removed = _invoices.remove(invoice);
    if (removed) notifyListeners();
  }

  void clearInvoices() {
    if (_invoices.isEmpty) return;
    _invoices.clear();
    notifyListeners();
  }

  /// The saved invoice with [id], or null when it was never saved.
  Invoice? getInvoiceById(String id) {
    final index = _invoices.indexWhere((invoice) => invoice.id == id);
    return index == -1 ? null : _invoices[index];
  }

  void setStatus(String id, InvoiceStatus status, {double? paidAmount}) {
    final invoice = getInvoiceById(id);
    if (invoice == null) return;
    updateInvoice(
      invoice.copyWith(
        status: status,
        paidAmount: status == InvoiceStatus.partiallyPaid
            ? (paidAmount ?? invoice.paidAmount)
            : 0,
      ),
    );
  }

  void setTemplate(String id, InvoiceTemplate template) {
    final invoice = getInvoiceById(id);
    if (invoice == null) return;
    updateInvoice(invoice.copyWith(template: template));
  }

  /// Saved invoices matching [status] and [query], newest first.
  ///
  /// A null [status] means "all"; [InvoiceStatus.overdue] uses the due date
  /// rather than the stored status.
  List<Invoice> filtered({InvoiceStatus? status, String query = ''}) {
    final trimmed = query.trim().toLowerCase();

    return _invoices.reversed.where((invoice) {
      final matchesStatus = switch (status) {
        null => true,
        InvoiceStatus.overdue => invoice.isOverdue,
        _ => invoice.status == status,
      };
      if (!matchesStatus) return false;
      if (trimmed.isEmpty) return true;

      return invoice.invoiceNumber.toLowerCase().contains(trimmed) ||
          invoice.to.toLowerCase().contains(trimmed) ||
          invoice.poNumber.toLowerCase().contains(trimmed) ||
          invoice.total.toStringAsFixed(0).contains(trimmed);
    }).toList(growable: false);
  }

  /// Outstanding money across [invoices], excluding paid ones.
  double totalUnpaid(List<Invoice> invoices) => invoices
      .where((invoice) => invoice.status != InvoiceStatus.paid)
      .fold(0, (sum, invoice) => sum + invoice.balanceDue);

  /// Outstanding money on invoices whose due date has passed.
  double totalOverdue(List<Invoice> invoices) => invoices
      .where((invoice) => invoice.isOverdue)
      .fold(0, (sum, invoice) => sum + invoice.balanceDue);
}
