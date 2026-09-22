import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/repositories/catalog_repository.dart';
import 'package:invoicemaker/state/optimistic_notifier.dart';

/// Exposes the saved products and services.
class CatalogController extends ChangeNotifier with OptimisticNotifier {
  CatalogController(this._repository);

  final CatalogRepository _repository;

  List<CatalogItem> get all => _repository.all;

  bool get isEmpty => _repository.isEmpty;

  int get count => _repository.count;

  CatalogItem? byId(String? id) => _repository.byId(id);

  List<CatalogItem> search(String query) => _repository.search(query);

  Future<void> save(CatalogItem item) => commit(_repository.save(item));

  Future<void> delete(String id) => commit(_repository.delete(id));

  void refresh() => notifyListeners();
}
