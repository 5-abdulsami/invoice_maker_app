import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/json_read.dart';

/// The name and contact details of one side of a document.
///
/// A document keeps its own copy of both parties. Editing the business
/// profile or a customer afterwards therefore never rewrites history: an
/// invoice always prints the details that were true when it was issued.
@immutable
class PartySnapshot {
  const PartySnapshot({
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.taxNumber = '',
    this.website = '',
  });

  const PartySnapshot.empty()
      : name = '',
        email = '',
        phone = '',
        address = '',
        taxNumber = '',
        website = '';

  final String name;
  final String email;
  final String phone;

  /// Free-form postal address; may contain newlines.
  final String address;

  /// Tax, VAT or GST registration number.
  final String taxNumber;

  final String website;

  bool get isEmpty => name.trim().isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Contact lines to print under the name, omitting the blanks.
  List<String> get contactLines => [
        for (final line in [phone, email, website]) //
          if (line.trim().isNotEmpty) line.trim(),
      ];

  /// Every detail line, address included, for a PDF party block.
  List<String> get detailLines => [
        for (final line in [
          address,
          phone,
          email,
          website,
          if (taxNumber.trim().isNotEmpty) 'Tax No: ${taxNumber.trim()}',
        ])
          if (line.trim().isNotEmpty) line.trim(),
      ];

  PartySnapshot copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? website,
  }) {
    return PartySnapshot(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      website: website ?? this.website,
    );
  }

  factory PartySnapshot.fromJson(JsonMap json) {
    return PartySnapshot(
      name: Json.string(json, 'name'),
      email: Json.string(json, 'email'),
      phone: Json.string(json, 'phone'),
      address: Json.string(json, 'address'),
      taxNumber: Json.string(json, 'taxNumber'),
      website: Json.string(json, 'website'),
    );
  }

  JsonMap toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'taxNumber': taxNumber,
        'website': website,
      };

  @override
  bool operator ==(Object other) =>
      other is PartySnapshot &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.address == address &&
      other.taxNumber == taxNumber &&
      other.website == website;

  @override
  int get hashCode =>
      Object.hash(name, email, phone, address, taxNumber, website);
}
