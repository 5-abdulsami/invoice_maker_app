import 'dart:convert'; // For JSON encoding and decoding
import 'dart:io'; // For File handling

class Business {
  final File? businessLogo;
  final String businessName;
  final String emailAddress;
  final String phone;
  final String billingAddress;
  final String website;

  Business({
    required this.businessLogo,
    required this.businessName,
    required this.emailAddress,
    required this.phone,
    required this.billingAddress,
    required this.website,
  });

  //Copy With Constructor
  Business copyWith({
    File? businessLogo,
    String? businessName,
    String? emailAddress,
    String? phone,
    String? billingAddress,
    String? website,
  }) {
    return Business(
      businessLogo: businessLogo ?? this.businessLogo,
      businessName: businessName ?? this.businessName,
      emailAddress: emailAddress ?? this.emailAddress,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      website: website ?? this.website,
    );
  }

  // Factory constructor to create an instance of Business from a JSON map
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      businessLogo:
          json['businessLogo'] != null ? File(json['businessLogo']) : null,
      businessName: json['businessName'] as String,
      emailAddress: json['emailAddress'] as String,
      phone: json['phone'] as String,
      billingAddress: json['billingAddress'] as String,
      website: json['website'] as String,
    );
  }

  // Method to convert a Business instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'businessLogo': businessLogo?.path,
      'businessName': businessName,
      'emailAddress': emailAddress,
      'phone': phone,
      'billingAddress': billingAddress,
      'website': website,
    };
  }

  // Method to create a Business instance from a JSON string
  static Business fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return Business.fromJson(jsonData);
  }

  // Method to convert a Business instance into a JSON string
  String toJsonString() {
    final Map<String, dynamic> jsonData = toJson();
    return json.encode(jsonData);
  }
}
