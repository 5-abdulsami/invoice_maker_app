import 'package:flutter/services.dart';

/// Keeps a numeric field to a non-negative decimal, optionally capped.
///
/// Rejecting the keystroke is preferred over rewriting the field, so the
/// caret never jumps while the user is typing.
class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.max, this.decimalPlaces = 2});

  /// Largest accepted value, e.g. 100 for a percentage.
  final double? max;

  /// Digits allowed after the separator; 0 forbids a decimal point.
  final int decimalPlaces;

  late final RegExp _pattern = RegExp(
    decimalPlaces > 0
        ? r'^\d*(\.\d{0,' '$decimalPlaces' r'})?$'
        : r'^\d*$',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Accept a lone separator so "0." can be typed on the way to "0.5".
    if (decimalPlaces > 0 && (text == '.' || text == '0.')) return newValue;
    if (!_pattern.hasMatch(text)) return oldValue;

    final value = double.tryParse(text);
    if (value == null) return oldValue;

    final limit = max;
    if (limit != null && value > limit) {
      // Keep the decimals when clamping; the previous version dropped them.
      final capped = _trimZeros(limit.toStringAsFixed(decimalPlaces));
      return TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    return newValue;
  }

  static String _trimZeros(String text) {
    if (!text.contains('.')) return text;
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

/// Keeps a field to a non-negative whole number.
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

    final limit = max;
    if (limit != null && value > limit) {
      final capped = limit.toString();
      return TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    return newValue;
  }
}

/// Collapses runs of whitespace as the user types, for single-line names.
class CollapseWhitespaceFormatter extends TextInputFormatter {
  const CollapseWhitespaceFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.contains('  ')) return newValue;

    final collapsed = newValue.text.replaceAll(RegExp(r' {2,}'), ' ');
    final removed = newValue.text.length - collapsed.length;
    final offset = (newValue.selection.baseOffset - removed).clamp(
      0,
      collapsed.length,
    );

    return TextEditingValue(
      text: collapsed,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
