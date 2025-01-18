import 'dart:convert'; // For JSON encoding and decoding
import 'package:invoicemaker/model/item_model.dart';

class Estimate {
  final String estimateNumber;
  final DateTime creationDate;
  final DateTime dueDate;
  final String estimateTitle;
  final String language;
  final String from;
  final String to;
  final List<Item> items;
  final double subTotal;
  final double discount;
  final String taxName; // New property
  final double tax;
  final double shippingCharges;
  final double total;
  final String currency;
  final int dueTerms;
  final String terms; // New property

  Estimate({
    required this.estimateNumber,
    required this.creationDate,
    required this.dueDate,
    required this.estimateTitle,
    required this.language,
    required this.from,
    required this.to,
    required this.items,
    required this.subTotal,
    required this.discount,
    required this.taxName, // New property
    required this.tax,
    required this.shippingCharges,
    required this.total,
    required this.currency,
    required this.dueTerms,
    required this.terms, // New property
  });

  // Factory constructor to create an instance of Estimate from a JSON map
  factory Estimate.fromJson(Map<String, dynamic> json) {
    return Estimate(
      estimateNumber: json['estimateNumber'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      estimateTitle: json['estimateTitle'] as String,
      language: json['language'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => Item.fromJson(item as Map<String, dynamic>))
          .toList(),
      subTotal: (json['subTotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      taxName: json['taxName'] as String, // New property
      tax: (json['tax'] as num).toDouble(),
      shippingCharges: (json['shippingCharges'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      dueTerms: json['dueTerms'] as int,
      terms: json['terms'] as String, // New property
    );
  }

  // Method to convert an Estimate instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'estimateNumber': estimateNumber,
      'creationDate': creationDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'estimateTitle': estimateTitle,
      'language': language,
      'from': from,
      'to': to,
      'items': items.map((item) => item.toJson()).toList(),
      'subTotal': subTotal,
      'discount': discount,
      'taxName': taxName, // New property
      'tax': tax,
      'shippingCharges': shippingCharges,
      'total': total,
      'currency': currency,
      'dueTerms': dueTerms,
      'terms': terms, // New property
    };
  }

  // Method to create an Estimate instance from a JSON string
  static Estimate fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return Estimate.fromJson(jsonData);
  }

  // Method to convert an Estimate instance into a JSON string
  String toJsonString() {
    final Map<String, dynamic> jsonData = toJson();
    return json.encode(jsonData);
  }

  // CopyWith method for immutability
  Estimate copyWith({
    String? estimateNumber,
    DateTime? creationDate,
    DateTime? dueDate,
    String? estimateTitle,
    String? language,
    String? from,
    String? to,
    List<Item>? items,
    double? subTotal,
    double? discount,
    String? taxName, // New property
    double? tax,
    double? shippingCharges,
    double? total,
    String? currency,
    int? dueTerms,
    String? terms, // New property
  }) {
    return Estimate(
      estimateNumber: estimateNumber ?? this.estimateNumber,
      creationDate: creationDate ?? this.creationDate,
      dueDate: dueDate ?? this.dueDate,
      estimateTitle: estimateTitle ?? this.estimateTitle,
      language: language ?? this.language,
      from: from ?? this.from,
      to: to ?? this.to,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      taxName: taxName ?? this.taxName, // New property
      tax: tax ?? this.tax,
      shippingCharges: shippingCharges ?? this.shippingCharges,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      dueTerms: dueTerms ?? this.dueTerms,
      terms: terms ?? this.terms, // New property
    );
  }
}
