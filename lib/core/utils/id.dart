import 'dart:math';

/// Generates collision-resistant identifiers for stored records.
///
/// Records used to take their id from `DateTime.now().microsecondsSinceEpoch`,
/// which collides when two are created in the same microsecond. Ids here pair
/// a time prefix, so they sort by creation order, with random entropy.
sealed class Id {
  static final Random _random = Random.secure();

  static const String _alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
  static const int _randomLength = 10;

  /// A new identifier, e.g. `m8f2k1c3-4b7d9a2e10`.
  static String generate() {
    final timePart = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomPart = List.generate(
      _randomLength,
      (_) => _alphabet[_random.nextInt(_alphabet.length)],
    ).join();
    return '$timePart-$randomPart';
  }
}
