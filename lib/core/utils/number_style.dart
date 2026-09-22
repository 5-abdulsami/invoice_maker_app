import 'package:flutter/foundation.dart';

/// How the digits of an amount are separated, e.g. `1,234.56` or `1.234,56`.
@immutable
class NumberStyle {
  const NumberStyle({
    required this.groupSeparator,
    required this.decimalSeparator,
    this.usesLakhGrouping = false,
  });

  /// `1,234.56`: the US, UK, Pakistan, Japan, the Gulf and most of Asia.
  static const NumberStyle commaDot =
      NumberStyle(groupSeparator: ',', decimalSeparator: '.');

  /// `1.234,56`: most of the eurozone, Indonesia, Vietnam, Turkey and much
  /// of Latin America.
  static const NumberStyle dotComma =
      NumberStyle(groupSeparator: '.', decimalSeparator: ',');

  /// `1 234.56`.
  static const NumberStyle spaceDot =
      NumberStyle(groupSeparator: ' ', decimalSeparator: '.');

  /// `1 234,56`: Scandinavia, Poland and South Africa.
  static const NumberStyle spaceComma =
      NumberStyle(groupSeparator: ' ', decimalSeparator: ',');

  /// `1'234.56`: Switzerland.
  static const NumberStyle apostropheDot =
      NumberStyle(groupSeparator: "'", decimalSeparator: '.');

  /// `1234.56`: no grouping.
  static const NumberStyle plainDot =
      NumberStyle(groupSeparator: '', decimalSeparator: '.');

  /// `1,00,000.00`: India, Bangladesh and Nepal, grouped in lakhs and crores.
  static const NumberStyle lakh = NumberStyle(
    groupSeparator: ',',
    decimalSeparator: '.',
    usesLakhGrouping: true,
  );

  /// Thousands separator; empty when digits are not grouped.
  final String groupSeparator;

  final String decimalSeparator;

  /// Groups the last three digits, then every two: `12,34,567`.
  final bool usesLakhGrouping;

  /// Applies the separators to a plain unsigned number such as `1234.56`.
  String apply(String plain) {
    final point = plain.indexOf('.');
    final integer = point == -1 ? plain : plain.substring(0, point);
    final grouped = _group(integer);
    return point == -1
        ? grouped
        : '$grouped$decimalSeparator${plain.substring(point + 1)}';
  }

  String _group(String digits) {
    if (groupSeparator.isEmpty || digits.length <= 3) return digits;

    // Split off the last three digits; the rest is grouped in twos for the
    // lakh system and in threes otherwise.
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final size = usesLakhGrouping ? 2 : 3;

    final groups = <String>[];
    for (var end = head.length; end > 0; end -= size) {
      groups.add(head.substring(end - size < 0 ? 0 : end - size, end));
    }

    return [...groups.reversed, tail].join(groupSeparator);
  }
}
