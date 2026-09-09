import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/item.dart';

/// The reusable item catalogue.
class ItemProvider extends ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);

  bool get hasItems => _items.isNotEmpty;

  void addItem(Item item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((current) => current.id == item.id);
    if (index == -1) return;
    _items[index] = item;
    notifyListeners();
  }

  void removeItem(Item item) {
    if (_items.remove(item)) notifyListeners();
  }

  void clearItems() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  Item? getItemById(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    return index == -1 ? null : _items[index];
  }

  /// Catalogue items whose name or description contains [query].
  List<Item> search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return items;

    return _items
        .where((item) =>
            item.name.toLowerCase().contains(trimmed) ||
            item.description.toLowerCase().contains(trimmed))
        .toList(growable: false);
  }
}
