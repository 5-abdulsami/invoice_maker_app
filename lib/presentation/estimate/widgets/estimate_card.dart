import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/estimate.dart';
import 'package:invoicemaker/presentation/common/widgets/status_badge.dart';

/// One row in the estimate list.
class EstimateCard extends StatelessWidget {
  const EstimateCard({
    super.key,
    required this.estimate,
    required this.onTap,
    this.onLongPress,
    this.onStatusTap,
  });

  final Estimate estimate;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      estimate.estimateNumber,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Gap.wSm,
                  Flexible(
                    child: Text(
                      estimate.to.isEmpty ? '-' : estimate.to,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Gap.sm,
              Row(
                children: [
                  Flexible(child: Text(estimate.creationDate.formatted)),
                  Gap.wSm,
                  Flexible(
                    child: Text(
                      estimate.total.asCurrency(estimate.currency),
                      textAlign: TextAlign.end,
                      style: AppTextStyles.amountSmall,
                    ),
                  ),
                ],
              ),
              Gap.sm,
              Row(
                children: [
                  Flexible(
                    child: Text('Valid until ${estimate.dueDate.formatted}'),
                  ),
                  Gap.wSm,
                  Align(
                    alignment: Alignment.centerRight,
                    child: EstimateStatusBadge(
                      status: estimate.status,
                      onTap: onStatusTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
