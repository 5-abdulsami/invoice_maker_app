import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/storage/local_store.dart';

/// Stores every invoice and estimate.
class DocumentRepository {
  DocumentRepository(this._store);

  final LocalStore _store;

  final List<SalesDocument> _documents = [];

  /// Every document, most recently updated first.
  List<SalesDocument> get all => List.unmodifiable(_documents);

  Future<void> load() async {
    final records = await _store.readArray(StoreKeys.documents);
    _documents
      ..clear()
      ..addAll(records.map(SalesDocument.fromJson));
    _sort();
  }

  /// Documents of one kind, most recently updated first.
  List<SalesDocument> ofKind(DocumentKind kind) => _documents
      .where((document) => document.kind == kind)
      .toList(growable: false);

  int countOfKind(DocumentKind kind) =>
      _documents.where((document) => document.kind == kind).length;

  SalesDocument? byId(String? id) {
    if (id == null) return null;
    for (final document in _documents) {
      if (document.id == id) return document;
    }
    return null;
  }

  /// Inserts [document], or replaces the existing record with its id.
  ///
  /// Matching is by id only: the previous version compared value equality,
  /// so an edited document could fail to match and be stored twice.
  Future<void> save(SalesDocument document) async {
    final index = _indexOf(document.id);
    if (index == -1) {
      _documents.add(document);
    } else {
      _documents[index] = document;
    }
    _sort();
    await _persist();
  }

  Future<void> delete(String id) async {
    final index = _indexOf(id);
    if (index == -1) return;
    _documents.removeAt(index);
    await _persist();
  }

  /// True when [number] is free within its kind.
  bool isNumberAvailable(
    String number, {
    required DocumentKind kind,
    String? exceptId,
  }) {
    final needle = number.trim().toLowerCase();
    if (needle.isEmpty) return false;

    return !_documents.any(
      (document) =>
          document.kind == kind &&
          document.id != exceptId &&
          document.number.trim().toLowerCase() == needle,
    );
  }

  /// Every number already used by [kind], for generating the next one.
  Set<String> usedNumbers(DocumentKind kind) => _documents
      .where((document) => document.kind == kind)
      .map((document) => document.number.trim().toLowerCase())
      .toSet();

  Future<void> replaceAll(List<SalesDocument> documents) async {
    _documents
      ..clear()
      ..addAll(documents);
    _sort();
    await _persist();
  }

  Future<void> mergeAll(List<SalesDocument> documents) async {
    final known = _documents.map((document) => document.id).toSet();
    _documents.addAll(
      documents.where((document) => !known.contains(document.id)),
    );
    _sort();
    await _persist();
  }

  Future<void> clear() async {
    _documents.clear();
    await _store.remove(StoreKeys.documents);
  }

  int _indexOf(String id) =>
      _documents.indexWhere((document) => document.id == id);

  void _sort() =>
      _documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  Future<void> _persist() async {
    final records = _documents
        .map((document) => document.toJson())
        .toList(growable: false);
    await _store.writeArray(StoreKeys.documents, records);
  }

  List<JsonMap> toRecords() =>
      _documents.map((document) => document.toJson()).toList(growable: false);
}
