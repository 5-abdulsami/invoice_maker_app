import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';

Item _item({
  required String id,
  double price = 100,
  int quantity = 1,
  double discount = 0,
  double tax = 0,
}) {
  return Item(
    id: id,
    name: 'Item $id',
    price: price,
    quantity: quantity,
    unitOfMeasure: '',
    discount: discount,
    tax: tax,
    description: '',
    subAmount: Item.calculateAmount(
      price: price,
      quantity: quantity,
      discountPercentage: discount,
      taxPercentage: tax,
    ),
  );
}

void main() {
  group('Item.calculateAmount', () {
    test('applies the discount before the tax', () {
      final amount = Item.calculateAmount(
        price: 100,
        quantity: 2,
        discountPercentage: 10,
        taxPercentage: 10,
      );
      // 200 - 20 = 180, plus 10% tax = 198.
      expect(amount, 198);
    });
  });

  group('InvoiceProvider draft', () {
    late InvoiceProvider provider;

    setUp(() => provider = InvoiceProvider());

    test('recalculates the subtotal and total when items change', () {
      provider
        ..addItem(_item(id: '1'))
        ..addItem(_item(id: '2', price: 50));

      expect(provider.invoice.subTotal, 150);
      expect(provider.invoice.total, 150);
    });

    test('folds discount, tax and shipping into the total', () {
      provider.addItem(_item(id: '1', price: 200));
      provider.updateDraft(
        (draft) => draft.copyWith(discount: 10, tax: 5, shippingCharges: 20),
      );
      provider.recalculateTotals();

      // 200 - 20 + 10 + 20 = 210.
      expect(provider.invoice.total, 210);
    });

    test('reorders items without dropping any', () {
      provider
        ..addItem(_item(id: '1'))
        ..addItem(_item(id: '2'))
        ..addItem(_item(id: '3'));

      // onReorderItem reports the index after removal, so 2 means "last".
      provider.reorderItems(0, 2);

      expect(
        provider.invoice.items.map((item) => item.id).toList(),
        ['2', '3', '1'],
      );
    });

    test('ignores an out-of-range reorder', () {
      provider.addItem(_item(id: '1'));
      provider.reorderItems(5, 0);

      expect(provider.invoice.items.single.id, '1');
    });

    test('keeps the due terms in step with the due date', () {
      final creation = provider.invoice.creationDate;
      provider.setDueDate(creation.add(const Duration(days: 30)));

      expect(provider.invoice.dueTerms, 30);
    });
  });

  group('InvoiceProvider list', () {
    late InvoiceProvider provider;

    setUp(() => provider = InvoiceProvider());

    Invoice saved({
      required String id,
      required String number,
      InvoiceStatus status = InvoiceStatus.unpaid,
      double total = 100,
      DateTime? dueDate,
      String to = 'Acme',
    }) {
      final invoice = Invoice.blank(invoiceNumber: number).copyWith(
        id: id,
        status: status,
        total: total,
        to: to,
        dueDate: dueDate,
      );
      provider.saveInvoice(invoice);
      return invoice;
    }

    test('saveInvoice adds once and then updates in place', () {
      final invoice = saved(id: 'a', number: 'INV00001');
      provider.saveInvoice(invoice.copyWith(total: 250));

      expect(provider.invoices, hasLength(1));
      expect(provider.getInvoiceById('a')!.total, 250);
    });

    test('issues unique invoice numbers', () {
      saved(id: 'a', number: provider.nextInvoiceNumber());
      final next = provider.nextInvoiceNumber();

      expect(provider.isInvoiceNumberUnique(next), isTrue);
      expect(next, isNot('INV00001'));
    });

    test('filters by status and treats overdue as date-driven', () {
      saved(id: 'a', number: 'INV1');
      saved(
        id: 'b',
        number: 'INV2',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      saved(id: 'c', number: 'INV3', status: InvoiceStatus.paid);

      expect(provider.filtered(status: InvoiceStatus.paid), hasLength(1));
      expect(provider.filtered(status: InvoiceStatus.overdue), hasLength(1));
      expect(provider.filtered(), hasLength(3));
    });

    test('a paid invoice is never overdue', () {
      final invoice = saved(
        id: 'a',
        number: 'INV1',
        status: InvoiceStatus.paid,
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(invoice.isOverdue, isFalse);
      expect(provider.totalOverdue(provider.invoices), 0);
    });

    test('searches by number and client name', () {
      saved(id: 'a', number: 'INV00001', to: 'Globex');
      saved(id: 'b', number: 'INV00002', to: 'Acme');

      expect(provider.filtered(query: 'globex').single.id, 'a');
      expect(provider.filtered(query: '00002').single.id, 'b');
      expect(provider.filtered(query: 'nothing'), isEmpty);
    });

    test('setStatus clears the paid amount unless partially paid', () {
      saved(id: 'a', number: 'INV1', total: 500);

      provider.setStatus('a', InvoiceStatus.partiallyPaid, paidAmount: 200);
      expect(provider.getInvoiceById('a')!.paidAmount, 200);

      provider.setStatus('a', InvoiceStatus.paid);
      expect(provider.getInvoiceById('a')!.paidAmount, 0);
    });

    test('getInvoiceById returns null for an unknown id', () {
      expect(provider.getInvoiceById('missing'), isNull);
    });
  });

  group('Invoice serialisation', () {
    test('round-trips through JSON', () {
      final invoice = Invoice.blank(invoiceNumber: 'INV00042').copyWith(
        status: InvoiceStatus.partiallyPaid,
        items: [_item(id: '1', price: 25, quantity: 4)],
        total: 100,
      );

      final restored = Invoice.fromJsonString(invoice.toJsonString());

      expect(restored.invoiceNumber, 'INV00042');
      expect(restored.status, InvoiceStatus.partiallyPaid);
      expect(restored.currency, invoice.currency);
      expect(restored.items.single.price, 25);
    });

    test('tolerates missing fields', () {
      final restored = Invoice.fromJson(const {});

      expect(restored.invoiceNumber, '');
      expect(restored.status, InvoiceStatus.unpaid);
      expect(restored.items, isEmpty);
    });
  });
}
