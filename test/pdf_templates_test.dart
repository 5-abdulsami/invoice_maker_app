import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template_registry.dart';
import 'package:pdf/widgets.dart' as pw;

/// The built-in PDF fonts.
///
/// Used for the bulk of these tests because they need no embedding or
/// subsetting: exercising eight layouts against long documents with a real
/// TTF turns a five-second suite into a multi-minute one. Every document
/// rendered with them bills in US dollars, which they can draw.
late PdfFonts _fastFonts;

/// The fonts the app actually ships, used where glyph coverage is the point.
late PdfFonts _bundledFonts;

PdfFonts _builtInFonts() => PdfFonts(
      regular: pw.Font.helvetica(),
      medium: pw.Font.helveticaBold(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
      narrowLight: pw.Font.helvetica(),
      narrowRegular: pw.Font.helvetica(),
      narrowBold: pw.Font.helveticaBold(),
    );

LineItem _line(String name, double price, double quantity) => LineItem(
      id: name,
      name: name,
      description: 'Description for $name',
      unit: 'hr',
      quantity: quantity,
      unitPrice: price,
      discountPercent: 10,
      taxPercent: 5,
    );

SalesDocument _document({
  List<LineItem>? lines,
  Currency currency = Currency.usd,
  DocumentKind kind = DocumentKind.invoice,
  DocumentStatus? status,
  String issuerName = 'Acme Studio',
  String recipientName = 'Globex Corporation',
  String notes = 'Thank you for your business.',
}) {
  final now = DateTime(2026, 9, 16);

  return SalesDocument(
    id: 'doc',
    kind: kind,
    number: '${kind.numberPrefix}-0123',
    reference: 'PO-9',
    issueDate: now,
    endDate: now.add(const Duration(days: 14)),
    issuer: PartySnapshot(
      name: issuerName,
      email: 'hello@acme.test',
      phone: '+1 555 0100',
      address: '1 Market Street, Springfield',
      taxNumber: 'GB123456789',
      website: 'acme.test',
    ),
    recipient: PartySnapshot(
      name: recipientName,
      email: 'ap@globex.test',
      phone: '+1 555 0199',
      address: '9 Industrial Way, Shelbyville',
    ),
    lines: lines ??
        [
          _line('Design', 250, 4),
          _line('Development', 500, 8),
          _line('Support', 120, 2),
        ],
    discount: const Adjustment.percent(5),
    taxLabel: 'VAT',
    taxPercent: 12,
    shipping: 30,
    currency: currency,
    status: status ?? DocumentStatus.initialFor(kind),
    template: InvoiceTemplate.slate,
    notes: notes,
    paymentTerms: 'Payment due within 14 days.',
    paymentDetails: 'Bank transfer to 0001-2222, reference the invoice number.',
    createdAt: now,
    updatedAt: now,
  );
}

PdfRenderData _data(SalesDocument document, PdfFonts fonts) => PdfRenderData(
      document: document,
      fonts: fonts,
      moneyFormat: MoneyFormat(
        currency: document.currency,
        grouping: NumberGroupingOption.comma,
      ),
      dateFormat: DateFormatOption.mediumDate,
    );

/// True when [bytes] begin with the PDF magic number.
bool _isPdf(List<int> bytes) =>
    bytes.length > 4 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46;

Future<List<int>> _render(
  InvoiceTemplate template,
  SalesDocument document, {
  PdfFonts? fonts,
}) async {
  final pdf = PdfTemplateRegistry.resolve(template).build(
    _data(document, fonts ?? _fastFonts),
  );
  return pdf.save();
}

void main() {
  setUpAll(() async {
    // rootBundle needs the test binding to serve the packaged fonts.
    TestWidgetsFlutterBinding.ensureInitialized();
    _fastFonts = _builtInFonts();
    _bundledFonts = await PdfFonts.load();
  });

  group('template registry', () {
    test('resolves every template to its own layout', () {
      for (final template in InvoiceTemplate.values) {
        expect(PdfTemplateRegistry.resolve(template).id, template);
      }
      expect(
        PdfTemplateRegistry.all,
        hasLength(InvoiceTemplate.values.length),
      );
    });

    test('offers thirty layouts, thirteen of them free', () {
      expect(InvoiceTemplate.values, hasLength(30));
      expect(
        InvoiceTemplate.values.where((template) => !template.isPro),
        hasLength(13),
      );
    });
  });

  group('bundled fonts', () {
    test('load and are cached', () async {
      expect(_bundledFonts.regular, isNotNull);
      expect(_bundledFonts.narrowBold, isNotNull);
      expect(await PdfFonts.load(), same(_bundledFonts));
    });

    test('every typeface a template uses is bundled', () async {
      // Fails if a font file is missing from pubspec.yaml's asset list.
      for (final typeface in PdfTypeface.values) {
        final fonts = await PdfFonts.load(typeface);
        expect(fonts.display, isNotNull, reason: typeface.name);
      }
    });

    test('every layout renders in its own typeface', () async {
      for (final template in InvoiceTemplate.values) {
        final layout = PdfTemplateRegistry.resolve(template);
        final bytes = await _render(
          template,
          _document(currency: Currency.eur, lines: [_line('Work', 100, 1)]),
          fonts: await PdfFonts.load(layout.typeface),
        );
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('draw the currency symbols the built-in fonts cannot', () async {
      // The reason the app embeds fonts at all: these symbols are outside
      // Latin-1 and used to print as a currency code instead.
      for (final currency in [
        Currency.eur,
        Currency.gbp,
        Currency.inr,
        Currency.jpy,
      ]) {
        final bytes = await _render(
          InvoiceTemplate.slate,
          _document(currency: currency, lines: [_line('Work', 100, 1)]),
          fonts: _bundledFonts,
        );
        expect(_isPdf(bytes), isTrue, reason: currency.code);
      }
    });
  });

  group('every template renders', () {
    for (final template in InvoiceTemplate.values) {
      test('${template.name} builds a valid PDF', () async {
        final bytes = await _render(template, _document());

        expect(_isPdf(bytes), isTrue, reason: '${template.name} is not a PDF');
        expect(bytes.length, greaterThan(1000));
      });
    }

    test('with no rows at all', () async {
      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(template, _document(lines: const []));
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('with a single row', () async {
      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(
          template,
          _document(lines: [_line('Only item', 99.99, 1)]),
        );
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('with sixty rows, spilling onto later pages', () async {
      final many = List.generate(
        60,
        (index) => _line('Line item number $index', 125.5, index + 1),
      );

      for (final template in InvoiceTemplate.values) {
        final long = await _render(template, _document(lines: many));
        final short = await _render(template, _document());

        expect(_isPdf(long), isTrue, reason: template.name);
        // A table that cannot break across pages either throws or produces no
        // more content than the three-row document.
        expect(
          long.length,
          greaterThan(short.length),
          reason: '${template.name} did not grow with sixty rows',
        );
      }
    });

    test('with two hundred rows', () async {
      final many = List.generate(200, (index) => _line('Row $index', 10, 1));

      final bytes = await _render(
        InvoiceTemplate.compact,
        _document(lines: many),
      );
      expect(_isPdf(bytes), isTrue);
    });

    test('with very long names and descriptions', () async {
      final longText = 'A ' * 120;
      final lines = [
        LineItem(
          id: 'long',
          name: 'An extremely long item name that has to wrap $longText',
          description: longText,
          quantity: 1000,
          unitPrice: 999999.99,
        ),
      ];

      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(
          template,
          _document(
            lines: lines,
            issuerName: 'A Very Long Business Name Limited $longText',
            recipientName: 'A Very Long Customer Company Name $longText',
            notes: longText,
          ),
        );
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('for an estimate as well as an invoice', () async {
      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(
          template,
          _document(kind: DocumentKind.estimate),
        );
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('for a settled invoice, which prints the paid marker', () async {
      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(
          template,
          _document(status: DocumentStatus.paid),
        );
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('with no optional details filled in', () async {
      final bare = SalesDocument.draft(
        kind: DocumentKind.invoice,
        number: 'INV-0001',
        issuer: const PartySnapshot(name: 'Sole Trader'),
        currency: Currency.usd,
        template: InvoiceTemplate.slate,
        termDays: 0,
      ).copyWith(
        recipient: const PartySnapshot(name: 'Walk-in customer'),
        lines: const [LineItem(id: 'l', name: 'Repair', unitPrice: 40)],
      );

      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(template, bare);
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });

    test('with no customer name, which must not crash the layout', () async {
      final noRecipient = _document().copyWith(
        recipient: const PartySnapshot.empty(),
      );

      for (final template in InvoiceTemplate.values) {
        final bytes = await _render(template, noRecipient);
        expect(_isPdf(bytes), isTrue, reason: template.name);
      }
    });
  });
}
