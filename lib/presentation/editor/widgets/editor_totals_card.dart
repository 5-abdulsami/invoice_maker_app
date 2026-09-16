import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/state/document_editor.dart';

/// Subtotal, the adjustments that can be tapped to edit, and the total.
class EditorTotalsCard extends StatelessWidget {
  const EditorTotalsCard({
    super.key,
    required this.editor,
    required this.money,
    required this.onEditDiscount,
    required this.onEditTax,
    required this.onEditShipping,
  });

  final DocumentEditor editor;
  final MoneyFormat money;
  final VoidCallback onEditDiscount;
  final VoidCallback onEditTax;
  final VoidCallback onEditShipping;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final document = editor.document;
    final totals = editor.totals;

    final taxName = document.taxLabel.trim().isEmpty
        ? AppStrings.tax
        : document.taxLabel.trim();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Summary'),
          AmountRow(
            label: AppStrings.subtotal,
            amount: money.format(totals.subtotal),
          ),
          Divider(color: palette.border),
          AmountRow(
            label: AppStrings.discount,
            amount: totals.hasDiscount
                ? money.formatNegated(totals.discountAmount)
                : 'None',
            caption: totals.hasDiscount && totals.discount.isPercent
                ? money.percent(totals.discount.value)
                : null,
            onTap: onEditDiscount,
          ),
          AmountRow(
            label: taxName,
            amount: totals.hasTax ? money.format(totals.taxAmount) : 'None',
            caption: _taxCaption(totals.uniformTaxRate),
            onTap: onEditTax,
          ),
          AmountRow(
            label: AppStrings.shipping,
            amount:
                totals.hasShipping ? money.format(totals.shipping) : 'None',
            onTap: onEditShipping,
          ),
          Divider(color: palette.border),
          Gap.h4,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.md,
              vertical: Insets.sm,
            ),
            decoration: BoxDecoration(
              color: palette.primarySurface,
              borderRadius: Radii.smAll,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.total,
                    style: context.text.titleLarge?.copyWith(
                      color: palette.primary,
                    ),
                  ),
                ),
                Gap.w8,
                Flexible(
                  child: Text(
                    money.format(totals.total),
                    textAlign: TextAlign.end,
                    style: context.textRoles.amountLarge.copyWith(
                      color: palette.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Names the rate only when every row shares one.
  String? _taxCaption(double? uniformRate) {
    if (uniformRate == null) return 'Mixed rates';
    if (uniformRate <= 0) return null;
    return money.percent(uniformRate);
  }
}
