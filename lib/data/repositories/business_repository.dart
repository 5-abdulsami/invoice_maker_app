import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/data/models/business_profile.dart';
import 'package:invoicemaker/data/storage/local_store.dart';
import 'package:invoicemaker/services/file_vault.dart';

/// Reads and writes the user's own business details.
///
/// Owns the lifecycle of the logo and signature images: picking a new one
/// copies it into app storage and removes the file it replaced, so the
/// directory does not fill up with orphans.
class BusinessRepository {
  BusinessRepository(this._store, this._vault);

  final LocalStore _store;

  /// Null when storage could not be opened, in which case images cannot be
  /// kept and the picker reports a failure rather than silently losing them.
  final FileVault? _vault;

  BusinessProfile _profile = BusinessProfile.empty;

  BusinessProfile get profile => _profile;

  FileVault get _requireVault {
    final vault = _vault;
    if (vault == null) throw const StorageException();
    return vault;
  }

  Future<void> load() async {
    final json = await _store.readObject(StoreKeys.businessProfile);
    _profile = json == null ? BusinessProfile.empty : BusinessProfile.fromJson(json);
  }

  Future<void> save(BusinessProfile profile) async {
    _profile = profile;
    await _store.writeObject(StoreKeys.businessProfile, profile.toJson());
  }

  /// Copies the image at [sourcePath] in as the logo and saves the profile.
  Future<BusinessProfile> setLogo(String sourcePath) async {
    final vault = _requireVault;
    final stored = await vault.storeFile(sourcePath, prefix: _logoPrefix);
    final previous = _profile.logoPath;

    await save(_profile.copyWith(logoPath: stored));
    await vault.delete(previous);
    return _profile;
  }

  Future<BusinessProfile> clearLogo() async {
    final previous = _profile.logoPath;
    await save(_profile.copyWith(clearLogo: true));
    await _vault?.delete(previous);
    return _profile;
  }

  /// Stores [bytes] as the signature and saves the profile.
  Future<BusinessProfile> setSignature(Uint8List bytes) async {
    final vault = _requireVault;
    final stored = await vault.storeBytes(bytes, prefix: _signaturePrefix);
    final previous = _profile.signaturePath;

    await save(_profile.copyWith(signaturePath: stored));
    await vault.delete(previous);
    return _profile;
  }

  Future<BusinessProfile> clearSignature() async {
    final previous = _profile.signaturePath;
    await save(_profile.copyWith(clearSignature: true));
    await _vault?.delete(previous);
    return _profile;
  }

  /// Reads the logo bytes, or null when none is set or the file is gone.
  Future<Uint8List?> readLogoBytes() async =>
      _vault?.readBytes(_profile.logoPath);

  Future<Uint8List?> readSignatureBytes() async =>
      _vault?.readBytes(_profile.signaturePath);

  /// Replaces the profile wholesale, used when restoring a backup.
  Future<void> replace(BusinessProfile profile) => save(profile);

  Future<void> clear() async {
    await _vault?.delete(_profile.logoPath);
    await _vault?.delete(_profile.signaturePath);
    _profile = BusinessProfile.empty;
    await _store.remove(StoreKeys.businessProfile);
  }

  static const String _logoPrefix = 'logo';
  static const String _signaturePrefix = 'signature';
}
