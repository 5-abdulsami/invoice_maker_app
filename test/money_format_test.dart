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

  group('MoneyFormat matching the currency', () {
    String format(Currency currency, num value) => MoneyFormat(
          currency: currency,
          grouping: NumberGroupingOption.automatic,
        ).format(value);

    test('writes rupees with commas, never dots', () {
      expect(format(Currency.pkr, 3000), 'Rs 3,000');
      expect(format(Currency.pkr, 50000), 'Rs 50,000');
      expect(format(Currency.pkr, 1000000), 'Rs 1,000,000');
    });

    test('groups Indian, Bangladeshi and Nepalese amounts in lakhs', () {
      expect(format(Currency.inr, 100000), '₹1,00,000.00');
      expect(format(Currency.inr, 12345678.9), '₹1,23,45,678.90');
      expect(format(Currency.bdt, 1500), 'BDT 1,500.00');
      expect(format(Currency.npr, 250000), 'NPR 2,50,000.00');
    });

    test("follows each currency's own separators", () {
      expect(format(Currency.usd, 1234.5), r'$1,234.50');
      expect(format(Currency.eur, 1234.56), '€1.234,56');
      expect(format(Currency.chf, 1234.5), "CHF 1'234.50");
      expect(format(Currency.sek, 1234.5), 'SEK 1 234,50');
      expect(format(Currency.idr, 2500000), 'Rp 2.500.000');
      expect(format(Currency.jpy, 1234567), '¥1,234,567');
    });

    test('leaves short amounts ungrouped', () {
      expect(format(Currency.inr, 999), '₹999.00');
      expect(format(Currency.pkr, 0), 'Rs 0');
    });

    test('keeps the sign outside the grouping', () {
      const money = MoneyFormat(
        currency: Currency.inr,
        grouping: NumberGroupingOption.automatic,
      );

      expect(money.formatNegated(100000), '-₹1,00,000.00');
      expect(money.format(-100000), '-₹1,00,000.00');
      expect(money.formatNegated(0), '₹0.00');
    });

    test("writes a percentage with the currency's decimal separator", () {
      const euro = MoneyFormat(
        currency: Currency.eur,
        grouping: NumberGroupingOption.automatic,
      );

      expect(euro.percent(12.5), '12,5%');
      expect(euro.percent(20), '20%');
    });

    test('a forced style overrides the currency', () {
      const forced = MoneyFormat(
        currency: Currency.inr,
        grouping: NumberGroupingOption.comma,
      );

      expect(forced.format(100000), '₹100,000.00');
    });

    test('labels each option with a sample', () {
      expect(NumberGroupingOption.automatic.label, 'Match currency');
      expect(NumberGroupingOption.comma.label, '1,234.56');
      expect(NumberGroupingOption.dot.label, '1.234,56');
      expect(NumberGroupingOption.space.label, '1 234.56');
      expect(NumberGroupingOption.none.label, '1234.56');
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
