import 'dart:convert';

/// A single billable line on an invoice or estimate.
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unitOfMeasure,
    required this.discount,
    required this.tax,
    required this.description,
    required this.subAmount,
  });

  final String id;
  final String name;
  final double price;
  final int quantity;
  final String unitOfMeasure;

  /// Per-item discount, as a percentage.
  final double discount;

  /// Per-item tax, as a percentage.
  final double tax;
  final String description;

  /// Line total after the item's own discount and tax.
  final double subAmount;

  /// An empty item with a fresh id, used to seed the item forms.
  factory Item.empty() => Item(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '',
        price: 0,
        quantity: 1,
        unitOfMeasure: '',
        discount: 0,
        tax: 0,
        description: '',
        subAmount: 0,
      );

  /// Line total for the given inputs: price x qty, less discount, plus tax.
  static double calculateAmount({
    required double price,
    required int quantity,
    required double discountPercentage,
    required double taxPercentage,
  }) {
    final gross = price * quantity;
    final afterDiscount = gross - (gross * (discountPercentage / 100));
    return afterDiscount + (afterDiscount * (taxPercentage / 100));
  }

  /// Cash value of this line's discount.
  double get discountAmount => price * quantity * (discount / 100);

  /// Cash value of this line's tax.
  double get taxAmount => price * quantity * (tax / 100);

  Item copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? unitOfMeasure,
    double? discount,
    double? tax,
    String? description,
    double? subAmount,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      description: description ?? this.description,
      subAmount: subAmount ?? this.subAmount,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitOfMeasure: json['unitOfMeasure'] as String? ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      subAmount: (json['subAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'unitOfMeasure': unitOfMeasure,
        'discount': discount,
        'tax': tax,
        'description': description,
        'subAmount': subAmount,
      };

  static Item fromJsonString(String jsonString) =>
      Item.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Item($id, $name, $quantity x $price)';
}
