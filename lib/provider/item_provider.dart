import 'package:flutter/foundation.dart';
import 'package:invoicemaker/model/item_model.dart';

class ItemProvider extends ChangeNotifier {
  Item _item = Item(
    id: DateTime.now().toIso8601String(),
    name: '',
    price: 0.0,
    quantity: 0,
    unitOfMeasure: '',
    discount: 0.0,
    tax: 0.0,
    description: '',
    subAmount: 0.0,
  );

  Item get item => _item;

  //items List
  final List<Item> _items = [];

  List<Item> get items => _items;

  void setName(String name) {
    _item = _item.copyWith(name: name);
    notifyListeners();
  }

  void setPrice(double price) {
    _item = _item.copyWith(price: price);
    notifyListeners();
  }

  void setQuantity(int quantity) {
    _item = _item.copyWith(quantity: quantity);
    notifyListeners();
  }

  void setUnitOfMeasure(String unitOfMeasure) {
    _item = _item.copyWith(unitOfMeasure: unitOfMeasure);
    notifyListeners();
  }

  void setDiscount(double discount) {
    _item = _item.copyWith(discount: discount);
    notifyListeners();
  }

  void setTax(double tax) {
    _item = _item.copyWith(tax: tax);
    notifyListeners();
  }

  void setDescription(String description) {
    _item = _item.copyWith(description: description);
    notifyListeners();
  }

  void setSubAmount(double subAmount) {
    _item = _item.copyWith(subAmount: subAmount);
    notifyListeners();
  }

  void setItem(Item item) {
    _item = item;
    notifyListeners();
  }

  //items List methods
  void addItem(Item item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateItem(Item updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }
}
