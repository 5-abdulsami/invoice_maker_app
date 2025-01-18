import 'dart:convert'; // For JSON encoding and decoding

class Client {
  final String id; // Unique identifier for the client
  final String name;
  final String emailAddress;
  final String phone;
  final String billingAddress;
  final String shippingAddress;
  final String detail;
  final bool isSelected; // New property to track selection state

  Client({
    required this.id,
    required this.name,
    required this.emailAddress,
    required this.phone,
    required this.billingAddress,
    required this.shippingAddress,
    required this.detail,
    this.isSelected = false, // Default value is false
  });

  // CopyWith Constructor
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

  // Factory constructor to create an instance of Client from a JSON map
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String, // Extract the id from the JSON map
      name: json['name'] as String,
      emailAddress: json['emailAddress'] as String,
      phone: json['phone'] as String,
      billingAddress: json['billingAddress'] as String,
      shippingAddress: json['shippingAddress'] as String,
      detail: json['detail'] as String,
      isSelected: json['isSelected'] as bool? ?? false, // Handle null value
    );
  }

  // Method to convert a Client instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include the id in the JSON map
      'name': name,
      'emailAddress': emailAddress,
      'phone': phone,
      'billingAddress': billingAddress,
      'shippingAddress': shippingAddress,
      'detail': detail,
      'isSelected': isSelected,
    };
  }

  // Method to create a Client instance from a JSON string
  static Client fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return Client.fromJson(jsonData);
  }

  // Method to convert a Client instance into a JSON string
  String toJsonString() {
    final Map<String, dynamic> jsonData = toJson();
    return json.encode(jsonData);
  }
}
