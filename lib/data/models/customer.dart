import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/utils/id.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';

/// Someone the user bills, saved for reuse.
@immutable
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.taxNumber = '',
    this.notes = '',
  });

  /// A new customer with a fresh id and timestamps.
  factory Customer.create({
    required String name,
    String email = '',
    String phone = '',
    String address = '',
    String taxNumber = '',
    String notes = '',
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return Customer(
      id: Id.generate(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      taxNumber: taxNumber,
      notes: notes,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String taxNumber;

  /// Private note, never printed on a document.
  final String notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// The single line shown under the name in a list.
  String get subtitle {
    for (final line in [email, phone, address]) {
      if (line.trim().isNotEmpty) return line.trim();
    }
    return '';
  }

  /// Freezes these details onto a document.
  PartySnapshot toSnapshot() => PartySnapshot(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
        taxNumber: taxNumber.trim(),
      );

  /// True when [query] appears in any searchable field.
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return name.toLowerCase().contains(needle) ||
        email.toLowerCase().contains(needle) ||
        phone.toLowerCase().contains(needle) ||
        address.toLowerCase().contains(needle) ||
        notes.toLowerCase().contains(needle);
  }

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Customer.fromJson(JsonMap json) {
    final created = Json.date(json, 'createdAt');
    return Customer(
      id: Json.stringOrNull(json, 'id') ?? Id.generate(),
      name: Json.string(json, 'name'),
      email: Json.string(json, 'email'),
      phone: Json.string(json, 'phone'),
      address: Json.string(json, 'address'),
      taxNumber: Json.string(json, 'taxNumber'),
      notes: Json.string(json, 'notes'),
      createdAt: created,
      updatedAt: Json.date(json, 'updatedAt', or: created),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'taxNumber': taxNumber,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is Customer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
