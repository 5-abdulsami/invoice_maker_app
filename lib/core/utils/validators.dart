/// Input rules shared by the forms and numeric dialogs.
sealed class Validators {
  static final RegExp _decimal = RegExp(r'^\d*\.?\d*$');

  /// True when [value] is empty or a well-formed non-negative decimal.
  static bool isNonNegativeDecimal(String value) =>
      value.isEmpty || _decimal.hasMatch(value);

  /// Parses a non-negative amount, clamped to [max] when one is given.
  static double parseAmount(String value, {double? max}) {
    final parsed = double.tryParse(value) ?? 0;
    if (parsed < 0) return 0;
    if (max != null && parsed > max) return max;
    return parsed;
  }

  /// Parses a quantity, never below one.
  static int parseQuantity(String value) {
    final parsed = int.tryParse(value) ?? 1;
    return parsed < 1 ? 1 : parsed;
  }

  static String? requiredField(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;
}
