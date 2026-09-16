import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/utils/id.dart';
import 'package:invoicemaker/data/models/json_read.dart';

/// One billable row on a document.
///
/// Money is never stored pre-calculated: the row keeps only what the user
/// typed and every figure derives from it, so a line total can never
/// contradict its own quantity and price.
@immutable
class LineItem {
  const LineItem({
    required this.id,
    required this.name,
    this.description = '',
    this.unit = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.discountPercent = 0,
    this.taxPercent,
    this.catalogItemId,
  });

  factory LineItem.create({
    required String name,
    String description = '',
    String unit = '',
    double quantity = 1,
    double unitPrice = 0,
    double discountPercent = 0,
    double? taxPercent,
    String? catalogItemId,
  }) {
    return LineItem(
      id: Id.generate(),
      name: name,
      description: description,
      unit: unit,
      quantity: quantity,
      unitPrice: unitPrice,
      discountPercent: discountPercent,
      taxPercent: taxPercent,
      catalogItemId: catalogItemId,
    );
  }

  final String id;
  final String name;
  final String description;

  /// Unit of measure shown beside the quantity, e.g. `hr` or `kg`.
  final String unit;

  /// Fractional quantities are supported, e.g. 2.5 hours.
  final double quantity;

  final double unitPrice;

  /// Row-level discount, as a percentage of the row's gross amount.
  final double discountPercent;

  /// Row-level tax rate. Null means "use the document's rate", which keeps a
  /// single-rate document simple while still allowing mixed rates.
  final double? taxPercent;

  /// The saved item this row came from, when it came from the catalogue.
  final String? catalogItemId;

  /// Quantity times unit price, before any discount.
  double get grossAmount => quantity * unitPrice;

  double get discountAmount => grossAmount * (discountPercent / 100);

  /// What this row contributes to the subtotal: gross less its own discount,
  /// and always before tax.
  double get netAmount => grossAmount - discountAmount;

  bool get hasOwnTaxRate => taxPercent != null;

  /// The rate that applies, given the document's default.
  double effectiveTaxPercent(double documentTaxPercent) =>
      taxPercent ?? documentTaxPercent;

  /// The quantity without a trailing `.0`, e.g. `2` or `2.5`.
  String get quantityLabel {
    final rounded = double.parse(quantity.toStringAsFixed(2));
    return rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toString();
  }

  /// `2 hr` when a unit is set, otherwise just the quantity.
  String get quantityWithUnit =>
      unit.trim().isEmpty ? quantityLabel : '$quantityLabel ${unit.trim()}';

  LineItem copyWith({
    String? name,
    String? description,
    String? unit,
    double? quantity,
    double? unitPrice,
    double? discountPercent,
    double? taxPercent,
    bool clearTaxPercent = false,
    String? catalogItemId,
  }) {
    return LineItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: clearTaxPercent ? null : (taxPercent ?? this.taxPercent),
      catalogItemId: catalogItemId ?? this.catalogItemId,
    );
  }

  /// A copy with a new id, used when duplicating a document.
  LineItem withNewId() => LineItem(
        id: Id.generate(),
        name: name,
        description: description,
        unit: unit,
        quantity: quantity,
        unitPrice: unitPrice,
        discountPercent: discountPercent,
        taxPercent: taxPercent,
        catalogItemId: catalogItemId,
      );

  factory LineItem.fromJson(JsonMap json) {
    return LineItem(
      id: Json.stringOrNull(json, 'id') ?? Id.generate(),
      name: Json.string(json, 'name'),
      description: Json.string(json, 'description'),
      unit: Json.string(json, 'unit'),
      quantity: Json.number(json, 'quantity', or: 1),
      unitPrice: Json.number(json, 'unitPrice'),
      discountPercent: Json.number(json, 'discountPercent'),
      taxPercent: json['taxPercent'] == null
          ? null
          : Json.number(json, 'taxPercent'),
      catalogItemId: Json.stringOrNull(json, 'catalogItemId'),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'unit': unit,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discountPercent': discountPercent,
        'taxPercent': taxPercent,
        'catalogItemId': catalogItemId,
      };

  @override
  bool operator ==(Object other) =>
      other is LineItem &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.unit == unit &&
      other.quantity == quantity &&
      other.unitPrice == unitPrice &&
      other.discountPercent == discountPercent &&
      other.taxPercent == taxPercent;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        unit,
        quantity,
        unitPrice,
        discountPercent,
        taxPercent,
      );
}
