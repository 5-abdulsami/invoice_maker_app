import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/async_action_mixin.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/invoice_options_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/invoice_status_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_drawer.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/filter_chip_bar.dart';
import 'package:invoicemaker/presentation/common/widgets/loading_overlay.dart';
import 'package:invoicemaker/presentation/common/widgets/search_app_bar.dart';
import 'package:invoicemaker/presentation/invoice/widgets/invoice_card.dart';
import 'package:invoicemaker/presentation/invoice/widgets/invoice_summary_cards.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/settings_provider.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:invoicemaker/services/pdf/pdf_service.dart';
import 'package:provider/provider.dart';

/// The invoice tab: totals, status filters, search and the invoice list.
class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen>
    with AsyncActionMixin {
  static const PdfService _pdfService = PdfService();

  /// Null stands for the "All" chip.
  static const List<InvoiceStatus?> _filters = [
    null,
    InvoiceStatus.unpaid,
    InvoiceStatus.partiallyPaid,
    InvoiceStatus.overdue,
    InvoiceStatus.paid,
  ];

  InvoiceStatus? _filter;
  String _query = '';

  Future<void> _createInvoice() async {
    final settings = context.read<SettingsProvider>();
    context.read<InvoiceProvider>().resetDraft(
          currency: settings.defaultCurrency,
          dueTermDays: settings.defaultDueTerms,
        );
    context.read<ClientProvider>().clearSelection();

    await Navigator.of(context).pushNamed(
      RouteNames.createEditInvoice,
      arguments: const CreateEditInvoiceArgs(),
    );
  }

  Future<void> _openOptions(Invoice invoice) async {
    final option = await InvoiceOptionsDialog.show(
      context,
      invoiceNumber: invoice.invoiceNumber,
    );
    if (option == null || !mounted) return;

    if (option == InvoiceOption.delete) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Delete Invoice',
      );
      if (!confirmed || !mounted) return;
      context.read<InvoiceProvider>().removeInvoice(invoice);
      return;
    }

    await _runPdfAction(
      invoice,
      switch (option) {
        InvoiceOption.share => PdfAction.share,
        InvoiceOption.email => PdfAction.email,
        InvoiceOption.print => PdfAction.print,
        InvoiceOption.delete => PdfAction.preview,
      },
    );
  }

  Future<void> _runPdfAction(Invoice invoice, PdfAction action) async {
    final business = context.read<BusinessProvider>().business;
    final client = context.read<ClientProvider>().client;
    final signature = context.read<SignatureProvider>().signature;

    await runGuarded(
      () => _pdfService.execute(
        invoice: invoice,
        business: business,
        client: client,
        signature: signature,
        action: action,
      ),
    );
  }

  Future<void> _changeStatus(Invoice invoice) async {
    final selection = await InvoiceStatusDialog.show(
      context,
      status: invoice.status,
      total: invoice.total,
      currency: invoice.currency,
      paidAmount: invoice.paidAmount,
    );
    if (selection == null || !mounted) return;

    context.read<InvoiceProvider>().setStatus(
          invoice.id,
          selection.status,
          paidAmount: selection.paidAmount,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final currency = context.watch<SettingsProvider>().defaultCurrency;
    final invoices = provider.filtered(status: _filter, query: _query);

    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.invoice,
        hintText: 'Search invoices',
        onQueryChanged: (query) => setState(() => _query = query),
        actions: [
          IconButton(
            tooltip: AppStrings.report,
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.report),
            icon: const Icon(Icons.insert_chart_outlined_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: LoadingOverlay(
        isLoading: isBusy,
        message: 'Preparing PDF...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Column(
                children: [
                  InvoiceSummaryCards(
                    totalUnpaid: provider.totalUnpaid(invoices),
                    totalOverdue: provider.totalOverdue(invoices),
                    currency: currency,
                  ),
                  Gap.md,
                  FilterChipBar<InvoiceStatus?>(
                    options: _filters,
                    selected: _filter,
                    labelBuilder: (status) => status?.label ?? 'All',
                    onSelected: (status) => setState(() => _filter = status),
                  ),
                  Gap.sm,
                ],
              ),
            ),
            Expanded(
              child: invoices.isEmpty
                  ? EmptyStateWidget(
                      message: _query.isEmpty
                          ? AppStrings.noInvoices
                          : 'No invoices match "$_query"',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      itemCount: invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = invoices[index];
                        return InvoiceCard(
                          invoice: invoice,
                          onTap: () => Navigator.of(context).pushNamed(
                            RouteNames.invoiceDetail,
                            arguments: InvoiceDetailArgs(invoice: invoice),
                          ),
                          onLongPress: () => _openOptions(invoice),
                          onStatusTap: () => _changeStatus(invoice),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppStrings.newInvoice,
        onPressed: _createInvoice,
        child: const Icon(Icons.add),
      ),
    );
  }
}
