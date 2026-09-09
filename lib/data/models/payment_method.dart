import 'dart:convert';

/// A saved set of payment instructions, printed on the invoice.
class PaymentMethod {
  const PaymentMethod({required this.details, this.isSelected = false});

  final String details;
  final bool isSelected;

  PaymentMethod copyWith({String? details, bool? isSelected}) => PaymentMethod(
        details: details ?? this.details,
        isSelected: isSelected ?? this.isSelected,
      );

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        details: json['details'] as String? ?? '',
        isSelected: json['isSelected'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'details': details,
        'isSelected': isSelected,
      };

  static PaymentMethod fromJsonString(String jsonString) =>
      PaymentMethod.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.details == details &&
          other.isSelected == isSelected);

  @override
  int get hashCode => Object.hash(details, isSelected);

  @override
  String toString() => 'PaymentMethod($details, selected: $isSelected)';
}
