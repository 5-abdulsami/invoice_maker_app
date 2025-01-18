import 'package:flutter/material.dart';
import 'package:invoicemaker/model/estimate_model.dart';
import 'package:invoicemaker/model/item_model.dart';

class EstimateProvider extends ChangeNotifier {
  Estimate _estimate = Estimate(
    estimateNumber: '',
    creationDate: DateTime.now(),
    dueDate: DateTime.now().add(const Duration(days: 7)),
    estimateTitle: '',
    language: '',
    from: '',
    to: '',
    items: [],
    subTotal: 0.0,
    discount: 0.0,
    taxName: '', // New property initialized
    tax: 0.0,
    shippingCharges: 0.0,
    total: 0.0,
    currency: '',
    dueTerms: 7,
    terms: '', // New property initialized
  );

  Estimate get estimate => _estimate;

  // Setters for each property with notifyListeners to update the UI

  void setEstimateNumber(String number) {
    _estimate = _estimate.copyWith(estimateNumber: number);
    notifyListeners();
  }

  void setCreationDate(DateTime date) {
    _estimate = _estimate.copyWith(creationDate: date);
    notifyListeners();
  }

  void updateDueTerms() {
    final int updatedDueTerms =
        _estimate.dueDate.difference(_estimate.creationDate).inDays;
    _estimate = _estimate.copyWith(dueTerms: updatedDueTerms);
    notifyListeners();
  }

  void setDueTerms(int dueTerms) {
    _estimate = _estimate.copyWith(dueTerms: dueTerms);
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    _estimate = _estimate.copyWith(dueDate: date);
    notifyListeners();
  }

  void setEstimateTitle(String title) {
    _estimate = _estimate.copyWith(estimateTitle: title);
    notifyListeners();
  }

  void setLanguage(String language) {
    _estimate = _estimate.copyWith(language: language);
    notifyListeners();
  }

  void setFrom(String from) {
    _estimate = _estimate.copyWith(from: from);
    notifyListeners();
  }

  void setTo(String to) {
    _estimate = _estimate.copyWith(to: to);
    notifyListeners();
  }

  void setItems(List<Item> items) {
    _estimate = _estimate.copyWith(items: items);
    notifyListeners();
  }

  void setSubTotal(double subTotal) {
    _estimate = _estimate.copyWith(subTotal: subTotal);
    notifyListeners();
  }

  void setDiscount(double discount) {
    _estimate = _estimate.copyWith(discount: discount);
    notifyListeners();
  }

  void setTaxName(String taxName) {
    // New setter for taxName
    _estimate = _estimate.copyWith(taxName: taxName);
    notifyListeners();
  }

  void setTax(double tax) {
    _estimate = _estimate.copyWith(tax: tax);
    notifyListeners();
  }

  void setShippingCharges(double shippingCharges) {
    _estimate = _estimate.copyWith(shippingCharges: shippingCharges);
    notifyListeners();
  }

  void setTotal(double total) {
    _estimate = _estimate.copyWith(total: total);
    notifyListeners();
  }

  void setCurrency(String currency) {
    _estimate = _estimate.copyWith(currency: currency);
    notifyListeners();
  }

  void setTerms(String terms) {
    // New setter for terms
    _estimate = _estimate.copyWith(terms: terms);
    notifyListeners();
  }

  // Method to set the entire Estimate object
  void setEstimate(Estimate estimate) {
    _estimate = estimate;
    notifyListeners();
  }

  // Method to load an Estimate from a JSON string
  void loadEstimateFromJson(String jsonString) {
    _estimate = Estimate.fromJsonString(jsonString);
    notifyListeners();
  }

  // Method to get the current Estimate as a JSON string
  String getEstimateAsJson() {
    return _estimate.toJsonString();
  }
}
