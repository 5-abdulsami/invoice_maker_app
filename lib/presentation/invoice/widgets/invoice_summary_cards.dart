import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';

/// The "Total Unpaid" and "Total Overdue" tiles above the invoice list.
///
/// Stacks on very narrow screens instead of forcing two fixed-width cards.
class InvoiceSummaryCards extends StatelessWidget {
  const InvoiceSummaryCards({
    super.key,
    required this.totalUnpaid,
    required this.totalOverdue,
    required this.currency,
  });

  final double totalUnpaid;
  final double totalOverdue;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        label: 'Total Unpaid',
        value: totalUnpaid.asCurrency(currency),
      ),
      _SummaryCard(
        label: 'Total Overdue',
        value: totalOverdue.asCurrency(currency),
        valueColor: AppColors.red,
      ),
    ];

    if (context.isSmallScreen) {
      return Column(
        children: [
          for (final card in cards) SizedBox(width: double.infinity, child: card),
        ],
      );
    }

    // IntrinsicHeight gives the Row a bounded height, so the two cards can
    // stretch to match each other inside the list's unbounded column.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards.first),
          Gap.wSm,
          Expanded(child: cards.last),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Gap.sm,
            FittedBox(
              child: Text(
                value,
                style: AppTextStyles.heading1.copyWith(color: valueColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
