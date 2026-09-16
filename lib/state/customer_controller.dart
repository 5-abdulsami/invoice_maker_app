import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/repositories/customer_repository.dart';

/// Exposes the saved customers.
class CustomerController extends ChangeNotifier {
  CustomerController(this._repository);

  final CustomerRepository _repository;

  List<Customer> get all => _repository.all;

  bool get isEmpty => _repository.isEmpty;

  int get count => _repository.count;

  Customer? byId(String? id) => _repository.byId(id);

  /// Customers matching [query], or all of them when it is blank.
  List<Customer> search(String query) => _repository.search(query);

  Future<void> save(Customer customer) async {
    await _repository.save(customer);
    notifyListeners();
  }

  /// Creates and saves a customer, returning the stored record.
  Future<Customer> create({
    required String name,
    String email = '',
    String phone = '',
    String address = '',
    String taxNumber = '',
    String notes = '',
  }) async {
    final customer = Customer.create(
      name: name,
      email: email,
      phone: phone,
      address: address,
      taxNumber: taxNumber,
      notes: notes,
    );
    await save(customer);
    return customer;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
