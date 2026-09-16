import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/repositories/business_repository.dart';
import 'package:invoicemaker/data/repositories/catalog_repository.dart';
import 'package:invoicemaker/data/repositories/customer_repository.dart';
import 'package:invoicemaker/data/repositories/document_repository.dart';
import 'package:invoicemaker/data/repositories/settings_repository.dart';
import 'package:invoicemaker/data/storage/local_store.dart';
import 'package:invoicemaker/services/file_vault.dart';

/// The app's storage, opened once at startup.
///
/// Holding the repositories together keeps the wiring in one place and gives
/// the backup service a single object to read from and write back to.
class AppRepositories {
  AppRepositories({
    required this.store,
    required this.vault,
    required this.settings,
    required this.business,
    required this.customers,
    required this.catalog,
    required this.documents,
  });

  /// Opens storage and loads everything into memory.
  ///
  /// If storage cannot be opened at all the app still starts, backed by an
  /// in-memory store: the user can work and will be told saving is
  /// unavailable, which beats failing to launch.
  static Future<AppRepositories> initialize() async {
    final (LocalStore store, FileVault? vault) = await _openStorage();

    final repositories = AppRepositories(
      store: store,
      vault: vault,
      settings: SettingsRepository(store),
      business: BusinessRepository(store, vault),
      customers: CustomerRepository(store),
      catalog: CatalogRepository(store),
      documents: DocumentRepository(store),
    );

    await repositories._loadAll();
    return repositories;
  }

  static Future<(LocalStore, FileVault?)> _openStorage() async {
    try {
      final store = await FileLocalStore.open();
      final vault = await FileVault.open();
      return (store, vault);
    } on Object catch (error) {
      debugPrint('Falling back to in-memory storage: $error');
      return (MemoryLocalStore(), null);
    }
  }

  final LocalStore store;

  /// Null only when storage could not be opened, in which case images
  /// cannot be kept.
  final FileVault? vault;

  final SettingsRepository settings;
  final BusinessRepository business;
  final CustomerRepository customers;
  final CatalogRepository catalog;
  final DocumentRepository documents;

  /// True when data is being held in memory only and will not survive a
  /// restart.
  bool get isEphemeral => store is MemoryLocalStore;

  Future<void> _loadAll() async {
    await Future.wait([
      settings.load(),
      business.load(),
      customers.load(),
      catalog.load(),
      documents.load(),
    ]);
  }

  /// Reloads from disk, used after a backup is restored.
  Future<void> reload() => _loadAll();

  /// Deletes every record and every stored image.
  Future<void> clearEverything() async {
    await documents.clear();
    await customers.clear();
    await catalog.clear();
    await business.clear();
    await settings.reset();
    await vault?.clear();
  }
}
