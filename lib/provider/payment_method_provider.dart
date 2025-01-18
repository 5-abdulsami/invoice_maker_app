import 'package:flutter/material.dart';
import 'package:invoicemaker/model/payment_method_model.dart';

class PaymentMethodProvider extends ChangeNotifier {
  List<PaymentMethod>? _paymentMethods = [];
  final bool _isSelected = false;

  List<PaymentMethod> get paymentMethods => _paymentMethods!;

  bool get isSelected => _isSelected;

  // Toggle the selection state of a payment method
  void togglePaymentMethodSelection(int index) {
    if (index >= 0 && index < _paymentMethods!.length) {
      final currentMethod = _paymentMethods![index];
      _paymentMethods![index] = currentMethod.copyWith(
        isSelected: !currentMethod.isSelected!,
      );
      notifyListeners();
    }
  }

  // Add a new payment method
  void addPaymentMethod(String details) {
    _paymentMethods!.add(PaymentMethod(details: details));
    notifyListeners();
  }

  // Update an existing payment method by index
  void updatePaymentMethod(int index, String newDetails) {
    if (index >= 0 && index < _paymentMethods!.length) {
      _paymentMethods![index] =
          _paymentMethods![index].copyWith(details: newDetails);
      notifyListeners();
    }
  }

  // Remove a payment method by index
  void removePaymentMethod(int index) {
    if (index >= 0 && index < _paymentMethods!.length) {
      _paymentMethods!.removeAt(index);
      notifyListeners();
    }
  }

  // Clear all payment methods
  void clearPaymentMethods() {
    _paymentMethods!.clear();
    notifyListeners();
  }

  // Load payment methods from a list of strings (e.g., from a database or API)
  void loadPaymentMethods(List<String> detailsList) {
    _paymentMethods =
        detailsList.map((details) => PaymentMethod(details: details)).toList();
    notifyListeners();
  }

  // Get the currently selected payment method
  PaymentMethod? getSelectedPaymentMethod() {
    return _paymentMethods?.firstWhere(
      (method) => method.isSelected ?? false,
      orElse: () => PaymentMethod(details: "No Payment Method Selected"),
    );
  }
}
