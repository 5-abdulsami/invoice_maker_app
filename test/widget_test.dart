import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/presentation/common/widgets/status_badge.dart';
import 'package:invoicemaker/presentation/invoice/widgets/invoice_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StatusBadge', () {
    testWidgets('shows the status label', (tester) async {
      await tester.pumpWidget(
        _wrap(const StatusBadge(status: InvoiceStatus.partiallyPaid)),
      );

      expect(find.text('Partially Paid'), findsOneWidget);
    });

    testWidgets('reports taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          StatusBadge(
            status: InvoiceStatus.unpaid,
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(StatusBadge));
      expect(taps, 1);
    });
  });

  group('InvoiceCard', () {
    testWidgets('renders the number, client and formatted total',
        (tester) async {
      final invoice = Invoice.blank(invoiceNumber: 'INV00007').copyWith(
        to: 'Globex',
        total: 1250,
        currency: Currency.usd,
      );

      await tester.pumpWidget(
        _wrap(InvoiceCard(invoice: invoice, onTap: () {})),
      );

      expect(find.text('INV00007'), findsOneWidget);
      expect(find.text('Globex'), findsOneWidget);
      expect(find.text(r'$1250'), findsOneWidget);
    });

    testWidgets('lays out at 320 logical pixels without overflowing',
        (tester) async {
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final invoice = Invoice.blank(invoiceNumber: 'INV00008').copyWith(
        to: 'A client with a rather long company name',
        total: 999999,
      );

      await tester.pumpWidget(
        _wrap(InvoiceCard(invoice: invoice, onTap: () {})),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
