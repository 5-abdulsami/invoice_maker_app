import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/app_language.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/item.dart';

/// A bill issued to a client.
class Invoice {
  const Invoice({
    required this.id,
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
    required this.paidAmount,
    required this.template,
  });

  final String id;
  final String invoiceNumber;
  final DateTime creationDate;
  final DateTime dueDate;
  final String invoiceTitle;
  final AppLanguage language;

  /// Business name shown in the "From" block.
  final String from;

  /// Client name shown in the "Bill To" block.
  final String to;
  final List<Item> items;
  final double subTotal;

  /// Invoice-wide discount, as a percentage of [subTotal].
  final double discount;
  final String taxName;

  /// Invoice-wide tax, as a percentage of [subTotal].
  final double tax;
  final double shippingCharges;
  final double total;
  final Currency currency;

  /// Days between [creationDate] and [dueDate].
  final int dueTerms;
  final String poNumber;
  final String terms;
  final String paymentMethod;
  final InvoiceStatus status;
  final double paidAmount;
  final InvoiceTemplate template;

  /// A blank invoice numbered [invoiceNumber], due [dueTermDays] from today.
  factory Invoice.blank({
    required String invoiceNumber,
    Currency currency = Currency.pkr,
    int dueTermDays = 7,
    AppLanguage language = AppLanguage.english,
  }) {
    final now = DateTime.now();
    return Invoice(
      id: now.microsecondsSinceEpoch.toString(),
      invoiceNumber: invoiceNumber,
      creationDate: now,
      dueDate: now.add(Duration(days: dueTermDays)),
      invoiceTitle: '',
      language: language,
      from: '',
      to: '',
      items: const [],
      subTotal: 0,
      discount: 0,
      taxName: '',
      tax: 0,
      shippingCharges: 0,
      total: 0,
      currency: currency,
      dueTerms: dueTermDays,
      poNumber: '',
      terms: '',
      paymentMethod: '',
      status: InvoiceStatus.unpaid,
      paidAmount: 0,
      template: InvoiceTemplate.template1,
    );
  }

  double get discountAmount => subTotal * (discount / 100);

  double get taxAmount => subTotal * (tax / 100);

  /// Total derived from the current lines, discount, tax and shipping.
  double get computedTotal =>
      subTotal - discountAmount + taxAmount + shippingCharges;

  /// Past its due date and not yet settled.
  bool get isOverdue =>
      status != InvoiceStatus.paid && dueDate.isBefore(DateTime.now());

  /// [status], upgraded to [InvoiceStatus.overdue] once the due date passes.
  InvoiceStatus get effectiveStatus =>
      isOverdue ? InvoiceStatus.overdue : status;

  double get balanceDue =>
      status == InvoiceStatus.paid ? 0 : (total - paidAmount).clamp(0, total);

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? creationDate,
    DateTime? dueDate,
    String? invoiceTitle,
    AppLanguage? language,
    String? from,
    String? to,
    List<Item>? items,
    double? subTotal,
    double? discount,
    String? taxName,
    double? tax,
    double? shippingCharges,
    double? total,
    Currency? currency,
    int? dueTerms,
    String? poNumber,
    String? terms,
    String? paymentMethod,
    InvoiceStatus? status,
    double? paidAmount,
    InvoiceTemplate? template,
  }) {
    return Invoice(
      id: id ?? this.id,
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
      paidAmount: paidAmount ?? this.paidAmount,
      template: template ?? this.template,
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      creationDate: DateTime.tryParse(json['creationDate'] as String? ?? '') ??
          DateTime.now(),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      invoiceTitle: json['invoiceTitle'] as String? ?? '',
      language: AppLanguage.fromLabel(json['language'] as String? ?? ''),
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => Item.fromJson(item as Map<String, dynamic>))
          .toList(),
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      taxName: json['taxName'] as String? ?? '',
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      shippingCharges: (json['shippingCharges'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      currency: Currency.fromCode(json['currency'] as String? ?? ''),
      dueTerms: (json['dueTerms'] as num?)?.toInt() ?? 0,
      poNumber: json['poNumber'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      status: InvoiceStatus.fromLabel(json['status'] as String? ?? ''),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      template: InvoiceTemplate.fromIndex(
        (json['template'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'creationDate': creationDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'invoiceTitle': invoiceTitle,
        'language': language.label,
        'from': from,
        'to': to,
        'items': items.map((item) => item.toJson()).toList(),
        'subTotal': subTotal,
        'discount': discount,
        'taxName': taxName,
        'tax': tax,
        'shippingCharges': shippingCharges,
        'total': total,
        'currency': currency.code,
        'dueTerms': dueTerms,
        'poNumber': poNumber,
        'terms': terms,
        'paymentMethod': paymentMethod,
        'status': status.label,
        'paidAmount': paidAmount,
        'template': template.index,
      };

  static Invoice fromJsonString(String jsonString) =>
      Invoice.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == id &&
          other.invoiceNumber == invoiceNumber &&
          other.status == status &&
          other.total == total &&
          other.template == template &&
          listEquals(other.items, items));

  @override
  int get hashCode =>
      Object.hash(id, invoiceNumber, status, total, template, items.length);

  @override
  String toString() => 'Invoice($invoiceNumber, ${status.label}, $total)';
}
