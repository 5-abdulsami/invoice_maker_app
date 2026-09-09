import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// A summary of invoiced, collected and outstanding money.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final currency = context.watch<SettingsProvider>().defaultCurrency;
    final invoices = provider.invoices;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.report)),
      body: invoices.isEmpty
          ? const EmptyStateWidget(message: AppStrings.noInvoices)
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    SectionCard(
                      title: 'Overview',
                      child: Column(
                        children: [
                          _ReportRow(
                            label: 'Invoices',
                            value: '${invoices.length}',
                          ),
                          _ReportRow(
                            label: 'Total invoiced',
                            value: _sum(invoices).asCurrency(currency),
                          ),
                          _ReportRow(
                            label: 'Collected',
                            value: _collected(invoices).asCurrency(currency),
                            valueColor: AppColors.lightGreenText,
                          ),
                          _ReportRow(
                            label: 'Outstanding',
                            value: provider
                                .totalUnpaid(invoices)
                                .asCurrency(currency),
                          ),
                          _ReportRow(
                            label: 'Overdue',
                            value: provider
                                .totalOverdue(invoices)
                                .asCurrency(currency),
                            valueColor: AppColors.red,
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'By status',
                      child: Column(
                        children: [
                          for (final status in InvoiceStatus.values)
                            _ReportRow(
                              label: status.label,
                              value: '${_countFor(invoices, status)} '
                                  '(${_totalFor(invoices, status).asCurrency(currency)})',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  double _sum(List<Invoice> invoices) =>
      invoices.fold(0, (sum, invoice) => sum + invoice.total);

  /// Money actually received: paid invoices in full, plus part payments.
  double _collected(List<Invoice> invoices) => invoices.fold(
        0,
        (sum, invoice) => sum +
            (invoice.status == InvoiceStatus.paid
                ? invoice.total
                : invoice.paidAmount),
      );

  int _countFor(List<Invoice> invoices, InvoiceStatus status) =>
      invoices.where((invoice) => invoice.effectiveStatus == status).length;

  double _totalFor(List<Invoice> invoices, InvoiceStatus status) => invoices
      .where((invoice) => invoice.effectiveStatus == status)
      .fold(0, (sum, invoice) => sum + invoice.total);
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.tileTitle)),
          Gap.wSm,
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.amountSmall.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
