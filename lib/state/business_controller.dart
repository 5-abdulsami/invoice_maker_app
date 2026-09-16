import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/business_profile.dart';
import 'package:invoicemaker/data/repositories/business_repository.dart';

/// Exposes the user's business profile, including the logo and signature
/// bytes the UI and the PDF both need.
class BusinessController extends ChangeNotifier {
  BusinessController(this._repository);

  final BusinessRepository _repository;

  Uint8List? _logoBytes;
  Uint8List? _signatureBytes;

  BusinessProfile get profile => _repository.profile;

  bool get isConfigured => profile.isConfigured;

  /// Logo image bytes, or null when none is set or the file is missing.
  Uint8List? get logoBytes => _logoBytes;

  Uint8List? get signatureBytes => _signatureBytes;

  bool get hasSignature => _signatureBytes != null;

  /// Loads the image bytes for the already-loaded profile.
  Future<void> loadImages() async {
    _logoBytes = await _repository.readLogoBytes();
    _signatureBytes = await _repository.readSignatureBytes();
    notifyListeners();
  }

  Future<void> save(BusinessProfile profile) async {
    await _repository.save(profile);
    notifyListeners();
  }

  /// Copies the picked image in as the logo.
  Future<void> setLogo(String sourcePath) async {
    await _repository.setLogo(sourcePath);
    _logoBytes = await _repository.readLogoBytes();
    notifyListeners();
  }

  Future<void> removeLogo() async {
    await _repository.clearLogo();
    _logoBytes = null;
    notifyListeners();
  }

  Future<void> setSignature(Uint8List bytes) async {
    await _repository.setSignature(bytes);
    _signatureBytes = await _repository.readSignatureBytes();
    notifyListeners();
  }

  Future<void> removeSignature() async {
    await _repository.clearSignature();
    _signatureBytes = null;
    notifyListeners();
  }

  /// Re-reads everything after a restore or a wipe.
  Future<void> refresh() async {
    await loadImages();
  }
}
