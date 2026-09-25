import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/presentation/common/widgets/status_chip.dart';
import 'package:invoicemaker/presentation/documents/document_actions.dart';
import 'package:invoicemaker/presentation/documents/widgets/document_preview.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// A saved document: how it will print, what it is worth, and what to do
/// with it.
class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({super.key, required this.document});

  /// The document as it was when this screen opened; the live copy is read
  /// from the controller so edits made here are reflected immediately.
  final SalesDocument document;

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen>
    with AsyncAction {
  /// The stored document, falling back to the one passed in if it was just
  /// deleted from underneath this screen.
  SalesDocument _current(BuildContext context) =>
      context.watch<DocumentController>().byId(widget.document.id) ??
      widget.document;

  @override
  void initState() {
    super.initState();
    // Renders the templates beside this one in the background once the
    // screen has settled, so "Change" opens the picker onto finished pages.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final document =
          context.read<DocumentController>().byId(widget.document.id) ??
              widget.document;
      unawaited(
        DocumentPreview.precacheAround(
          context,
          document: document,
          around: document.template,
          radius: 1,
        ),
      );
    });
  }

  Future<void> _output(SalesDocument document, PdfAction action) async {
    await run(
      () => DocumentActionRunner.output(
        context,
        document: document,
        action: action,
      ),
    );
  }

  Future<void> _edit(SalesDocument document) async {
    await AppNavigator.openEditor(
      context,
      kind: document.kind,
      documentId: document.id,
    );
  }

  Future<void> _changeTemplate(SalesDocument document) async {
    final template = await AppNavigator.openTemplatePicker(
      context,
      document: document,
    );
    if (template == null || !mounted) return;

    await context.read<DocumentController>().setTemplate(
          document.id,
          template,
        );
  }

  Future<void> _changeStatus(SalesDocument document) async {
    await DocumentActionRunner.changeStatus(context, document: document);
  }

  Future<void> _delete(SalesDocument document) async {
    final deleted = await DocumentActionRunner.delete(
      context,
      document: document,
    );
    if (!deleted || !mounted) return;

    context.showMessage(AppCopy.deletedMessage);
    Navigator.of(context).pop();
  }

  Future<void> _duplicate(SalesDocument document) async {
    final documents = context.read<DocumentController>();
    final copy = await documents.duplicate(document);
    if (!mounted) return;

    context.showMessage(AppCopy.duplicatedMessage);
    await AppNavigator.openDocumentDetail(context, copy, replace: true);
  }

  Future<void> _convert(SalesDocument document) async {
    final documents = context.read<DocumentController>();
    final invoice = await documents.convertToInvoice(document);
    if (!mounted) return;

    context.showMessage('Invoice ${invoice.number} created');
    await AppNavigator.openDocumentDetail(context, invoice, replace: true);
  }

  Future<void> _openActions(SalesDocument document) async {
    final action = await DocumentActionsSheet.show(
      context,
      document: document,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case DocumentAction.share:
        await _output(document, PdfAction.share);
      case DocumentAction.print:
        await _output(document, PdfAction.print);
      case DocumentAction.edit:
        await _edit(document);
      case DocumentAction.changeStatus:
        await _changeStatus(document);
      case DocumentAction.duplicate:
        await _duplicate(document);
      case DocumentAction.convertToInvoice:
        await _convert(document);
      case DocumentAction.delete:
        await _delete(document);
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = _current(context);
    final settings = context.watch<SettingsController>();
    final money = settings.moneyFormatFor(document.currency);
    final totals = document.totals;

    return AppScaffold(
      title: document.number,
      actions: [
        IconButton(
          onPressed: isBusy ? null : () => _edit(document),
          icon: const Icon(Icons.edit_outlined),
          tooltip: AppStrings.edit,
        ),
        IconButton(
          onPressed: isBusy ? null : () => _openActions(document),
          icon: const Icon(Icons.more_vert),
          tooltip: 'More actions',
        ),
      ],
      bottomBar: BottomActionBar(
        children: [
          AppButton.secondary(
            label: AppStrings.print,
            icon: Icons.print_outlined,
            onPressed: isBusy ? null : () => _output(document, PdfAction.print),
          ),
          AppButton(
            label: AppStrings.share,
            icon: Icons.ios_share,
            isBusy: isBusy,
            onPressed: () => _output(document, PdfAction.share),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        message: 'Preparing the PDF',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Insets.gutter,
            Insets.lg,
            Insets.gutter,
            Insets.xl,
          ),
          children: [
            CardColumn(
              children: [
                _SummaryCard(
                  document: document,
                  amount: money.format(totals.total),
                  balance: totals.hasPayment
                      ? money.format(totals.balanceDue)
                      : null,
                  dueLabel: DocumentStatusPresentation.endDateLabel(
                    document.status,
                    document.endDate,
                  ),
                  onStatusTap: () => _changeStatus(document),
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(
                        title: AppStrings.preview,
                        actionLabel: AppStrings.change,
                        onAction: () => _changeTemplate(document),
                      ),
                      DocumentPreview(
                        document: document,
                        onTap: () => _changeTemplate(document),
                      ),
                      Gap.h12,
                      Text(
                        '${document.template.label} template',
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                _BreakdownCard(document: document, money: money),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Who it is for, what it is worth, and whether it is settled.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.document,
    required this.amount,
    required this.dueLabel,
    required this.onStatusTap,
    this.balance,
  });

  final SalesDocument document;
  final String amount;
  final String? balance;
  final String dueLabel;
  final VoidCallback onStatusTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  document.recipientName,
                  style: context.text.headlineSmall,
                ),
              ),
              Gap.w8,
              StatusChip(
                presentation: document.statusPresentation,
                onTap: onStatusTap,
              ),
            ],
          ),
          Gap.h16,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: context.textRoles.amountHero),
          ),
          if (balance != null) ...[
            Gap.h4,
            Text(
              '$balance ${AppStrings.balanceDue.toLowerCase()}',
              style: context.text.bodyMedium,
            ),
          ],
          Gap.h8,
          Text(dueLabel, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

/// The figures, itemised.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.document, required this.money});

  final SalesDocument document;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final totals = document.totals;
    final taxName = document.taxLabel.trim().isEmpty
        ? AppStrings.tax
        : document.taxLabel.trim();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: '${AppStrings.lineItems} · ${document.lines.length}',
          ),
          for (final line in totals.lines) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          line.line.name,
                          style: context.text.bodyLarge,
                        ),
                        Text(
                          '${line.line.quantityWithUnit} × '
                          '${money.format(line.line.unitPrice)}',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Gap.w12,
                  Text(
                    money.format(line.netAmount),
                    style: context.textRoles.amountSmall,
                  ),
                ],
              ),
            ),
          ],
          Divider(color: context.palette.border, height: Insets.xl),
          AmountRow(
            label: AppStrings.subtotal,
            amount: money.format(totals.subtotal),
          ),
          if (totals.hasDiscount)
            AmountRow(
              label: AppStrings.discount,
              amount: money.formatNegated(totals.discountAmount),
            ),
          if (totals.hasTax)
            AmountRow(label: taxName, amount: money.format(totals.taxAmount)),
          if (totals.hasShipping)
            AmountRow(
              label: AppStrings.shipping,
              amount: money.format(totals.shipping),
            ),
          AmountRow(
            label: AppStrings.total,
            amount: money.format(totals.total),
            emphasis: AmountEmphasis.total,
          ),
          if (totals.hasPayment) ...[
            AmountRow(
              label: AppStrings.amountPaid,
              amount: money.formatNegated(totals.amountPaid),
            ),
            AmountRow(
              label: AppStrings.balanceDue,
              amount: money.format(totals.balanceDue),
              emphasis: AmountEmphasis.strong,
            ),
          ],
          if (document.notes.trim().isNotEmpty) ...[
            Gap.h16,
            const SectionHeader(title: AppStrings.notes),
            Text(document.notes.trim(), style: context.text.bodyMedium),
          ],
          if (document.paymentTerms.trim().isNotEmpty) ...[
            Gap.h16,
            const SectionHeader(title: AppStrings.paymentTerms),
            Text(document.paymentTerms.trim(), style: context.text.bodyMedium),
          ],
        ],
      ),
    );
  }
}
