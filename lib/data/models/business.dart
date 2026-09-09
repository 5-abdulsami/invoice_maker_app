import 'dart:convert';

/// The user's own company details, shown in the "From" block.
class Business {
  const Business({
    required this.businessName,
    required this.emailAddress,
    required this.phone,
    required this.billingAddress,
    required this.website,
    this.logoPath,
  });

  /// Filesystem path of the chosen logo. Null when no logo is set.
  final String? logoPath;
  final String businessName;
  final String emailAddress;
  final String phone;
  final String billingAddress;
  final String website;

  const Business.empty()
      : logoPath = null,
        businessName = '',
        emailAddress = '',
        phone = '',
        billingAddress = '',
        website = '';

  bool get hasLogo => logoPath != null && logoPath!.isNotEmpty;

  /// Pass [clearLogo] to remove an existing logo, since passing null to
  /// [logoPath] keeps the current value.
  Business copyWith({
    String? logoPath,
    String? businessName,
    String? emailAddress,
    String? phone,
    String? billingAddress,
    String? website,
    bool clearLogo = false,
  }) {
    return Business(
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      businessName: businessName ?? this.businessName,
      emailAddress: emailAddress ?? this.emailAddress,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      website: website ?? this.website,
    );
  }

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      logoPath: json['logoPath'] as String?,
      businessName: json['businessName'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      billingAddress: json['billingAddress'] as String? ?? '',
      website: json['website'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'logoPath': logoPath,
        'businessName': businessName,
        'emailAddress': emailAddress,
        'phone': phone,
        'billingAddress': billingAddress,
        'website': website,
      };

  static Business fromJsonString(String jsonString) =>
      Business.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Business &&
          other.logoPath == logoPath &&
          other.businessName == businessName &&
          other.emailAddress == emailAddress &&
          other.phone == phone &&
          other.billingAddress == billingAddress &&
          other.website == website);

  @override
  int get hashCode => Object.hash(
        logoPath,
        businessName,
        emailAddress,
        phone,
        billingAddress,
        website,
      );

  @override
  String toString() => 'Business($businessName)';
}
