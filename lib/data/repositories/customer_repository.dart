import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/storage/local_store.dart';

/// Stores the saved customers.
///
/// The list is held in memory after [load] so screens can read it without an
/// await, and every mutation writes the whole collection back atomically.
class CustomerRepository {
  CustomerRepository(this._store);

  final LocalStore _store;

  final List<Customer> _customers = [];

  /// Every customer, ordered by name.
  List<Customer> get all => List.unmodifiable(_customers);

  bool get isEmpty => _customers.isEmpty;

  int get count => _customers.length;

  Future<void> load() async {
    final records = await _store.readArray(StoreKeys.customers);
    _customers
      ..clear()
      ..addAll(records.map(Customer.fromJson));
    _sort();
  }

  Customer? byId(String? id) {
    if (id == null) return null;
    for (final customer in _customers) {
      if (customer.id == id) return customer;
    }
    return null;
  }

  /// Customers matching [query], ordered by name.
  List<Customer> search(String query) {
    if (query.trim().isEmpty) return all;
    return _customers
        .where((customer) => customer.matches(query))
        .toList(growable: false);
  }

  /// Inserts [customer], or replaces the existing record with its id.
  Future<void> save(Customer customer) async {
    final index = _indexOf(customer.id);
    if (index == -1) {
      _customers.add(customer);
    } else {
      _customers[index] = customer;
    }
    _sort();
    await _persist();
  }

  Future<void> delete(String id) async {
    final index = _indexOf(id);
    if (index == -1) return;
    _customers.removeAt(index);
    await _persist();
  }

  /// Replaces the collection, used when restoring a backup.
  Future<void> replaceAll(List<Customer> customers) async {
    _customers
      ..clear()
      ..addAll(customers);
    _sort();
    await _persist();
  }

  /// Adds the customers whose ids are not already present.
  Future<void> mergeAll(List<Customer> customers) async {
    final known = _customers.map((customer) => customer.id).toSet();
    _customers.addAll(
      customers.where((customer) => !known.contains(customer.id)),
    );
    _sort();
    await _persist();
  }

  Future<void> clear() async {
    _customers.clear();
    await _store.remove(StoreKeys.customers);
  }

  int _indexOf(String id) =>
      _customers.indexWhere((customer) => customer.id == id);

  /// Case-insensitive by name, so the list reads naturally.
  void _sort() => _customers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

  Future<void> _persist() async {
    final records = _customers
        .map((customer) => customer.toJson())
        .toList(growable: false);
    await _store.writeArray(StoreKeys.customers, records);
  }

  /// The stored records, for building a backup.
  List<JsonMap> toRecords() =>
      _customers.map((customer) => customer.toJson()).toList(growable: false);
}
