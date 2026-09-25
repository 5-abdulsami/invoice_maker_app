import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/design/app_theme.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/presentation/home/widgets/summary_section.dart';
import 'package:invoicemaker/state/document_controller.dart';

import 'support/test_data.dart';

/// The home figures must show every digit of an amount, however large, on
/// any phone width and text size: money is never clipped or ellipsised.
void main() {
  setUpAll(loadAppFonts);

  MoneyFormat moneyFor(Currency currency) =>
      MoneyFormat(currency: currency, grouping: NumberGroupingOption.comma);

  const cases = <(String, DocumentSummary)>[
    (
      'short amounts',
      DocumentSummary(
        currency: Currency.pkr,
        invoiceCount: 3,
        outstanding: 1500,
        overdue: 0,
        collected: 2700,
        overdueCount: 0,
      ),
    ),
    (
      'huge rupee amounts',
      DocumentSummary(
        currency: Currency.pkr,
        invoiceCount: 40,
        outstanding: 987654321098,
        overdue: 12345678901,
        collected: 5555555555555,
        overdueCount: 12,
      ),
    ),
    (
      'huge dollar amounts with cents',
      DocumentSummary(
        currency: Currency.usd,
        invoiceCount: 40,
        outstanding: 98765432109.99,
        overdue: 7.5,
        collected: 123456789012.34,
        overdueCount: 1,
      ),
    ),
  ];

  for (final width in [320.0, 360.0, 412.0, 700.0]) {
    for (final textScale in [1.0, 1.6]) {
      for (final (label, summary) in cases) {
        testWidgets('$label show in full at ${width.toInt()}pt wide, '
            '${textScale}x text', (tester) async {
          tester.view
            ..physicalSize = Size(width, 600)
            ..devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SummarySection(
                    summaries: [summary],
                    moneyFor: moneyFor,
                  ),
                ),
              ),
            ),
          );

          final money = moneyFor(summary.currency);
          for (final amount in [
            summary.outstanding,
            summary.overdue,
            summary.collected,
          ]) {
            final text = money.format(amount);
            final finder = find.text(text);
            expect(finder, findsOneWidget, reason: '$text is missing');

            // Laid out on one line at its natural width: nothing is cut off.
            final paragraph = tester.renderObject<RenderParagraph>(finder);
            expect(paragraph.didExceedMaxLines, isFalse, reason: text);
            expect(
              paragraph.size.width,
              greaterThanOrEqualTo(
                paragraph.getMaxIntrinsicWidth(double.infinity) - 0.5,
              ),
              reason: '$text was clipped',
            );

            // And its on-screen box stays inside the screen.
            final box = tester.getRect(finder);
            expect(box.right, lessThanOrEqualTo(width), reason: text);
          }
        });
      }
    }
  }
}
