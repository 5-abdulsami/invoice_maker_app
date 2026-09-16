import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/repositories/catalog_repository.dart';

/// Exposes the saved products and services.
class CatalogController extends ChangeNotifier {
  CatalogController(this._repository);

  final CatalogRepository _repository;

  List<CatalogItem> get all => _repository.all;

  bool get isEmpty => _repository.isEmpty;

  int get count => _repository.count;

  CatalogItem? byId(String? id) => _repository.byId(id);

  List<CatalogItem> search(String query) => _repository.search(query);

  Future<void> save(CatalogItem item) async {
    await _repository.save(item);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
