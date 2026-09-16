import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/storage/local_store.dart';

/// Stores the saved products and services.
class CatalogRepository {
  CatalogRepository(this._store);

  final LocalStore _store;

  final List<CatalogItem> _items = [];

  /// Every saved item, ordered by name.
  List<CatalogItem> get all => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get count => _items.length;

  Future<void> load() async {
    final records = await _store.readArray(StoreKeys.catalogItems);
    _items
      ..clear()
      ..addAll(records.map(CatalogItem.fromJson));
    _sort();
  }

  CatalogItem? byId(String? id) {
    if (id == null) return null;
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<CatalogItem> search(String query) {
    if (query.trim().isEmpty) return all;
    return _items.where((item) => item.matches(query)).toList(growable: false);
  }

  Future<void> save(CatalogItem item) async {
    final index = _indexOf(item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    _sort();
    await _persist();
  }

  Future<void> delete(String id) async {
    final index = _indexOf(id);
    if (index == -1) return;
    _items.removeAt(index);
    await _persist();
  }

  Future<void> replaceAll(List<CatalogItem> items) async {
    _items
      ..clear()
      ..addAll(items);
    _sort();
    await _persist();
  }

  Future<void> mergeAll(List<CatalogItem> items) async {
    final known = _items.map((item) => item.id).toSet();
    _items.addAll(items.where((item) => !known.contains(item.id)));
    _sort();
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    await _store.remove(StoreKeys.catalogItems);
  }

  int _indexOf(String id) => _items.indexWhere((item) => item.id == id);

  void _sort() => _items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

  Future<void> _persist() async {
    final records = _items.map((item) => item.toJson()).toList(growable: false);
    await _store.writeArray(StoreKeys.catalogItems, records);
  }

  List<JsonMap> toRecords() =>
      _items.map((item) => item.toJson()).toList(growable: false);
}
