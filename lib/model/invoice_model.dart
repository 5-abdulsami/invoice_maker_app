import 'dart:convert'; // For JSON encoding and decoding
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/pdf_templates/templates.dart';

class Invoice {
  final String id; // New property
  final String invoiceNumber;
  final DateTime creationDate;
  final DateTime dueDate;
  final String invoiceTitle;
  final String language;
  final String from;
  final String to;
  final List<Item> items;
  final double subTotal;
  final double discount;
  final String taxName;
  final double tax;
  final double shippingCharges;
  final double total;
  final String currency;
  int dueTerms;
  final String poNumber;
  final String terms;
  final String paymentMethod;
  String status = "Unpaid"; // Existing property
  final double paidAmount; // New property
  final InvoiceTemplate template;

  Invoice({
    required this.id, // Initialize the new property
    required this.invoiceNumber,
    required this.creationDate,
    required this.dueDate,
    required this.invoiceTitle,
    required this.language,
    required this.from,
    required this.to,
    required this.items,
    required this.subTotal,
    required this.discount,
    required this.taxName,
    required this.tax,
    required this.shippingCharges,
    required this.total,
    required this.currency,
    required this.dueTerms,
    required this.poNumber,
    required this.terms,
    required this.paymentMethod,
    required this.status,
    required this.paidAmount, // Initialize the new property
    required this.template, // Initialize the template
  });

  Invoice copyWith({
    String? id, // Add the new property to copyWith
    String? invoiceNumber,
    DateTime? creationDate,
    DateTime? dueDate,
    String? invoiceTitle,
    String? language,
    String? from,
    String? to,
    List<Item>? items,
    double? subTotal,
    double? discount,
    String? taxName,
    double? tax,
    double? shippingCharges,
    double? total,
    String? currency,
    int? dueTerms,
    String? poNumber,
    String? terms,
    String? paymentMethod,
    String? status,
    double? paidAmount, // Add the new property to copyWith
    InvoiceTemplate? template,
  }) {
    return Invoice(
      id: id ?? this.id, // Initialize the new property
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      creationDate: creationDate ?? this.creationDate,
      dueDate: dueDate ?? this.dueDate,
      invoiceTitle: invoiceTitle ?? this.invoiceTitle,
      language: language ?? this.language,
      from: from ?? this.from,
      to: to ?? this.to,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      taxName: taxName ?? this.taxName,
      tax: tax ?? this.tax,
      shippingCharges: shippingCharges ?? this.shippingCharges,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      dueTerms: dueTerms ?? this.dueTerms,
      poNumber: poNumber ?? this.poNumber,
      terms: terms ?? this.terms,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount, // Initialize the new property
      template: template ?? this.template,
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String, // Parse the new property
      invoiceNumber: json['invoiceNumber'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      invoiceTitle: json['invoiceTitle'] as String,
      language: json['language'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => Item.fromJson(item as Map<String, dynamic>))
          .toList(),
      subTotal: (json['subTotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      taxName: json['taxName'] as String,
      tax: (json['tax'] as num).toDouble(),
      shippingCharges: (json['shippingCharges'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      dueTerms: json['dueTerms'] as int,
      poNumber: json['poNumber'] as String,
      terms: json['terms'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      paidAmount:
          (json['paidAmount'] as num).toDouble(), // Parse the new property
      template:
          InvoiceTemplate.values[json['template']], // Parse the new property
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include the new property in JSON
      'invoiceNumber': invoiceNumber,
      'creationDate': creationDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'invoiceTitle': invoiceTitle,
      'language': language,
      'from': from,
      'to': to,
      'items': items.map((item) => item.toJson()).toList(),
      'subTotal': subTotal,
      'discount': discount,
      'taxName': taxName,
      'tax': tax,
      'shippingCharges': shippingCharges,
      'total': total,
      'currency': currency,
      'dueTerms': dueTerms,
      'poNumber': poNumber,
      'terms': terms,
      'paymentMethod': paymentMethod,
      'status': status,
      'paidAmount': paidAmount, // Include the new property in JSON
      'template': template.index, // Include the new property in JSON
    };
  }

  static Invoice fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return Invoice.fromJson(jsonData);
  }

  String toJsonString() {
    final Map<String, dynamic> jsonData = toJson();
    return json.encode(jsonData);
  }
}
