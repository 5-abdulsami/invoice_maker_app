import 'dart:convert';

class Item {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String unitOfMeasure;
  final double discount;
  final double tax;
  final String description;
  final double subAmount;

  Item({
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

  // CopyWith method to create a new instance with updated values
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

  // Factory constructor to create an instance of Item from a JSON map
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      unitOfMeasure: json['unitOfMeasure'] as String,
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      description: json['description'] as String,
      subAmount: (json['subAmount'] as num).toDouble(),
    );
  }

  // Method to convert an Item instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
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
  }

  // Method to create an Item instance from a JSON string
  static Item fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return Item.fromJson(jsonData);
  }

  // Method to convert an Item instance into a JSON string
  String toJsonString() {
    final Map<String, dynamic> jsonData = toJson();
    return json.encode(jsonData);
  }
}
