import 'package:flutter/foundation.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/pdf_templates/templates.dart';

class InvoiceProvider extends ChangeNotifier {
  // For auto-incrementing invoice number
  int _latestInvoiceNumber = 1;

  late Invoice _invoice;

  InvoiceProvider() {
    _invoice = _createNewInvoice();
  }

  Invoice get invoice => _invoice;

  final List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  // Method to generate the next invoice number
  String _generateNextInvoiceNumber() {
    return 'INV${_latestInvoiceNumber.toString().padLeft(5, '0')}';
  }

  // Method to create a new invoice with auto-incremented invoice number
  Invoice _createNewInvoice() {
    return Invoice(
        id: DateTime.now().toIso8601String(),
        invoiceNumber: _generateNextInvoiceNumber(),
        creationDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        invoiceTitle: '',
        language: '',
        from: '',
        to: '',
        items: [],
        subTotal: 0.0,
        discount: 0.0,
        taxName: '',
        tax: 0.0,
        shippingCharges: 0.0,
        total: 0.0,
        currency: '',
        dueTerms: 7,
        poNumber: '',
        terms: '',
        paymentMethod: '',
        status: "Unpaid",
        paidAmount: 0.0,
        template: InvoiceTemplate.template1);
  }

  // Method to add a new invoice
  void addInvoice(Invoice invoice) {
    _invoices.add(invoice);
    _latestInvoiceNumber++;
    notifyListeners();
  }

  // Method to reset the invoice and increment the invoice number
  void resetInvoice() {
    _invoice = _createNewInvoice();
    notifyListeners();
  }

  // Setters for each property

  void setId(String id) {
    _invoice = _invoice.copyWith(id: id);
    notifyListeners();
  }

  void setInvoiceNumber(String number) {
    _invoice = _invoice.copyWith(invoiceNumber: number);
    notifyListeners();
  }

  void setCreationDate(DateTime date) {
    _invoice = _invoice.copyWith(creationDate: date);
    notifyListeners();
  }

  void setDueTerms(int dueTerms) {
    _invoice = _invoice.copyWith(dueTerms: dueTerms);
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    _invoice = _invoice.copyWith(dueDate: date);
    notifyListeners();
  }

  // New method to update dueTerms based on creationDate and dueDate
  void updateDueTerms() {
    final int updatedDueTerms =
        _invoice.dueDate.difference(_invoice.creationDate).inDays + 1;
    _invoice = _invoice.copyWith(dueTerms: updatedDueTerms);
    notifyListeners();
  }

  void setInvoiceTitle(String title) {
    _invoice = _invoice.copyWith(invoiceTitle: title);
    notifyListeners();
  }

  void setLanguage(String language) {
    _invoice = _invoice.copyWith(language: language);
    notifyListeners();
  }

  void setFrom(String from) {
    _invoice = _invoice.copyWith(from: from);
    notifyListeners();
  }

  void setTo(String to) {
    _invoice = _invoice.copyWith(to: to);
    notifyListeners();
  }

  void setItems(List<Item> items) {
    _invoice = _invoice.copyWith(items: items);
    notifyListeners();
  }

  void setSubTotal(double subTotal) {
    _invoice = _invoice.copyWith(subTotal: subTotal);
    notifyListeners();
  }

  void setDiscount(double discount) {
    _invoice = _invoice.copyWith(discount: discount);
    notifyListeners();
  }

  void setTaxName(String taxName) {
    _invoice = _invoice.copyWith(taxName: taxName);
    notifyListeners();
  }

  void setTax(double tax) {
    _invoice = _invoice.copyWith(tax: tax);
    notifyListeners();
  }

  void setShippingCharges(double shippingCharges) {
    _invoice = _invoice.copyWith(shippingCharges: shippingCharges);
    notifyListeners();
  }

  void setTotal(double total) {
    _invoice = _invoice.copyWith(total: total);
    notifyListeners();
  }

  void setCurrency(String currency) {
    _invoice = _invoice.copyWith(currency: currency);
    notifyListeners();
  }

  void setPoNumber(String poNumber) {
    _invoice = _invoice.copyWith(poNumber: poNumber);
    notifyListeners();
  }

  void setTerms(String terms) {
    // New setter for terms
    _invoice = _invoice.copyWith(terms: terms);
    notifyListeners();
  }

  void setStatus(String status) {
    _invoice = _invoice.copyWith(status: status);
    notifyListeners();
  }

  void setPaidAmount(double paidAmount) {
    _invoice = _invoice.copyWith(paidAmount: paidAmount);
    notifyListeners();
  }

  void setPaymentMethod(String paymentMethod) {
    _invoice = _invoice.copyWith(paymentMethod: paymentMethod);
    notifyListeners();
  }

  void setInvoice(Invoice invoice) {
    _invoice = invoice;
    notifyListeners();
  }

  // Reorder items in reorderable listview builder
  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Item item = _invoice.items.removeAt(oldIndex);
    _invoice.items.insert(newIndex, item);
    _invoice = _invoice.copyWith(items: _invoice.items); // Update _invoice
    notifyListeners();
  }

  // Update subTotal Method
  void updateSubTotal() {
    double subTotal =
        _invoice.items.fold(0, (sum, item) => sum + item.subAmount);
    setSubTotal(subTotal);
  }

  // Calculate total
  double calculateTotal() {
    return (invoice.subTotal -
        (invoice.subTotal * (invoice.discount / 100)) +
        (invoice.subTotal * (invoice.tax / 100)) +
        invoice.shippingCharges);
  }

  // Methods to manage the list of invoices

  void removeInvoice(Invoice invoice) {
    _invoices.remove(invoice);
    notifyListeners();
  }

  void clearInvoices() {
    _invoices.clear();
    notifyListeners();
  }

  bool hasInvoices() {
    return _invoices.isNotEmpty;
  }

  // Update invoice
  void updateInvoice(Invoice updatedInvoice) {
    final int index =
        _invoices.indexWhere((inv) => inv.id == updatedInvoice.id);
    if (index != -1) {
      _invoices[index] = updatedInvoice;
      notifyListeners();
    }
  }

  // Update item
  void updateItem(String itemId, Item updatedItem) {
    final index = _invoice.items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      List<Item> updatedItems = List.from(_invoice.items);
      updatedItems[index] = updatedItem;
      _invoice = _invoice.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void recalculateTotals() {
    double newSubTotal =
        _invoice.items.fold(0, (sum, item) => sum + item.subAmount);
    double newTotal = (newSubTotal -
        (newSubTotal * (_invoice.discount / 100)) +
        (newSubTotal * (_invoice.tax / 100)) +
        _invoice.shippingCharges);

    _invoice = _invoice.copyWith(subTotal: newSubTotal, total: newTotal);
    notifyListeners();
  }

  // New method to get an invoice by its ID
  Invoice? getInvoiceById(String id) {
    return _invoices.firstWhere((invoice) => invoice.id == id,
        orElse: () => _invoice);
  }

  // New method to update tax information for a specific invoice
  void updateInvoiceTax(String id, String taxName, double tax) {
    final index = _invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      final updatedInvoice = _invoices[index].copyWith(
        taxName: taxName,
        tax: tax,
      );
      _invoices[index] = updatedInvoice;
      notifyListeners();
    }
  }

  //template selection
  void setTemplate(InvoiceTemplate template, String invoiceId) {
    final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
    if (index != -1) {
      _invoices[index] = _invoices[index].copyWith(template: template);

      notifyListeners();
    }
  }
}
