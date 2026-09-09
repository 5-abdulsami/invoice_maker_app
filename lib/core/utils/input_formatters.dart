import 'package:flutter/services.dart';

/// Accepts only a non-negative decimal, optionally capped at [max].
///
/// Replaces the hand-rolled `onChanged` clearing logic the numeric fields and
/// dialogs each carried a copy of.
class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.max, this.decimalPlaces = 2});

  /// Largest accepted value, e.g. 100 for a percentage.
  final double? max;
  final int decimalPlaces;

  late final RegExp _pattern =
      RegExp(r'^\d*' + (decimalPlaces > 0 ? r'\.?\d{0,' '$decimalPlaces' r'}$' : r'$'));

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!_pattern.hasMatch(text)) return oldValue;

    final value = double.tryParse(text);
    if (value == null) return text == '.' ? oldValue : newValue;
    if (max != null && value > max!) {
      final capped = max!.toStringAsFixed(0);
      return TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    return newValue;
  }
}

/// Accepts only a positive whole number.
class IntegerInputFormatter extends TextInputFormatter {
  IntegerInputFormatter({this.max});

  final int? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final value = int.tryParse(text);
    if (value == null || value < 0) return oldValue;
    if (max != null && value > max!) {
      final capped = max.toString();
      return TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    return newValue;
  }
}
