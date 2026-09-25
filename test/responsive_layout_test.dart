import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/app.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/shell/app_shell.dart';

import 'support/test_data.dart';

/// Opens every screen on a range of phone sizes and text scales and fails on
/// any layout overflow or build error.
///
/// The seeded data is deliberately awkward: long names, long amounts, many
/// rows and more than one currency, the content most likely to break a
/// layout. A fresh install and forms with the keyboard open are checked too.
void main() {
  setUpAll(loadAppFonts);

  const screens = <(String, Size)>[
    ('small phone', Size(320, 568)),
    ('compact phone', Size(360, 640)),
    ('large phone', Size(412, 915)),
    ('landscape', Size(780, 360)),
  ];
  const textScales = [1.0, 1.6];

  for (final (label, size) in screens) {
    for (final scale in textScales) {
      final variant = '$label (${size.width.toInt()}x${size.height.toInt()}) '
          'at ${scale}x text';

      testWidgets('every screen fits a $variant', (tester) async {
        final seed = await tester.runAsync(seededRepositories);
        final (repositories, invoice, estimate) = seed!;
        await _audit(
          tester,
          size: size,
          textScale: scale,
          repositories: repositories,
          screens: _allScreens(repositories, invoice, estimate),
        );
      });

      testWidgets('a fresh install fits a $variant', (tester) async {
        final repositories = await tester.runAsync(AppRepositories.inMemory);
        await _audit(
          tester,
          size: size,
          textScale: scale,
          repositories: repositories!,
          screens: _emptyStateScreens,
        );
      });
    }

    testWidgets('forms fit a $label with the keyboard open', (tester) async {
      final seed = await tester.runAsync(seededRepositories);
      final (repositories, invoice, _) = seed!;
      await _audit(
        tester,
        size: size,
        textScale: 1.3,
        // A typical on-screen keyboard, capped so a landscape phone keeps
        // a usable strip of content above it.
        keyboardHeight: (size.height * 0.45).clamp(0, 300),
        repositories: repositories,
        screens: _formScreens(repositories, invoice),
      );
    });
  }
}

typedef _Opener = void Function(BuildContext context);

Map<String, _Opener> _allScreens(
  AppRepositories repositories,
  SalesDocument invoice,
  SalesDocument estimate,
) {
  return {
    'settings': AppNavigator.openSettings,
    'document defaults': AppNavigator.openDocumentDefaults,
    'numbering': AppNavigator.openNumbering,
    'backup': AppNavigator.openBackup,
    'about': AppNavigator.openAbout,
    'signature': AppNavigator.openSignatureCapture,
    ..._formScreens(repositories, invoice),
    'new estimate': (c) =>
        AppNavigator.openEditor(c, kind: DocumentKind.estimate),
    'invoice detail': (c) => AppNavigator.openDocumentDetail(c, invoice),
    'estimate detail': (c) => AppNavigator.openDocumentDetail(c, estimate),
    'preview': (c) => AppNavigator.openDocumentPreview(c, invoice),
    'template picker': (c) =>
        AppNavigator.openTemplatePicker(c, document: invoice),
  };
}

/// Screens with text fields, where the keyboard takes space.
Map<String, _Opener> _formScreens(
  AppRepositories repositories,
  SalesDocument invoice,
) {
  return {
    'business profile': AppNavigator.openBusinessProfile,
    'new customer': AppNavigator.openCustomerEditor,
    'edit customer': (c) => AppNavigator.openCustomerEditor(
          c,
          customer: repositories.customers.all.first,
        ),
    'new item': AppNavigator.openCatalogEditor,
    'edit item': (c) => AppNavigator.openCatalogEditor(
          c,
          item: repositories.catalog.all.first,
        ),
    'new invoice': (c) =>
        AppNavigator.openEditor(c, kind: DocumentKind.invoice),
    'edit invoice': (c) => AppNavigator.openEditor(
          c,
          kind: DocumentKind.invoice,
          documentId: invoice.id,
        ),
  };
}

/// What a first-run user can reach before creating anything.
final Map<String, _Opener> _emptyStateScreens = {
  'settings': AppNavigator.openSettings,
  'backup': AppNavigator.openBackup,
  'business profile': AppNavigator.openBusinessProfile,
  'new invoice': (c) => AppNavigator.openEditor(c, kind: DocumentKind.invoice),
};

/// Pumps the app, visits every tab and then each of [screens], and fails
/// with a list of every problem found, labelled by screen.
Future<void> _audit(
  WidgetTester tester, {
  required Size size,
  required double textScale,
  required AppRepositories repositories,
  required Map<String, _Opener> screens,
  double keyboardHeight = 0,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..viewInsets = FakeViewPadding(bottom: keyboardHeight);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  // Layout overflows are reported through FlutterError rather than thrown,
  // so they are collected here, labelled with the screen that caused them.
  final problems = <String>[];
  var screen = 'home';
  final previousHandler = FlutterError.onError;
  FlutterError.onError = (details) => problems.add(
        '$screen: ${_firstLine(details.exceptionAsString())}',
      );

  try {
    await tester.pumpWidget(InvoiceMakerApp(repositories: repositories));
    await _settle(tester);

    void check() {
      final Object? error = tester.takeException();
      if (error != null) problems.add('$screen: ${_firstLine(error)}');
    }

    check();
    for (final tab in ShellTab.values.skip(1)) {
      screen = tab.label;
      await tester.tap(find.byTooltip(tab.label).last);
      await _settle(tester);
      check();
    }

    for (final MapEntry(key: name, value: open) in screens.entries) {
      screen = name;
      open(tester.element(find.byType(AppShell)));
      await _settle(tester);
      check();

      final navigator =
          tester.state<NavigatorState>(find.byType(Navigator).first);
      expect(navigator.canPop(), isTrue, reason: '$name did not open');
      navigator.pop();
      screen = '$name (closing)';
      await _settle(tester);
      check();
    }
  } finally {
    FlutterError.onError = previousHandler;
  }

  expect(problems, isEmpty, reason: problems.join('\n'));
}

/// Advances time without waiting for endless animations such as spinners
/// to stop, which `pumpAndSettle` would.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _firstLine(Object error) => error.toString().split('\n').first;
