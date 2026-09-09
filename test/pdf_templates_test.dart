import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/utils/pdf_asset_loader.dart';
import 'package:invoicemaker/data/models/business.dart';
import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/services/pdf/templates/base_template.dart';
import 'package:invoicemaker/services/pdf/templates/template_registry.dart';

Item _item(String name, double price, int quantity) => Item(
      id: name,
      name: name,
      price: price,
      quantity: quantity,
      unitOfMeasure: 'hrs',
      discount: 10,
      tax: 5,
      description: 'Description for $name',
      subAmount: Item.calculateAmount(
        price: price,
        quantity: quantity,
        discountPercentage: 10,
        taxPercentage: 5,
      ),
    );

InvoiceDocumentData _data({
  Currency currency = Currency.pkr,
  List<Item>? items,
}) {
  final lines = items ??
      [
        _item('Design', 250, 4),
        _item('Development', 500, 8),
        _item('Support', 120, 2),
      ];

  final subTotal = lines.fold<double>(0, (sum, item) => sum + item.subAmount);
  final invoice = Invoice.blank(invoiceNumber: 'INV00123').copyWith(
    from: 'Acme Studio',
    to: 'Globex Corporation',
    items: lines,
    subTotal: subTotal,
    discount: 5,
    taxName: 'VAT',
    tax: 12,
    shippingCharges: 300,
    total: subTotal * 0.95 * 1.12 + 300,
    currency: currency,
    poNumber: 'PO-9',
    terms: 'Payment due within 7 days.',
    paymentMethod: 'Bank transfer to 0001-2222',
  );

  return InvoiceDocumentData(
    invoice: invoice,
    business: const Business(
      businessName: 'Acme Studio',
      emailAddress: 'hello@acme.test',
      phone: '+1 555 0100',
      billingAddress: '1 Market Street',
      website: 'acme.test',
    ),
    client: const Client(
      id: 'c1',
      name: 'Globex Corporation',
      emailAddress: 'ap@globex.test',
      phone: '+1 555 0199',
      billingAddress: '9 Industrial Way',
      shippingAddress: '9 Industrial Way',
      detail: '',
    ),
    signature: PdfAssetLoader.transparentPixel,
  );
}

/// True when [bytes] start with the PDF magic number.
bool _isPdf(List<int> bytes) =>
    bytes.length > 4 &&
    bytes[0] == 0x25 && // %
    bytes[1] == 0x50 && // P
    bytes[2] == 0x44 && // D
    bytes[3] == 0x46; // F

void main() {
  group('TemplateRegistry', () {
    test('resolves every template exactly once', () {
      for (final template in InvoiceTemplate.values) {
        expect(TemplateRegistry.resolve(template).id, template);
      }
      expect(TemplateRegistry.all, hasLength(InvoiceTemplate.values.length));
    });
  });

  group('PDF templates', () {
    for (final template in InvoiceTemplate.values) {
      test('${template.name} builds a valid document', () async {
        final document =
            await TemplateRegistry.resolve(template).buildDocument(_data());
        final bytes = await document.save();

        expect(_isPdf(bytes), isTrue, reason: '${template.name} is not a PDF');
        expect(bytes.length, greaterThan(1000));
      });
    }

    test('every template renders each supported currency', () async {
      for (final currency in Currency.values) {
        for (final template in InvoiceTemplate.values) {
          final document = await TemplateRegistry.resolve(template)
              .buildDocument(_data(currency: currency));
          expect(_isPdf(await document.save()), isTrue);
        }
      }
    });

    test('uses only Latin-1 symbols the built-in PDF fonts can draw', () {
      for (final currency in Currency.values) {
        expect(
          currency.pdfSymbol.codeUnits.every((unit) => unit <= 0xFF),
          isTrue,
          reason: '${currency.code} would not render in a PDF',
        );
      }
    });

    test('handles an invoice with no line items', () async {
      for (final template in InvoiceTemplate.values) {
        final document = await TemplateRegistry.resolve(template)
            .buildDocument(_data(items: const []));
        expect(_isPdf(await document.save()), isTrue);
      }
    });

    test('handles enough items to spill onto a second page', () async {
      final many = List.generate(40, (i) => _item('Line $i', 100, 1));
      final document = await TemplateRegistry.resolve(InvoiceTemplate.template1)
          .buildDocument(_data(items: many));

      expect(_isPdf(await document.save()), isTrue);
    });
  });
}
