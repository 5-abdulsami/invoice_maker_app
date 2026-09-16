import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/json_read.dart';

/// Whether an adjustment is a percentage or a fixed amount.
enum AdjustmentMode {
  percent('Percentage'),
  amount('Fixed amount');

  const AdjustmentMode(this.label);

  final String label;

  static const AdjustmentMode fallback = AdjustmentMode.percent;

  static AdjustmentMode fromName(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return fallback;
  }
}

/// A document-level discount, expressed either way.
///
/// Small businesses ask for both: "10% off" and "take $50 off". Storing the
/// mode alongside the value keeps the intent, so the printed document can say
/// `Discount (10%)` rather than just showing the resulting cash figure.
@immutable
class Adjustment {
  const Adjustment({required this.mode, required this.value});

  const Adjustment.none()
      : mode = AdjustmentMode.percent,
        value = 0;

  const Adjustment.percent(this.value) : mode = AdjustmentMode.percent;

  const Adjustment.amount(this.value) : mode = AdjustmentMode.amount;

  final AdjustmentMode mode;

  /// A percentage when [mode] is percent, otherwise a cash amount.
  final double value;

  bool get isZero => value <= 0;

  bool get isPercent => mode == AdjustmentMode.percent;

  /// The cash value of this adjustment against [base].
  ///
  /// Never exceeds [base], so a fixed discount larger than the subtotal
  /// cannot produce a negative total.
  double appliedTo(double base) {
    if (isZero || base <= 0) return 0;
    final raw = isPercent ? base * (value / 100) : value;
    return raw > base ? base : raw;
  }

  Adjustment copyWith({AdjustmentMode? mode, double? value}) => Adjustment(
        mode: mode ?? this.mode,
        value: value ?? this.value,
      );

  factory Adjustment.fromJson(JsonMap json) => Adjustment(
        mode: AdjustmentMode.fromName(Json.string(json, 'mode')),
        value: Json.number(json, 'value'),
      );

  JsonMap toJson() => {'mode': mode.name, 'value': value};

  @override
  bool operator ==(Object other) =>
      other is Adjustment && other.mode == mode && other.value == value;

  @override
  int get hashCode => Object.hash(mode, value);
}
