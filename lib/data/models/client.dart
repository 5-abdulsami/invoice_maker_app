import 'dart:convert';

/// Someone an invoice is billed to.
class Client {
  const Client({
    required this.id,
    required this.name,
    required this.emailAddress,
    required this.phone,
    required this.billingAddress,
    required this.shippingAddress,
    required this.detail,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String emailAddress;
  final String phone;
  final String billingAddress;
  final String shippingAddress;

  /// Private note, never rendered on the invoice.
  final String detail;

  /// Whether this client is the one currently chosen for an invoice.
  final bool isSelected;

  factory Client.empty() => Client(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '',
        emailAddress: '',
        phone: '',
        billingAddress: '',
        shippingAddress: '',
        detail: '',
      );

  Client copyWith({
    String? id,
    String? name,
    String? emailAddress,
    String? phone,
    String? billingAddress,
    String? shippingAddress,
    String? detail,
    bool? isSelected,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      emailAddress: emailAddress ?? this.emailAddress,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      detail: detail ?? this.detail,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      billingAddress: json['billingAddress'] as String? ?? '',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emailAddress': emailAddress,
        'phone': phone,
        'billingAddress': billingAddress,
        'shippingAddress': shippingAddress,
        'detail': detail,
        'isSelected': isSelected,
      };

  static Client fromJsonString(String jsonString) =>
      Client.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Client && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Client($id, $name)';
}
