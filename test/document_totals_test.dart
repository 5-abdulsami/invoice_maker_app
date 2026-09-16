import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/domain/document_totals.dart';

LineItem _line({
  required String name,
  double quantity = 1,
  double unitPrice = 0,
  double discountPercent = 0,
  double? taxPercent,
}) {
  return LineItem(
    id: name,
    name: name,
    quantity: quantity,
    unitPrice: unitPrice,
    discountPercent: discountPercent,
    taxPercent: taxPercent,
  );
}

DocumentTotals _totals({
  List<LineItem>? lines,
  Adjustment discount = const Adjustment.none(),
  double taxPercent = 0,
  double shipping = 0,
  Currency currency = Currency.usd,
  double amountPaid = 0,
  bool isFullyPaid = false,
}) {
  return DocumentTotals.compute(
    lines: lines ?? const [],
    discount: discount,
    taxPercent: taxPercent,
    shipping: shipping,
    currency: currency,
    amountPaid: amountPaid,
    isFullyPaid: isFullyPaid,
  );
}

void main() {
  group('line arithmetic', () {
    test('applies the row discount before tax', () {
      final line = _line(
        name: 'Design',
        quantity: 2,
        unitPrice: 100,
        discountPercent: 10,
      );

      expect(line.grossAmount, 200);
      expect(line.discountAmount, 20);
      expect(line.netAmount, 180);
    });

    test('supports a fractional quantity', () {
      final line = _line(name: 'Hours', quantity: 2.5, unitPrice: 40);

      expect(line.netAmount, 100);
      expect(line.quantityLabel, '2.5');
    });

    test('formats a whole quantity without a decimal', () {
      expect(_line(name: 'x', quantity: 3).quantityLabel, '3');
    });
  });

  group('document totals', () {
    test('sums the row nets into the subtotal', () {
      final totals = _totals(
        lines: [
          _line(name: 'a', quantity: 2, unitPrice: 100, discountPercent: 10),
          _line(name: 'b', unitPrice: 50),
        ],
      );

      expect(totals.subtotal, 230);
      expect(totals.total, 230);
    });

    test('charges tax on the discounted amounts, per row rate', () {
      final totals = _totals(
        lines: [
          // Falls back to the document rate of 5%.
          _line(name: 'a', quantity: 2, unitPrice: 100, discountPercent: 10),
          // Overrides it with 20%.
          _line(name: 'b', unitPrice: 50, taxPercent: 20),
        ],
        discount: const Adjustment.percent(10),
        taxPercent: 5,
        shipping: 10,
      );

      expect(totals.subtotal, 230);
      expect(totals.discountAmount, 23);
      expect(totals.discountedSubtotal, 207);
      // 180 * 0.9 * 5% = 8.10, plus 50 * 0.9 * 20% = 9.00.
      expect(totals.taxAmount, 17.10);
      expect(totals.total, 234.10);
    });

    test('per-row tax figures add up to the document tax', () {
      final totals = _totals(
        lines: [
          _line(name: 'a', unitPrice: 33.33, taxPercent: 7),
          _line(name: 'b', unitPrice: 66.67, taxPercent: 7),
        ],
        discount: const Adjustment.percent(15),
      );

      final rowTaxSum = totals.lines.fold<double>(
        0,
        (sum, line) => sum + line.taxAmount,
      );
      expect(rowTaxSum, totals.taxAmount);
    });

    test('a fixed discount never exceeds the subtotal', () {
      final totals = _totals(
        lines: [_line(name: 'a', unitPrice: 100)],
        discount: const Adjustment.amount(150),
        shipping: 5,
      );

      expect(totals.discountAmount, 100);
      expect(totals.discountedSubtotal, 0);
      expect(totals.total, 5);
    });

    test('reports mixed rates rather than claiming one', () {
      final mixed = _totals(
        lines: [
          _line(name: 'a', unitPrice: 10, taxPercent: 5),
          _line(name: 'b', unitPrice: 10, taxPercent: 20),
        ],
      );
      expect(mixed.hasMixedTaxRates, isTrue);
      expect(mixed.uniformTaxRate, isNull);

      final uniform = _totals(
        lines: [
          _line(name: 'a', unitPrice: 10),
          _line(name: 'b', unitPrice: 10),
        ],
        taxPercent: 5,
      );
      expect(uniform.hasMixedTaxRates, isFalse);
      expect(uniform.uniformTaxRate, 5);
    });

    test('handles a document with no rows', () {
      final totals = _totals(shipping: 12, taxPercent: 20);

      expect(totals.subtotal, 0);
      expect(totals.taxAmount, 0);
      expect(totals.total, 12);
      expect(totals.hasLines, isFalse);
    });

    test('rounds to the currency minor units', () {
      final withCents = _totals(
        lines: [_line(name: 'a', quantity: 3, unitPrice: 9.99)],
        taxPercent: 7.5,
      );
      // 29.97 + 2.25 (rounded from 2.24775).
      expect(withCents.subtotal, 29.97);
      expect(withCents.taxAmount, 2.25);
      expect(withCents.total, 32.22);

      final wholeUnits = _totals(
        lines: [_line(name: 'a', quantity: 3, unitPrice: 9.99)],
        currency: Currency.jpy,
      );
      expect(wholeUnits.subtotal, 30);
    });

    test('a paid document owes nothing', () {
      final totals = _totals(
        lines: [_line(name: 'a', unitPrice: 100)],
        isFullyPaid: true,
      );

      expect(totals.amountPaid, 100);
      expect(totals.balanceDue, 0);
      expect(totals.isSettled, isTrue);
    });

    test('a part payment leaves the remainder due', () {
      final totals = _totals(
        lines: [_line(name: 'a', unitPrice: 100)],
        amountPaid: 40,
      );

      expect(totals.amountPaid, 40);
      expect(totals.balanceDue, 60);
      expect(totals.isSettled, isFalse);
    });

    test('a payment larger than the total is capped', () {
      final totals = _totals(
        lines: [_line(name: 'a', unitPrice: 100)],
        amountPaid: 500,
      );

      expect(totals.amountPaid, 100);
      expect(totals.balanceDue, 0);
    });

    test('copes with fifty rows', () {
      final totals = _totals(
        lines: List.generate(
          50,
          (index) => _line(name: 'row$index', unitPrice: 10),
        ),
        taxPercent: 10,
      );

      expect(totals.lines, hasLength(50));
      expect(totals.subtotal, 500);
      expect(totals.total, 550);
    });
  });
}
