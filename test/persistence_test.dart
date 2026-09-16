import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/app_settings.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/repositories/catalog_repository.dart';
import 'package:invoicemaker/data/repositories/customer_repository.dart';
import 'package:invoicemaker/data/repositories/document_repository.dart';
import 'package:invoicemaker/data/repositories/settings_repository.dart';
import 'package:invoicemaker/data/storage/local_store.dart';
import 'package:invoicemaker/domain/numbering.dart';

SalesDocument _document({
  String number = 'INV-0001',
  DocumentKind kind = DocumentKind.invoice,
  String recipient = 'Globex',
}) {
  final now = DateTime(2026, 9, 16);

  return SalesDocument(
    id: 'doc-$number',
    kind: kind,
    number: number,
    issueDate: now,
    endDate: now.add(const Duration(days: 14)),
    issuer: const PartySnapshot(name: 'Acme Studio', phone: '555'),
    recipient: PartySnapshot(name: recipient),
    lines: const [
      LineItem(id: 'l1', name: 'Design', quantity: 2, unitPrice: 100),
    ],
    currency: Currency.usd,
    status: DocumentStatus.unpaid,
    template: InvoiceTemplate.slate,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('documents survive a reload', () {
    test('a saved document reads back with its figures intact', () async {
      final store = MemoryLocalStore();

      final first = DocumentRepository(store);
      await first.load();
      await first.save(_document());

      // A second repository over the same store stands in for a restart.
      final second = DocumentRepository(store);
      await second.load();

      expect(second.all, hasLength(1));
      final restored = second.all.single;
      expect(restored.number, 'INV-0001');
      expect(restored.recipient.name, 'Globex');
      expect(restored.issuer.name, 'Acme Studio');
      expect(restored.totals.total, 200);
    });

    test('saving twice updates in place rather than duplicating', () async {
      final store = MemoryLocalStore();
      final repository = DocumentRepository(store);
      await repository.load();

      final document = _document();
      await repository.save(document);
      await repository.save(document.copyWith(number: 'INV-0009'));

      expect(repository.all, hasLength(1));
      expect(repository.all.single.number, 'INV-0009');
    });

    test('delete removes only the matching record', () async {
      final repository = DocumentRepository(MemoryLocalStore());
      await repository.load();

      await repository.save(_document());
      await repository.save(_document(number: 'INV-0002'));
      await repository.delete('doc-INV-0001');

      expect(repository.all, hasLength(1));
      expect(repository.all.single.number, 'INV-0002');
    });

    test('numbers are unique within a kind, not across kinds', () async {
      final repository = DocumentRepository(MemoryLocalStore());
      await repository.load();
      await repository.save(_document());

      expect(
        repository.isNumberAvailable('INV-0001', kind: DocumentKind.invoice),
        isFalse,
      );
      expect(
        repository.isNumberAvailable('INV-0001', kind: DocumentKind.estimate),
        isTrue,
      );
      expect(
        repository.isNumberAvailable(
          'INV-0001',
          kind: DocumentKind.invoice,
          exceptId: 'doc-INV-0001',
        ),
        isTrue,
      );
    });

    test('estimates and invoices are listed separately', () async {
      final repository = DocumentRepository(MemoryLocalStore());
      await repository.load();

      await repository.save(_document());
      await repository.save(
        _document(number: 'EST-0001', kind: DocumentKind.estimate),
      );

      expect(repository.ofKind(DocumentKind.invoice), hasLength(1));
      expect(repository.countOfKind(DocumentKind.estimate), 1);
    });
  });

  group('customers and items survive a reload', () {
    test('customers read back sorted by name', () async {
      final store = MemoryLocalStore();
      final first = CustomerRepository(store);
      await first.load();

      await first.save(Customer.create(name: 'Zeta', email: 'z@example.com'));
      await first.save(Customer.create(name: 'Alpha'));

      final second = CustomerRepository(store);
      await second.load();

      expect(
        second.all.map((customer) => customer.name).toList(),
        ['Alpha', 'Zeta'],
      );
      expect(second.search('z@example').single.name, 'Zeta');
    });

    test('saved items read back with their defaults', () async {
      final store = MemoryLocalStore();
      final first = CatalogRepository(store);
      await first.load();

      await first.save(
        CatalogItem.create(
          name: 'Consulting',
          unit: 'hr',
          unitPrice: 85.5,
          defaultTaxPercent: 20,
        ),
      );

      final second = CatalogRepository(store);
      await second.load();

      final item = second.all.single;
      expect(item.unitPrice, 85.5);
      expect(item.unit, 'hr');
      expect(item.defaultTaxPercent, 20);

      final line = item.toLineItem(quantity: 2);
      expect(line.netAmount, 171);
      expect(line.catalogItemId, item.id);
    });
  });

  group('settings survive a reload', () {
    test('preferences and the numbering sequence are kept', () async {
      final store = MemoryLocalStore();
      final first = SettingsRepository(store);
      await first.load();

      await first.save(
        first.settings.copyWith(
          defaultCurrency: Currency.gbp,
          nextInvoiceSequence: 42,
          invoicePrefix: 'BILL',
        ),
      );

      final second = SettingsRepository(store);
      await second.load();

      expect(second.settings.defaultCurrency, Currency.gbp);
      expect(second.settings.nextInvoiceSequence, 42);
      expect(
        second.settings.formatNumber(DocumentKind.invoice, 42),
        'BILL-0042',
      );
    });

    test('a missing record falls back to the defaults', () async {
      final repository = SettingsRepository(MemoryLocalStore());
      await repository.load();

      expect(repository.settings.defaultCurrency, Currency.fallback);
      expect(repository.settings.nextInvoiceSequence, 1);
    });
  });

  group('numbering', () {
    test('uses the stored sequence', () {
      const settings = AppSettings(nextInvoiceSequence: 7);
      final next = DocumentNumbering.next(
        kind: DocumentKind.invoice,
        settings: settings,
        usedNumbers: const {},
      );

      expect(next.number, 'INV-0007');
      expect(next.sequence, 7);
    });

    test('skips a number already in use', () {
      const settings = AppSettings(nextInvoiceSequence: 7);
      final next = DocumentNumbering.next(
        kind: DocumentKind.invoice,
        settings: settings,
        usedNumbers: const {'inv-0007', 'inv-0008'},
      );

      expect(next.number, 'INV-0009');
    });

    test('uses the estimate prefix for an estimate', () {
      const settings = AppSettings(nextEstimateSequence: 3);
      final next = DocumentNumbering.next(
        kind: DocumentKind.estimate,
        settings: settings,
        usedNumbers: const {},
      );

      expect(next.number, 'EST-0003');
    });
  });
}
