import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/async_action_mixin.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/invoice_status_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/loading_overlay.dart';
import 'package:invoicemaker/presentation/common/widgets/status_badge.dart';
import 'package:invoicemaker/presentation/invoice/widgets/invoice_preview.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:invoicemaker/services/pdf/pdf_service.dart';
import 'package:provider/provider.dart';

/// Shows a saved invoice: PDF preview, totals and the share/save/print actions.
class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.args});

  final InvoiceDetailArgs args;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen>
    with AsyncActionMixin {
  static const PdfService _pdfService = PdfService();

  /// A4 proportions, so the preview keeps its shape on any screen.
  static const double _pageAspectRatio = 1 / 1.414;

  /// The live invoice, falling back to the one that opened this screen.
  Invoice _current(BuildContext context) =>
      context.watch<InvoiceProvider>().getInvoiceById(widget.args.invoice.id) ??
      widget.args.invoice;

  Future<void> _runAction(Invoice invoice, PdfAction action) async {
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

  Future<void> _changeTemplate(Invoice invoice) async {
    final signature = context.read<SignatureProvider>().signature;
    final template = await Navigator.of(context).pushNamed(
      RouteNames.templateSelection,
      arguments: TemplateSelectionArgs(invoice: invoice, signature: signature),
    );
    if (template is! InvoiceTemplate || !mounted) return;
    context.read<InvoiceProvider>().setTemplate(invoice.id, template);
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

  Future<void> _delete(Invoice invoice) async {
    final confirmed =
        await ConfirmDialog.show(context, title: 'Delete Invoice');
    if (!confirmed || !mounted) return;
    context.read<InvoiceProvider>().removeInvoice(invoice);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final invoice = _current(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          IconButton(
            tooltip: AppStrings.editInvoice,
            onPressed: () => Navigator.of(context).pushNamed(
              RouteNames.createEditInvoice,
              arguments: CreateEditInvoiceArgs(invoiceId: invoice.id),
            ),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Back to invoices',
            // The dashboard is the first route once the splash replaces itself.
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        message: 'Preparing PDF...',
        child: ListView(
          children: [
            ColoredBox(
              color: AppColors.previewBg,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl,
                  horizontal: AppSpacing.xxl,
                ),
                child: AspectRatio(
                  aspectRatio: _pageAspectRatio,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(0, 1),
                          color: AppColors.darkGrey,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _changeTemplate(invoice),
                      child: InvoicePreview(invoice: invoice),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.to.isEmpty
                              ? AppStrings.unknownClient
                              : invoice.to,
                          style: const TextStyle(fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(
                        status: invoice.effectiveStatus,
                        onTap: () => _changeStatus(invoice),
                      ),
                    ],
                  ),
                  Gap.sm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            invoice.total.asCurrency(invoice.currency),
                            style: AppTextStyles.amount,
                          ),
                        ),
                      ),
                      Gap.wSm,
                      Text('Due on ${invoice.dueDate.formatted}'),
                    ],
                  ),
                  Gap.md,
                  _ActionBar(
                    onShare: () => _runAction(invoice, PdfAction.share),
                    onSave: () => _runAction(invoice, PdfAction.save),
                    onPrint: () => _runAction(invoice, PdfAction.print),
                    onDelete: () => _delete(invoice),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The share / save / print / delete strip under the preview.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onShare,
    required this.onSave,
    required this.onPrint,
    required this.onDelete,
  });

  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Action(
              icon: Icons.share_outlined,
              label: AppStrings.share,
              onTap: onShare,
            ),
            _Action(
              icon: Icons.save_alt_outlined,
              label: 'Save',
              onTap: onSave,
            ),
            _Action(
              icon: Icons.print_outlined,
              label: AppStrings.print,
              onTap: onPrint,
            ),
            _Action(
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 32),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
