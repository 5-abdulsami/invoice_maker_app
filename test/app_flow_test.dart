import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/app.dart';

/// Pumps out a route transition without settling, which the PDF preview's
/// pending platform call would otherwise block.
Future<void> _pumpTransition(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls the form until [finder] is on screen, then settles.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.byType(Scrollable).first,
    const Offset(0, -250),
  );
  await tester.pumpAndSettle();
}

/// Opens the invoice form from the dashboard FAB.
Future<void> _openInvoiceForm(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> _bootToDashboard(WidgetTester tester) async {
  await tester.pumpWidget(const InvoiceMakerApp());

  expect(find.text('Invoice Maker'), findsOneWidget);

  // Let the splash timer fire and the dashboard settle.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('boots through the splash to the invoice dashboard',
      (tester) async {
    await _bootToDashboard(tester);

    expect(find.text('Total Unpaid'), findsOneWidget);
    expect(find.text('Total Overdue'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets('opens the invoice form and refuses to save an empty invoice',
      (tester) async {
    await _bootToDashboard(tester);

    await _openInvoiceForm(tester);

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Bill To'), findsOneWidget);
    // A blank draft starts at INV00001.
    expect(find.text('INV00001'), findsOneWidget);

    await _scrollTo(tester, find.text('Add Item'));
    expect(find.text('Add Item'), findsOneWidget);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('Add at least one item first.'), findsOneWidget);
  });

  testWidgets('creates a client from the invoice form', (tester) async {
    await _bootToDashboard(tester);

    await _openInvoiceForm(tester);

    // With no saved clients, "Bill To" goes straight to the client form.
    await tester.tap(find.text('Bill To'));
    await tester.pumpAndSettle();
    expect(find.text('New Client'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter client name'),
      'Globex',
    );
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    // Back on the form, the chosen client fills the "Bill To" line.
    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Globex'), findsOneWidget);
  });

  testWidgets('adds an item and totals it on the invoice form', (tester) async {
    await _bootToDashboard(tester);

    await _openInvoiceForm(tester);

    await _scrollTo(tester, find.text('Add Item'));
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();
    expect(find.text('New Item'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter Item Name'),
      'Consulting',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rs0'),
      '250',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '1'),
      '2',
    );
    await tester.pumpAndSettle();

    // The live amount updates as the fields change.
    await _scrollTo(tester, find.text('Amount'));
    expect(find.text('Rs500'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Items(1)'), findsOneWidget);
    await _scrollTo(tester, find.text('Total'));
    // The line amount, the subtotal and the total all read Rs500 when there
    // is no invoice-level discount, tax or shipping.
    expect(find.text('Rs500'), findsNWidgets(3));
  });

  testWidgets('saves the invoice and lists it on the dashboard',
      (tester) async {
    await _bootToDashboard(tester);

    await _openInvoiceForm(tester);

    await _scrollTo(tester, find.text('Add Item'));
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter Item Name'),
      'Consulting',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Rs0'), '400');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAVE'));
    // Plain pumps rather than pumpAndSettle: the detail screen's PDF preview
    // needs the pdfx platform channel, which never resolves in a headless test.
    await _pumpTransition(tester);

    // The detail screen opens on the saved invoice.
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.text('INV00001'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await _pumpTransition(tester);

    expect(find.text('Total Unpaid'), findsOneWidget);
    expect(find.text('Rs400'), findsWidgets);
  });
}
