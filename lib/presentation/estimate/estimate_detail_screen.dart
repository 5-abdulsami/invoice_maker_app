import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/estimate_status.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/estimate.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/selection_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/presentation/common/widgets/status_badge.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:provider/provider.dart';

/// Shows a saved estimate with its lines, totals and status.
class EstimateDetailScreen extends StatelessWidget {
  const EstimateDetailScreen({super.key, required this.args});

  final EstimateDetailArgs args;

  Future<void> _changeStatus(BuildContext context, Estimate estimate) async {
    final status = await SelectionDialog.show<EstimateStatus>(
      context,
      title: 'Mark as',
      options: EstimateStatus.values,
      selected: estimate.status,
      labelBuilder: (value) => value.label,
    );
    if (status == null || !context.mounted) return;
    context.read<EstimateProvider>().setStatus(estimate.id, status);
  }

  Future<void> _delete(BuildContext context, Estimate estimate) async {
    final confirmed =
        await ConfirmDialog.show(context, title: 'Delete Estimate');
    if (!confirmed || !context.mounted) return;
    context.read<EstimateProvider>().removeEstimate(estimate);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final estimate =
        context.watch<EstimateProvider>().getEstimateById(args.estimate.id) ??
            args.estimate;

    return Scaffold(
      appBar: AppBar(
        title: Text(estimate.estimateNumber),
        actions: [
          IconButton(
            tooltip: AppStrings.editEstimate,
            onPressed: () => Navigator.of(context).pushNamed(
              RouteNames.createEditEstimate,
              arguments: CreateEditEstimateArgs(estimateId: estimate.id),
            ),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () => _delete(context, estimate),
            icon: const Icon(Icons.delete_outline),
          ),
          Gap.wSm,
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            estimate.to.isEmpty
                                ? AppStrings.unknownClient
                                : estimate.to,
                            style: AppTextStyles.heading2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        EstimateStatusBadge(
                          status: estimate.status,
                          onTap: () => _changeStatus(context, estimate),
                        ),
                      ],
                    ),
                    Gap.sm,
                    Text('Created ${estimate.creationDate.formatted}'),
                    Text('Valid until ${estimate.dueDate.formatted}'),
                  ],
                ),
              ),
              SectionCard(
                title: AppStrings.items,
                child: Column(
                  children: [
                    for (final item in estimate.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.quantity} x '
                          '${item.price.asCurrency(estimate.currency)}',
                        ),
                        trailing: Text(
                          item.subAmount.asCurrency(estimate.currency),
                          style: AppTextStyles.amountSmall,
                        ),
                      ),
                    const Divider(),
                    _TotalRow(
                      label: AppStrings.subtotal,
                      value: estimate.subTotal.asCurrency(estimate.currency),
                    ),
                    if (estimate.discount != 0)
                      _TotalRow(
                        label:
                            '${AppStrings.discount} (${estimate.discount.asPercent})',
                        value:
                            '-${estimate.discountAmount.asCurrency(estimate.currency)}',
                      ),
                    if (estimate.tax != 0)
                      _TotalRow(
                        label: '${AppStrings.tax} (${estimate.tax.asPercent})',
                        value:
                            estimate.taxAmount.asCurrency(estimate.currency),
                      ),
                    if (estimate.shippingCharges != 0)
                      _TotalRow(
                        label: AppStrings.shipping,
                        value: estimate.shippingCharges
                            .asCurrency(estimate.currency),
                      ),
                    _TotalRow(
                      label: AppStrings.total,
                      value: estimate.total.asCurrency(estimate.currency),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              if (estimate.terms.isNotEmpty)
                SectionCard(
                  title: AppStrings.terms,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(estimate.terms),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold ? AppTextStyles.amountSmall : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
