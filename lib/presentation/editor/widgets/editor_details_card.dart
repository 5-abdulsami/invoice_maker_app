import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/common/widgets/status_chip.dart';
import 'package:invoicemaker/state/document_editor.dart';

/// Currency, template, payment state and the text blocks printed at the
/// bottom of the document.
class EditorDetailsCard extends StatelessWidget {
  const EditorDetailsCard({
    super.key,
    required this.editor,
    required this.money,
    required this.hasBusinessSignature,
    required this.onPickCurrency,
    required this.onPickTemplate,
    required this.onEditStatus,
    required this.onEditNotes,
    required this.onEditPaymentTerms,
    required this.onEditPaymentDetails,
    required this.onToggleSignature,
  });

  final DocumentEditor editor;
  final MoneyFormat money;

  /// Whether a signature has been captured in the business profile.
  final bool hasBusinessSignature;

  final VoidCallback onPickCurrency;
  final VoidCallback onPickTemplate;
  final VoidCallback onEditStatus;
  final VoidCallback onEditNotes;
  final VoidCallback onEditPaymentTerms;
  final VoidCallback onEditPaymentDetails;
  final ValueChanged<bool> onToggleSignature;

  @override
  Widget build(BuildContext context) {
    final document = editor.document;
    final totals = editor.totals;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(Insets.lg, Insets.xs, Insets.lg, 0),
            child: SectionHeader(title: 'Document'),
          ),
          AppTileGroup(
            children: [
              AppTile(
                title: AppStrings.currency,
                value: document.currency.shortLabel,
                onTap: onPickCurrency,
              ),
              AppTile(
                title: AppStrings.template,
                value: document.template.label,
                onTap: onPickTemplate,
              ),
              if (editor.isInvoice)
                AppTile(
                  title: AppStrings.status,
                  onTap: onEditStatus,
                  showChevron: false,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusChip(
                        presentation: document.statusPresentation,
                        isCompact: true,
                      ),
                      Gap.w4,
                      Icon(
                        Icons.chevron_right,
                        size: IconSizes.md,
                        color: context.palette.textTertiary,
                      ),
                    ],
                  ),
                  subtitle: totals.hasPayment
                      ? '${money.format(totals.amountPaid)} paid · '
                          '${money.format(totals.balanceDue)} due'
                      : null,
                ),
              AppTile(
                title: AppStrings.notes,
                subtitle: _preview(document.notes) ??
                    'Anything the customer should read',
                onTap: onEditNotes,
              ),
              AppTile(
                title: AppStrings.paymentTerms,
                subtitle:
                    _preview(document.paymentTerms) ?? 'When payment is due',
                onTap: onEditPaymentTerms,
              ),
              AppTile(
                title: AppStrings.paymentDetails,
                subtitle: _preview(document.paymentDetails) ??
                    'Bank details or how to pay',
                onTap: onEditPaymentDetails,
              ),
              if (hasBusinessSignature)
                AppTile(
                  title: 'Include signature',
                  subtitle: 'Print your saved signature on this document',
                  showChevron: false,
                  trailing: Switch(
                    value: document.signaturePath != null,
                    onChanged: onToggleSignature,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// A one-line preview of a text block, or null when it is empty.
  String? _preview(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return null;
    return trimmed.length <= _previewLength
        ? trimmed
        : '${trimmed.substring(0, _previewLength)}…';
  }

  static const int _previewLength = 60;
}
