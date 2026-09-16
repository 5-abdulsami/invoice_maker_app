/// The shape every stored record is decoded from.
typedef JsonMap = Map<String, Object?>;

/// Tolerant readers for decoding stored records.
///
/// A backup file can be hand-edited and an older version of the app may have
/// written a field differently, so every read falls back to a sane default
/// instead of throwing and losing the whole file.
sealed class Json {
  static String string(JsonMap json, String key, {String or = ''}) {
    final value = json[key];
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return or;
  }

  /// A string field that is meaningfully absent when empty.
  static String? stringOrNull(JsonMap json, String key) {
    final value = string(json, key);
    return value.isEmpty ? null : value;
  }

  static double number(JsonMap json, String key, {double or = 0}) {
    final value = json[key];
    if (value is num) return value.isFinite ? value.toDouble() : or;
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null && parsed.isFinite) return parsed;
    }
    return or;
  }

  static int integer(JsonMap json, String key, {int or = 0}) {
    final value = json[key];
    if (value is num) return value.isFinite ? value.toInt() : or;
    if (value is String) return int.tryParse(value) ?? or;
    return or;
  }

  static bool flag(JsonMap json, String key, {bool or = false}) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return or;
  }

  static DateTime date(JsonMap json, String key, {DateTime? or}) {
    final value = json[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return or ?? DateTime.now();
  }

  static DateTime? dateOrNull(JsonMap json, String key) {
    final value = json[key];
    return value is String ? DateTime.tryParse(value) : null;
  }

  /// Nested objects at [key], skipping anything that is not an object.
  static List<JsonMap> objects(JsonMap json, String key) {
    final value = json[key];
    if (value is! List) return const [];

    return value
        .whereType<Map<Object?, Object?>>()
        .map(coerce)
        .toList(growable: false);
  }

  /// A nested object at [key], or null when absent or malformed.
  static JsonMap? object(JsonMap json, String key) {
    final value = json[key];
    return value is Map<Object?, Object?> ? coerce(value) : null;
  }

  /// Narrows a decoded map to [JsonMap], dropping non-string keys.
  static JsonMap coerce(Map<Object?, Object?> value) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is String) result[key] = entry.value;
    }
    return result;
  }
}
