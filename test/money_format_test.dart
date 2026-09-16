import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/utils/money.dart';

void main() {
  group('MoneyFormat', () {
    test('groups digits and places the symbol', () {
      const format = MoneyFormat(
        currency: Currency.usd,
        grouping: NumberGroupingOption.comma,
      );

      expect(format.format(1234.5), r'$1,234.50');
      expect(format.format(0), r'$0.00');
      expect(format.format(1000000), r'$1,000,000.00');
    });

    test('spaces an alphabetic symbol from the digits', () {
      const format = MoneyFormat(
        currency: Currency.aed,
        grouping: NumberGroupingOption.comma,
      );

      expect(format.format(1200), 'AED 1,200.00');
    });

    test('honours the chosen separators', () {
      const dotted = MoneyFormat(
        currency: Currency.eur,
        grouping: NumberGroupingOption.dot,
      );
      expect(dotted.format(1234.56), '€1.234,56');

      const ungrouped = MoneyFormat(
        currency: Currency.eur,
        grouping: NumberGroupingOption.none,
      );
      expect(ungrouped.format(1234.56), '€1234.56');
    });

    test('omits minor units for a zero-decimal currency', () {
      const format = MoneyFormat(
        currency: Currency.jpy,
        grouping: NumberGroupingOption.comma,
      );

      expect(format.format(1234.6), '¥1,235');
    });

    test('writes a deduction with the sign before the symbol', () {
      const format = MoneyFormat(
        currency: Currency.usd,
        grouping: NumberGroupingOption.comma,
      );

      expect(format.formatNegated(40), r'-$40.00');
      expect(format.formatNegated(0), r'$0.00');
    });

    test('drops trailing zeros from a percentage', () {
      const format = MoneyFormat.fallback();

      expect(format.percent(12), '12%');
      expect(format.percent(12.5), '12.5%');
      expect(format.percent(0), '0%');
    });
  });

  group('Money.round', () {
    test('rounds to the requested number of decimals', () {
      expect(Money.round(1.0051, 2), 1.01);
      expect(Money.round(1.0049, 2), 1);
      expect(Money.round(12.3456, 2), 12.35);
      expect(Money.round(1.4, 0), 1);
    });

    test('rounds an exactly representable half away from zero', () {
      expect(Money.round(1.5, 0), 2);
      expect(Money.round(2.5, 0), 3);
      expect(Money.round(0.125, 2), 0.13);
    });

    test('treats a non-finite value as zero', () {
      expect(Money.round(double.nan, 2), 0);
      expect(Money.round(double.infinity, 2), 0);
    });

    test('clamps a negative amount to zero', () {
      expect(Money.clampPositive(-5), 0);
      expect(Money.clampPositive(5, max: 3), 3);
      expect(Money.clampPositive(double.nan), 0);
    });
  });
}
