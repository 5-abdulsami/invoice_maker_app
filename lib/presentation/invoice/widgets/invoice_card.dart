import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/presentation/common/widgets/status_badge.dart';

/// One row in the invoice list.
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.onLongPress,
    this.onStatusTap,
  });

  final Invoice invoice;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Line(
                left: Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(fontSize: 16),
                ),
                right: Text(
                  invoice.to.isEmpty ? '-' : invoice.to,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              Gap.sm,
              _Line(
                left: Text(invoice.creationDate.formatted),
                right: Text(
                  invoice.total.asCurrency(invoice.currency),
                  style: AppTextStyles.amountSmall,
                  textAlign: TextAlign.end,
                ),
              ),
              Gap.sm,
              _Line(
                left: Text('Due in ${invoice.dueTerms} days'),
                right: Align(
                  alignment: Alignment.centerRight,
                  child: StatusBadge(
                    status: invoice.effectiveStatus,
                    onTap: onStatusTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A left/right row that lets both halves shrink instead of overflowing.
class _Line extends StatelessWidget {
  const _Line({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: Align(alignment: Alignment.centerLeft, child: left)),
        Gap.wSm,
        Flexible(child: Align(alignment: Alignment.centerRight, child: right)),
      ],
    );
  }
}
