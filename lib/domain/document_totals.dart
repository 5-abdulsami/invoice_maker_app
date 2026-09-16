import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/line_item.dart';

/// One row's resolved figures.
@immutable
class LineTotal {
  const LineTotal({
    required this.line,
    required this.netAmount,
    required this.taxPercent,
    required this.taxAmount,
  });

  final LineItem line;

  /// Quantity times price, less the row's own discount, rounded.
  final double netAmount;

  /// The rate actually applied, after falling back to the document's rate.
  final double taxPercent;

  /// Tax on this row, charged on its share of the discounted subtotal.
  final double taxAmount;
}

/// Every money figure on a document, derived from its inputs.
///
/// This is the only place the arithmetic lives: the forms, the list cards, the
/// detail screen and all eight PDF templates read the same instance, so a
/// figure can never differ between the screen and the printed page.
///
/// The order of operations is: row discount, then the document discount, then
/// tax on the discounted amounts, then shipping.
@immutable
class DocumentTotals {
  const DocumentTotals({
    required this.currency,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.discountAmount,
    required this.discountedSubtotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.shipping,
    required this.total,
    required this.amountPaid,
    required this.balanceDue,
  });

  /// Computes the breakdown.
  ///
  /// [isFullyPaid] settles the document regardless of [amountPaid], which is
  /// how a "paid" invoice reports a zero balance without having to store a
  /// figure that duplicates the total.
  factory DocumentTotals.compute({
    required List<LineItem> lines,
    required Adjustment discount,
    required double taxPercent,
    required double shipping,
    required Currency currency,
    double amountPaid = 0,
    bool isFullyPaid = false,
  }) {
    double round(double value) => Money.roundFor(value, currency);

    final rawSubtotal = lines.fold<double>(
      0,
      (sum, line) => sum + line.netAmount,
    );

    final subtotal = round(rawSubtotal);
    final discountAmount = round(discount.appliedTo(subtotal));
    final discountedSubtotal = round(subtotal - discountAmount);

    // The document discount is shared across the rows in proportion to their
    // size, so the per-row tax figures add up to the document's tax total.
    final taxableShare = rawSubtotal <= 0
        ? 0.0
        : (rawSubtotal - discount.appliedTo(rawSubtotal)) / rawSubtotal;

    final lineTotals = <LineTotal>[];
    var taxTotal = 0.0;

    for (final line in lines) {
      final rate = line.effectiveTaxPercent(taxPercent);
      final taxable = line.netAmount * taxableShare;
      final tax = round(taxable * (rate / 100));

      taxTotal += tax;
      lineTotals.add(
        LineTotal(
          line: line,
          netAmount: round(line.netAmount),
          taxPercent: rate,
          taxAmount: tax,
        ),
      );
    }

    final taxAmount = round(taxTotal);
    final shippingAmount = round(Money.clampPositive(shipping));
    final total = round(discountedSubtotal + taxAmount + shippingAmount);

    final paid = isFullyPaid
        ? total
        : round(Money.clampPositive(amountPaid, max: total));

    return DocumentTotals(
      currency: currency,
      lines: List.unmodifiable(lineTotals),
      subtotal: subtotal,
      discount: discount,
      discountAmount: discountAmount,
      discountedSubtotal: discountedSubtotal,
      taxPercent: taxPercent,
      taxAmount: taxAmount,
      shipping: shippingAmount,
      total: total,
      amountPaid: paid,
      balanceDue: round(total - paid),
    );
  }

  final Currency currency;
  final List<LineTotal> lines;

  /// Sum of the row net amounts.
  final double subtotal;

  /// The document-level discount as the user expressed it.
  final Adjustment discount;

  /// Cash value of the document-level discount.
  final double discountAmount;

  final double discountedSubtotal;

  /// The document's default tax rate; individual rows may override it.
  final double taxPercent;

  final double taxAmount;
  final double shipping;
  final double total;
  final double amountPaid;
  final double balanceDue;

  bool get hasLines => lines.isNotEmpty;
  bool get hasDiscount => discountAmount > 0;
  bool get hasTax => taxAmount > 0;
  bool get hasShipping => shipping > 0;
  bool get hasPayment => amountPaid > 0;
  bool get isSettled => balanceDue <= 0 && total > 0;

  /// True when rows carry differing tax rates, so the summary should not
  /// claim a single document-wide rate.
  bool get hasMixedTaxRates {
    if (lines.length < 2) return false;
    final first = lines.first.taxPercent;
    return lines.any((line) => line.taxPercent != first);
  }

  /// The single rate to show beside the tax row, or null when rates differ.
  double? get uniformTaxRate {
    if (lines.isEmpty) return taxPercent;
    return hasMixedTaxRates ? null : lines.first.taxPercent;
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentTotals &&
      other.currency == currency &&
      other.subtotal == subtotal &&
      other.discountAmount == discountAmount &&
      other.taxAmount == taxAmount &&
      other.shipping == shipping &&
      other.total == total &&
      other.amountPaid == amountPaid &&
      other.lines.length == lines.length;

  @override
  int get hashCode => Object.hash(
        currency,
        subtotal,
        discountAmount,
        taxAmount,
        shipping,
        total,
        amountPaid,
        lines.length,
      );
}
