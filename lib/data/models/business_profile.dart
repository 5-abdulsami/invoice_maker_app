import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';

/// The user's own business details, reused on every new document.
@immutable
class BusinessProfile {
  const BusinessProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.taxNumber = '',
    this.website = '',
    this.logoPath,
    this.signaturePath,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String taxNumber;
  final String website;

  /// Path to the logo inside the app's own storage.
  ///
  /// The picked image is copied in, so the reference stays valid after the
  /// original is deleted from the gallery.
  final String? logoPath;

  /// Path to the saved signature PNG inside the app's own storage.
  final String? signaturePath;

  static const BusinessProfile empty = BusinessProfile();

  bool get hasLogo => (logoPath ?? '').isNotEmpty;

  bool get hasSignature => (signaturePath ?? '').isNotEmpty;

  /// True once the user has given the business a name.
  bool get isConfigured => name.trim().isNotEmpty;

  /// Freezes these details onto a document.
  PartySnapshot toSnapshot() => PartySnapshot(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
        taxNumber: taxNumber.trim(),
        website: website.trim(),
      );

  /// Pass [clearLogo] or [clearSignature] to remove one, since passing null
  /// keeps the current value.
  BusinessProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? website,
    String? logoPath,
    String? signaturePath,
    bool clearLogo = false,
    bool clearSignature = false,
  }) {
    return BusinessProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      website: website ?? this.website,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      signaturePath:
          clearSignature ? null : (signaturePath ?? this.signaturePath),
    );
  }

  factory BusinessProfile.fromJson(JsonMap json) {
    return BusinessProfile(
      name: Json.string(json, 'name'),
      email: Json.string(json, 'email'),
      phone: Json.string(json, 'phone'),
      address: Json.string(json, 'address'),
      taxNumber: Json.string(json, 'taxNumber'),
      website: Json.string(json, 'website'),
      logoPath: Json.stringOrNull(json, 'logoPath'),
      signaturePath: Json.stringOrNull(json, 'signaturePath'),
    );
  }

  JsonMap toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'taxNumber': taxNumber,
        'website': website,
        'logoPath': logoPath,
        'signaturePath': signaturePath,
      };

  @override
  bool operator ==(Object other) =>
      other is BusinessProfile &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.address == address &&
      other.taxNumber == taxNumber &&
      other.website == website &&
      other.logoPath == logoPath &&
      other.signaturePath == signaturePath;

  @override
  int get hashCode => Object.hash(
        name,
        email,
        phone,
        address,
        taxNumber,
        website,
        logoPath,
        signaturePath,
      );
}
