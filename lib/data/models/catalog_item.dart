import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/utils/id.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/models/line_item.dart';

/// A product or service the user sells, saved for reuse.
@immutable
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.unit = '',
    this.unitPrice = 0,
    this.defaultDiscountPercent = 0,
    this.defaultTaxPercent,
  });

  factory CatalogItem.create({
    required String name,
    String description = '',
    String unit = '',
    double unitPrice = 0,
    double defaultDiscountPercent = 0,
    double? defaultTaxPercent,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return CatalogItem(
      id: Id.generate(),
      name: name,
      description: description,
      unit: unit,
      unitPrice: unitPrice,
      defaultDiscountPercent: defaultDiscountPercent,
      defaultTaxPercent: defaultTaxPercent,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  final String id;
  final String name;
  final String description;

  /// Unit of measure, e.g. `hr`, `kg`, `pcs`.
  final String unit;

  final double unitPrice;

  /// Discount applied by default when this item is added to a document.
  final double defaultDiscountPercent;

  /// Tax rate applied by default; null means the document's own rate.
  final double? defaultTaxPercent;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Turns this saved item into a document row.
  LineItem toLineItem({double quantity = 1}) => LineItem.create(
        name: name,
        description: description,
        unit: unit,
        quantity: quantity,
        unitPrice: unitPrice,
        discountPercent: defaultDiscountPercent,
        taxPercent: defaultTaxPercent,
        catalogItemId: id,
      );

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return name.toLowerCase().contains(needle) ||
        description.toLowerCase().contains(needle) ||
        unit.toLowerCase().contains(needle);
  }

  CatalogItem copyWith({
    String? name,
    String? description,
    String? unit,
    double? unitPrice,
    double? defaultDiscountPercent,
    double? defaultTaxPercent,
    bool clearDefaultTaxPercent = false,
    DateTime? updatedAt,
  }) {
    return CatalogItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      defaultDiscountPercent:
          defaultDiscountPercent ?? this.defaultDiscountPercent,
      defaultTaxPercent: clearDefaultTaxPercent
          ? null
          : (defaultTaxPercent ?? this.defaultTaxPercent),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory CatalogItem.fromJson(JsonMap json) {
    final created = Json.date(json, 'createdAt');
    return CatalogItem(
      id: Json.stringOrNull(json, 'id') ?? Id.generate(),
      name: Json.string(json, 'name'),
      description: Json.string(json, 'description'),
      unit: Json.string(json, 'unit'),
      unitPrice: Json.number(json, 'unitPrice'),
      defaultDiscountPercent: Json.number(json, 'defaultDiscountPercent'),
      defaultTaxPercent: json['defaultTaxPercent'] == null
          ? null
          : Json.number(json, 'defaultTaxPercent'),
      createdAt: created,
      updatedAt: Json.date(json, 'updatedAt', or: created),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'unit': unit,
        'unitPrice': unitPrice,
        'defaultDiscountPercent': defaultDiscountPercent,
        'defaultTaxPercent': defaultTaxPercent,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is CatalogItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
