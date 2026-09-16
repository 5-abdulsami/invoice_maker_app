import 'dart:io';
import 'dart:typed_data';

import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/utils/id.dart';
import 'package:path_provider/path_provider.dart';

/// Owns the images the app must keep: the business logo and the signature.
///
/// A picked photo lives in a cache the system may clear, and the user can
/// delete the original from their gallery, so the file is copied into the
/// app's own directory and only that copy is referenced afterwards.
class FileVault {
  FileVault({required Directory directory}) : _directory = directory;

  static Future<FileVault> open() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final directory = Directory('${base.path}/$_folderName');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return FileVault(directory: directory);
    } on Object catch (error) {
      throw StorageException(error);
    }
  }

  static const String _folderName = 'media';

  final Directory _directory;

  /// Copies the file at [sourcePath] in and returns the stored path.
  Future<String> storeFile(String sourcePath, {required String prefix}) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) throw const ImagePickException();

      final destination = _newFile(prefix, _extensionOf(sourcePath));
      await source.copy(destination.path);
      return destination.path;
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw ImagePickException(error);
    }
  }

  /// Writes [bytes] in and returns the stored path.
  Future<String> storeBytes(
    Uint8List bytes, {
    required String prefix,
    String extension = 'png',
  }) async {
    try {
      final destination = _newFile(prefix, extension);
      await destination.writeAsBytes(bytes, flush: true);
      return destination.path;
    } on Object catch (error) {
      throw StorageException(error);
    }
  }

  /// Reads a stored file, returning null when it is missing or unreadable.
  ///
  /// Callers treat null as "no image", so a deleted file degrades to a
  /// document without a logo rather than an error.
  Future<Uint8List?> readBytes(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } on Object {
      return null;
    }
  }

  /// Deletes [path], but only when this vault owns it.
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    if (!path.startsWith(_directory.path)) return;

    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on Object {
      // A leftover image is harmless; never fail a save because of one.
    }
  }

  /// Removes every stored file, for a full data wipe.
  Future<void> clear() async {
    try {
      if (!await _directory.exists()) return;
      await for (final entity in _directory.list()) {
        if (entity is File) await entity.delete();
      }
    } on Object {
      // Best effort: the records are already gone by this point.
    }
  }

  File _newFile(String prefix, String extension) =>
      File('${_directory.path}/$prefix-${Id.generate()}.$extension');

  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'png';

    final extension = path.substring(dot + 1).toLowerCase();
    return extension.length <= 4 ? extension : 'png';
  }
}
