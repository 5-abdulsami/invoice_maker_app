import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/app_settings.dart';
import 'package:invoicemaker/data/models/backup_bundle.dart';
import 'package:invoicemaker/data/models/business_profile.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/data/models/sales_document.dart';

SalesDocument _document() {
  final now = DateTime(2026, 3, 4, 10, 30);

  return SalesDocument(
    id: 'doc-1',
    kind: DocumentKind.invoice,
    number: 'INV-0042',
    title: 'TAX INVOICE',
    reference: 'PO-99',
    issueDate: now,
    endDate: now.add(const Duration(days: 30)),
    issuer: const PartySnapshot(
      name: 'Acme Studio',
      email: 'hi@acme.test',
      taxNumber: 'GB123',
    ),
    recipient: const PartySnapshot(name: 'Globex', phone: '555-0100'),
    customerId: 'cust-1',
    lines: const [
      LineItem(
        id: 'l1',
        name: 'Design',
        description: 'Brand work',
        unit: 'hr',
        quantity: 2.5,
        unitPrice: 120,
        discountPercent: 10,
        taxPercent: 20,
      ),
    ],
    discount: const Adjustment.amount(25),
    taxLabel: 'VAT',
    taxPercent: 20,
    shipping: 15,
    currency: Currency.gbp,
    status: DocumentStatus.partiallyPaid,
    amountPaid: 100,
    notes: 'Thanks',
    paymentTerms: 'Net 30',
    paymentDetails: 'Bank 123',
    template: InvoiceTemplate.ledger,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('SalesDocument JSON', () {
    test('round-trips every field', () {
      final original = _document();
      final restored = SalesDocument.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.kind, DocumentKind.invoice);
      expect(restored.number, 'INV-0042');
      expect(restored.title, 'TAX INVOICE');
      expect(restored.reference, 'PO-99');
      expect(restored.issuer.taxNumber, 'GB123');
      expect(restored.recipient.name, 'Globex');
      expect(restored.customerId, 'cust-1');
      expect(restored.lines.single.quantity, 2.5);
      expect(restored.lines.single.taxPercent, 20);
      expect(restored.discount.mode, AdjustmentMode.amount);
      expect(restored.discount.value, 25);
      expect(restored.currency, Currency.gbp);
      expect(restored.status, DocumentStatus.partiallyPaid);
      expect(restored.amountPaid, 100);
      expect(restored.template, InvoiceTemplate.ledger);
      expect(restored.totals.total, original.totals.total);
    });

    test('decodes an empty object into a usable document', () {
      final restored = SalesDocument.fromJson(const {});

      expect(restored.number, '');
      expect(restored.lines, isEmpty);
      expect(restored.status, DocumentStatus.unpaid);
      expect(restored.currency, Currency.fallback);
      expect(restored.template, InvoiceTemplate.fallback);
      expect(restored.totals.total, 0);
    });

    test('repairs a status belonging to the other kind', () {
      final json = _document().toJson()
        ..['kind'] = DocumentKind.estimate.name
        ..['status'] = DocumentStatus.paid.name;

      // "Paid" is an invoice status, so an estimate falls back to pending.
      expect(SalesDocument.fromJson(json).status, DocumentStatus.pending);
    });

    test('a null row tax rate stays null rather than becoming zero', () {
      const line = LineItem(id: 'l', name: 'a', unitPrice: 10);
      final restored = LineItem.fromJson(line.toJson());

      expect(restored.taxPercent, isNull);
      expect(restored.hasOwnTaxRate, isFalse);
      expect(restored.effectiveTaxPercent(7), 7);
    });

    test('a duplicate gets new ids and a clean payment state', () {
      final copy = _document().duplicateAs(number: 'INV-0043', termDays: 7);

      expect(copy.id, isNot('doc-1'));
      expect(copy.number, 'INV-0043');
      expect(copy.status, DocumentStatus.unpaid);
      expect(copy.lines.single.id, isNot('l1'));
      expect(copy.lines.single.name, 'Design');
      expect(copy.recipient.name, 'Globex');
    });

    test('an estimate converts into an invoice, keeping its figures', () {
      final estimate = SalesDocument.fromJson(
        _document().toJson()
          ..['kind'] = DocumentKind.estimate.name
          ..['status'] = DocumentStatus.approved.name,
      );

      final invoice = estimate.asInvoice(number: 'INV-1000', termDays: 14);

      expect(invoice.kind, DocumentKind.invoice);
      expect(invoice.status, DocumentStatus.unpaid);
      expect(invoice.number, 'INV-1000');
      expect(invoice.totals.total, estimate.totals.total);
    });
  });

  group('BackupBundle', () {
    BackupBundle bundle() => BackupBundle.snapshot(
          settings: AppSettings.defaults.copyWith(defaultCurrency: Currency.eur),
          business: const BusinessProfile(name: 'Acme Studio'),
          customers: [Customer.create(name: 'Globex')],
          catalogItems: [CatalogItem.create(name: 'Design', unitPrice: 100)],
          documents: [_document()],
        );

    test('round-trips through its encoded form', () {
      final restored = BackupBundle.decode(bundle().encode());

      expect(restored.version, BackupBundle.currentVersion);
      expect(restored.business.name, 'Acme Studio');
      expect(restored.customers.single.name, 'Globex');
      expect(restored.catalogItems.single.unitPrice, 100);
      expect(restored.documents.single.number, 'INV-0042');
      expect(restored.settings.defaultCurrency, Currency.eur);
      expect(restored.recordCount, 3);
      expect(restored.invoiceCount, 1);
    });

    test('rejects a file that is not one of our backups', () {
      expect(
        () => BackupBundle.decode('{"hello":"world"}'),
        throwsA(isA<BackupImportException>()),
      );
      expect(
        () => BackupBundle.decode('not json at all'),
        throwsA(isA<BackupImportException>()),
      );
    });

    test('rejects a backup from a newer version of the app', () {
      final future = bundle().encode().replaceFirst(
            '"version": ${BackupBundle.currentVersion}',
            '"version": ${BackupBundle.currentVersion + 1}',
          );

      expect(
        () => BackupBundle.decode(future),
        throwsA(isA<BackupImportException>()),
      );
    });
  });

  group('PartySnapshot', () {
    test('lists only the details that were filled in', () {
      const party = PartySnapshot(
        name: 'Acme',
        phone: '555',
        taxNumber: 'GB1',
      );

      expect(party.detailLines, ['555', 'Tax No: GB1']);
      expect(party.isNotEmpty, isTrue);
      expect(const PartySnapshot.empty().isEmpty, isTrue);
    });
  });
}
