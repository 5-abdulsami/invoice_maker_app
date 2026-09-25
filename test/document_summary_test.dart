import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';

void main() {
  late AppRepositories repositories;
  late SettingsController settings;
  late DocumentController documents;

  setUp(() async {
    repositories = await AppRepositories.inMemory();
    settings = SettingsController(repositories.settings);
    documents = DocumentController(
      documents: repositories.documents,
      business: repositories.business,
      settings: settings,
    );
    await settings.setDefaultCurrency(Currency.pkr);
  });

  SalesDocument invoice(
    String number,
    Currency currency,
    double amount, {
    DocumentStatus status = DocumentStatus.unpaid,
    int termDays = 14,
    DateTime? issued,
    DocumentKind kind = DocumentKind.invoice,
  }) {
    return SalesDocument.draft(
      kind: kind,
      number: number,
      issuer: const PartySnapshot(name: 'Studio'),
      currency: currency,
      template: InvoiceTemplate.slate,
      termDays: termDays,
      now: issued,
    ).copyWith(
      lines: [LineItem(id: number, name: 'Work', unitPrice: amount)],
      status: status,
    );
  }

  test('starts with the default currency even before any invoice', () {
    final summaries = documents.summaries;
    expect(summaries, hasLength(1));
    expect(summaries.single.currency, Currency.pkr);
    expect(summaries.single.outstanding, 0);
  });

  test('never adds amounts in different currencies together', () async {
    await documents.save(invoice('INV-1', Currency.pkr, 1000));
    await documents.save(invoice('INV-2', Currency.usd, 50));
    await documents.save(invoice('INV-3', Currency.usd, 25));

    final summaries = documents.summaries;
    expect(summaries.map((s) => s.currency), [Currency.pkr, Currency.usd]);
    expect(summaries[0].outstanding, 1000);
    expect(summaries[1].outstanding, 75);
    expect(summaries[1].invoiceCount, 2);
  });

  test('counts paid and overdue invoices, and ignores estimates', () async {
    await documents.save(
      invoice('INV-1', Currency.pkr, 300, status: DocumentStatus.paid),
    );
    // Issued a month ago on seven-day terms, so now overdue.
    await documents.save(
      invoice(
        'INV-2',
        Currency.pkr,
        200,
        termDays: 7,
        issued: DateTime.now().subtract(const Duration(days: 30)),
      ),
    );
    await documents.save(
      invoice(
        'EST-1',
        Currency.pkr,
        999,
        kind: DocumentKind.estimate,
        status: DocumentStatus.pending,
      ),
    );

    final summary = documents.summaries.single;
    expect(summary.collected, 300);
    expect(summary.outstanding, 200);
    expect(summary.overdue, 200);
    expect(summary.overdueCount, 1);
    expect(summary.invoiceCount, 2);
  });
}
