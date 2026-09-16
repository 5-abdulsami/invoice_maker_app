import 'package:invoicemaker/data/models/app_settings.dart';
import 'package:invoicemaker/data/storage/local_store.dart';

/// Reads and writes the user's preferences.
class SettingsRepository {
  SettingsRepository(this._store);

  final LocalStore _store;

  AppSettings _settings = AppSettings.defaults;

  AppSettings get settings => _settings;

  /// Loads the stored preferences, falling back to the defaults.
  Future<void> load() async {
    final json = await _store.readObject(StoreKeys.settings);
    _settings = json == null ? AppSettings.defaults : AppSettings.fromJson(json);
  }

  Future<void> save(AppSettings settings) async {
    _settings = settings;
    await _store.writeObject(StoreKeys.settings, settings.toJson());
  }

  /// Resets to the defaults, keeping nothing.
  Future<void> reset() => save(AppSettings.defaults);
}
