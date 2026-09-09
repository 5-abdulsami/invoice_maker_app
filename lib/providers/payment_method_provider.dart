import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/payment_method.dart';

/// Saved payment instructions, one of which can be attached to an invoice.
class PaymentMethodProvider extends ChangeNotifier {
  final List<PaymentMethod> _paymentMethods = [];

  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);

  bool get isEmpty => _paymentMethods.isEmpty;

  /// The chosen method, or null when the user has not picked one.
  PaymentMethod? get selectedPaymentMethod {
    final index = _paymentMethods.indexWhere((method) => method.isSelected);
    return index == -1 ? null : _paymentMethods[index];
  }

  /// Selects the method at [index] and deselects the rest; tapping the
  /// selected one clears the selection.
  void togglePaymentMethodSelection(int index) {
    if (!_isValidIndex(index)) return;

    final shouldSelect = !_paymentMethods[index].isSelected;
    for (var i = 0; i < _paymentMethods.length; i++) {
      final isSelected = shouldSelect && i == index;
      if (_paymentMethods[i].isSelected != isSelected) {
        _paymentMethods[i] =
            _paymentMethods[i].copyWith(isSelected: isSelected);
      }
    }
    notifyListeners();
  }

  void addPaymentMethod(String details) {
    final trimmed = details.trim();
    if (trimmed.isEmpty) return;
    _paymentMethods.add(PaymentMethod(details: trimmed));
    notifyListeners();
  }

  void updatePaymentMethod(int index, String details) {
    if (!_isValidIndex(index)) return;
    final trimmed = details.trim();
    if (trimmed.isEmpty) return;
    _paymentMethods[index] = _paymentMethods[index].copyWith(details: trimmed);
    notifyListeners();
  }

  void removePaymentMethod(int index) {
    if (!_isValidIndex(index)) return;
    _paymentMethods.removeAt(index);
    notifyListeners();
  }

  void clearPaymentMethods() {
    if (_paymentMethods.isEmpty) return;
    _paymentMethods.clear();
    notifyListeners();
  }

  /// Replaces the list, e.g. when restoring a backup.
  void loadPaymentMethods(List<String> details) {
    _paymentMethods
      ..clear()
      ..addAll(details.map((detail) => PaymentMethod(details: detail)));
    notifyListeners();
  }

  bool _isValidIndex(int index) =>
      index >= 0 && index < _paymentMethods.length;
}
