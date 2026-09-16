import 'dart:convert';
import 'dart:io';

import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:path_provider/path_provider.dart';

/// Names of the stored collections and records.
sealed class StoreKeys {
  static const String settings = 'settings';
  static const String businessProfile = 'business_profile';
  static const String customers = 'customers';
  static const String catalogItems = 'catalog_items';
  static const String documents = 'documents';

  /// Every key, for a full wipe.
  static const List<String> all = [
    settings,
    businessProfile,
    customers,
    catalogItems,
    documents,
  ];
}

/// Persists JSON records under named keys.
abstract interface class LocalStore {
  Future<JsonMap?> readObject(String key);

  Future<List<JsonMap>> readArray(String key);

  Future<void> writeObject(String key, JsonMap value);

  Future<void> writeArray(String key, List<JsonMap> values);

  Future<void> remove(String key);

  /// Deletes every stored key.
  Future<void> clear();
}

/// A [LocalStore] backed by one JSON file per key in the app's private
/// directory.
///
/// Chosen over a database because the data is small, always loaded whole, and
/// this makes the backup file a straight copy of what is stored. Two
/// properties matter and are handled explicitly:
///
/// * Writes are atomic. Content goes to a temporary file which is then renamed
///   over the target, so a crash mid-write cannot leave a half-written file.
/// * A damaged file does not lose the data. The previous good copy is kept
///   alongside as `.bak` and is used when the main file will not parse.
class FileLocalStore implements LocalStore {
  FileLocalStore({required Directory directory}) : _directory = directory;

  /// Opens the store in the app's private documents directory.
  static Future<FileLocalStore> open() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final directory = Directory('${base.path}/$_folderName');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return FileLocalStore(directory: directory);
    } on Object catch (error) {
      throw StorageException(error);
    }
  }

  static const String _folderName = 'store';
  static const String _extension = '.json';
  static const String _backupExtension = '.bak';
  static const String _tempExtension = '.tmp';

  final Directory _directory;

  @override
  Future<JsonMap?> readObject(String key) async {
    final decoded = await _read(key);
    if (decoded is Map<Object?, Object?>) return Json.coerce(decoded);
    return null;
  }

  @override
  Future<List<JsonMap>> readArray(String key) async {
    final decoded = await _read(key);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(Json.coerce)
        .toList(growable: false);
  }

  @override
  Future<void> writeObject(String key, JsonMap value) => _write(key, value);

  @override
  Future<void> writeArray(String key, List<JsonMap> values) =>
      _write(key, values);

  @override
  Future<void> remove(String key) async {
    await _deleteQuietly(_fileFor(key));
    await _deleteQuietly(_backupFor(key));
  }

  @override
  Future<void> clear() async {
    for (final key in StoreKeys.all) {
      await remove(key);
    }
  }

  /// Decodes the file for [key], falling back to the backup copy.
  Future<Object?> _read(String key) async {
    final parsed = await _tryDecode(_fileFor(key));
    if (parsed != null) return parsed;

    // The main file is missing or damaged; the previous good copy stands in.
    return _tryDecode(_backupFor(key));
  }

  Future<Object?> _tryDecode(File file) async {
    try {
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      return jsonDecode(raw);
    } on Object {
      // Unreadable or malformed: treated as absent so the caller can carry on
      // with defaults rather than failing to start.
      return null;
    }
  }

  Future<void> _write(String key, Object value) async {
    final target = _fileFor(key);
    final temp = File('${target.path}$_tempExtension');

    try {
      await temp.writeAsString(jsonEncode(value), flush: true);

      // Keep the last good copy before replacing it.
      if (await target.exists()) {
        await target.copy(_backupFor(key).path);
      }
      await temp.rename(target.path);
    } on Object catch (error) {
      await _deleteQuietly(temp);
      throw StorageException(error);
    }
  }

  File _fileFor(String key) => File('${_directory.path}/$key$_extension');

  File _backupFor(String key) =>
      File('${_directory.path}/$key$_extension$_backupExtension');

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on Object {
      // Nothing useful to do if the temporary file cannot be removed.
    }
  }
}

/// An in-memory [LocalStore], used by tests.
class MemoryLocalStore implements LocalStore {
  final Map<String, Object> _values = {};

  @override
  Future<JsonMap?> readObject(String key) async {
    final value = _values[key];
    return value is JsonMap ? value : null;
  }

  @override
  Future<List<JsonMap>> readArray(String key) async {
    final value = _values[key];
    return value is List<JsonMap> ? value : const [];
  }

  @override
  Future<void> writeObject(String key, JsonMap value) async {
    _values[key] = value;
  }

  @override
  Future<void> writeArray(String key, List<JsonMap> values) async {
    _values[key] = values;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }
}
