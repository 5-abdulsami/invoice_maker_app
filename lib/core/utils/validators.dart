import 'package:invoicemaker/core/constants/app_strings.dart';

/// Form validation and the parsing of typed numbers.
///
/// Validators return null when the value is acceptable, matching the contract
/// `TextFormField.validator` expects.
sealed class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Requires some non-whitespace text.
  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? AppCopy.requiredField : null;

  /// Requires text, naming the field in the message.
  static String? requiredNamed(String? value, String fieldLabel) =>
      (value == null || value.trim().isEmpty) ? '$fieldLabel is required' : null;

  /// Accepts an empty value, or a plausible email address.
  static String? optionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _email.hasMatch(text) ? null : AppCopy.invalidEmail;
  }

  /// Accepts an empty value, or a non-negative number.
  static String? optionalAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return AppCopy.invalidAmount;
    }
    return null;
  }

  /// Requires a quantity greater than zero.
  static String? quantity(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return 'Enter a quantity above zero';
    }
    return null;
  }

  /// Parses a non-negative amount, clamped to [max] when given.
  static double parseAmount(String? value, {double? max}) {
    final parsed = double.tryParse(value?.trim() ?? '') ?? 0;
    if (!parsed.isFinite || parsed < 0) return 0;
    if (max != null && parsed > max) return max;
    return parsed;
  }

  /// Parses a quantity, never returning zero or less.
  static double parseQuantity(String? value, {double fallback = 1}) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || !parsed.isFinite || parsed <= 0) return fallback;
    return parsed;
  }

  /// Parses a percentage into the range `0..100`.
  static double parsePercent(String? value) =>
      parseAmount(value, max: maxPercent);

  /// Parses a whole number of days, never negative.
  static int parseDays(String? value, {int fallback = 0}) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) return fallback;
    return parsed;
  }

  /// The largest accepted percentage.
  static const double maxPercent = 100;
}
