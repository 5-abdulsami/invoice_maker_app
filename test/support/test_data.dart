import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/data/models/business_profile.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';

/// Repositories filled with deliberately awkward data: long names, long
/// amounts and many rows, the content most likely to break a layout.
///
/// Returns the repositories with one invoice and one estimate to open.
Future<(AppRepositories, SalesDocument, SalesDocument)>
    seededRepositories() async {
  final repositories = await AppRepositories.inMemory();
  final now = DateTime(2026, 9, 21);

  await repositories.business.save(
    const BusinessProfile(
      name: 'Samionyx Digital Solutions and Creative Studio (Private) Limited',
      email: 'accounts.department@samionyx-digital-solutions.example',
      phone: '+92 316 0816689',
      address: 'Office 1204, Twelfth Floor, Business Tower, Blue Area,\n'
          'Islamabad, Pakistan',
      taxNumber: 'NTN-1234567-8',
      website: 'samionyx.example',
    ),
  );

  for (var i = 0; i < 12; i++) {
    await repositories.customers.save(
      Customer.create(
        name: i == 0
            ? 'Globex International Trading Corporation of Rawalpindi'
            : 'Customer number $i',
        email: 'accounts.payable.department$i@customer-domain.example',
        phone: '+92 315 53502$i',
        address: 'Street $i, Sector G-11, Islamabad',
        now: now,
      ),
    );
  }

  for (var i = 0; i < 12; i++) {
    await repositories.catalog.save(
      CatalogItem.create(
        name: i == 0
            ? 'Complete mobile application design and development package'
            : 'Catalog item $i',
        description: 'A description long enough to wrap onto a second line',
        unit: 'hours',
        unitPrice: 1234567.89,
        now: now,
      ),
    );
  }

  // Most documents bill in rupees and a few in dollars, so the home screen's
  // per-currency figures are exercised too.
  await repositories.settings.save(
    repositories.settings.settings.copyWith(defaultCurrency: Currency.pkr),
  );

  SalesDocument document(
    DocumentKind kind,
    int index,
    DocumentStatus status, {
    Currency currency = Currency.pkr,
  }) {
    final lines = [
      for (var i = 0; i < 6; i++)
        LineItem(
          id: 'line-$index-$i',
          name: i == 0
              ? 'Complete mobile application design and development'
              : 'Line item $i',
          description: 'Scoped work with a description that wraps',
          unit: 'hours',
          quantity: 12.5,
          unitPrice: 987654.32,
          discountPercent: 10,
          taxPercent: 16,
        ),
    ];

    return SalesDocument.draft(
      kind: kind,
      number: '${kind.numberPrefix}-${1000 + index}',
      issuer: const PartySnapshot(
        name: 'Samionyx Digital Solutions and Creative Studio',
      ),
      currency: currency,
      template: InvoiceTemplate.aurora,
      termDays: 14,
      now: now,
    ).copyWith(
      recipient: const PartySnapshot(
        name: 'Globex International Trading Corporation of Rawalpindi',
        email: 'accounts.payable@globex.example',
      ),
      lines: lines,
      discount: const Adjustment.percent(5),
      status: status,
      notes: 'Thank you for your business. ' * 4,
    );
  }

  final invoice = document(DocumentKind.invoice, 1, DocumentStatus.unpaid);
  final estimate = document(DocumentKind.estimate, 2, DocumentStatus.pending);
  await repositories.documents.save(invoice);
  await repositories.documents.save(estimate);
  for (var i = 3; i < 15; i++) {
    await repositories.documents.save(
      document(
        i.isEven ? DocumentKind.invoice : DocumentKind.estimate,
        i,
        i.isEven ? DocumentStatus.paid : DocumentStatus.approved,
        currency: i % 4 == 0 ? Currency.usd : Currency.pkr,
      ),
    );
  }

  return (repositories, invoice, estimate);
}

/// Loads the app's real fonts: the default test font is far wider than
/// Roboto, and would report overflows no user could ever see.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final file in files) {
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }

  await family('AppSans', [
    'roboto-regular',
    'roboto-medium',
    'roboto-bold',
    'roboto-italic',
  ]);
  await family('AppSansNarrow', [
    'robotocondensed-light',
    'robotocondensed-regular',
    'robotocondensed-bold',
  ]);
}
