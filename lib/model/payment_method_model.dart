class PaymentMethod {
  String details = '';
  bool? isSelected;

  PaymentMethod({required this.details, this.isSelected = false});

  PaymentMethod copyWith({String? details, bool? isSelected}) {
    return PaymentMethod(
        details: details ?? this.details,
        isSelected: isSelected ?? this.isSelected);
  }
}
