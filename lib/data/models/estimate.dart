import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/app_language.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/estimate_status.dart';
import 'package:invoicemaker/data/models/item.dart';

/// A quote sent to a client before any invoice is raised.
class Estimate {
  const Estimate({
    required this.id,
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
    required this.taxName,
    required this.tax,
    required this.shippingCharges,
    required this.total,
    required this.currency,
    required this.dueTerms,
    required this.terms,
    required this.status,
  });

  /// Unique identifier, so an estimate can be edited and deleted.
  final String id;
  final String estimateNumber;
  final DateTime creationDate;
  final DateTime dueDate;
  final String estimateTitle;
  final AppLanguage language;
  final String from;
  final String to;
  final List<Item> items;
  final double subTotal;

  /// Estimate-wide discount, as a percentage of [subTotal].
  final double discount;
  final String taxName;

  /// Estimate-wide tax, as a percentage of [subTotal].
  final double tax;
  final double shippingCharges;
  final double total;
  final Currency currency;
  final int dueTerms;
  final String terms;
  final EstimateStatus status;

  factory Estimate.blank({
    required String estimateNumber,
    Currency currency = Currency.pkr,
    int dueTermDays = 7,
    AppLanguage language = AppLanguage.english,
  }) {
    final now = DateTime.now();
    return Estimate(
      id: now.microsecondsSinceEpoch.toString(),
      estimateNumber: estimateNumber,
      creationDate: now,
      dueDate: now.add(Duration(days: dueTermDays)),
      estimateTitle: '',
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
      terms: '',
      status: EstimateStatus.pending,
    );
  }

  double get discountAmount => subTotal * (discount / 100);

  double get taxAmount => subTotal * (tax / 100);

  double get computedTotal =>
      subTotal - discountAmount + taxAmount + shippingCharges;

  bool get isOverdue =>
      status == EstimateStatus.pending && dueDate.isBefore(DateTime.now());

  Estimate copyWith({
    String? id,
    String? estimateNumber,
    DateTime? creationDate,
    DateTime? dueDate,
    String? estimateTitle,
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
    String? terms,
    EstimateStatus? status,
  }) {
    return Estimate(
      id: id ?? this.id,
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
      taxName: taxName ?? this.taxName,
      tax: tax ?? this.tax,
      shippingCharges: shippingCharges ?? this.shippingCharges,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      dueTerms: dueTerms ?? this.dueTerms,
      terms: terms ?? this.terms,
      status: status ?? this.status,
    );
  }

  factory Estimate.fromJson(Map<String, dynamic> json) {
    return Estimate(
      id: json['id'] as String? ?? '',
      estimateNumber: json['estimateNumber'] as String? ?? '',
      creationDate: DateTime.tryParse(json['creationDate'] as String? ?? '') ??
          DateTime.now(),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      estimateTitle: json['estimateTitle'] as String? ?? '',
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
      terms: json['terms'] as String? ?? '',
      status: EstimateStatus.fromLabel(json['status'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'estimateNumber': estimateNumber,
        'creationDate': creationDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'estimateTitle': estimateTitle,
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
        'terms': terms,
        'status': status.label,
      };

  static Estimate fromJsonString(String jsonString) =>
      Estimate.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Estimate &&
          other.id == id &&
          other.estimateNumber == estimateNumber &&
          other.status == status &&
          other.total == total &&
          listEquals(other.items, items));

  @override
  int get hashCode =>
      Object.hash(id, estimateNumber, status, total, items.length);

  @override
  String toString() => 'Estimate($estimateNumber, ${status.label}, $total)';
}
