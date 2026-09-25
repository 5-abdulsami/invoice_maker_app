import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/status_chip.dart';

/// One row in the document list.
///
/// Reads top to bottom: who it is for, what it is worth, and whether it needs
/// attention. The number is secondary, which is the opposite of how a ledger
/// is ordered but matches how a person looks for an invoice.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.money,
    required this.dateFormat,
    required this.onTap,
    this.onLongPress,
    this.onStatusTap,
  });

  final SalesDocument document;
  final MoneyFormat money;
  final DateFormatOption dateFormat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final totals = document.totals;
    final isOverdue = document.isPastEndDate;

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      accentColor: isOverdue ? palette.danger : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      document.recipientName,
                      style: context.text.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h2,
                    Text(
                      document.number,
                      style: context.textRoles.documentNumber.copyWith(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    money.format(totals.total),
                    style: context.textRoles.amountMedium,
                  ),
                  Gap.h4,
                  StatusChip(
                    presentation: document.statusPresentation,
                    onTap: onStatusTap,
                    isCompact: true,
                  ),
                ],
              ),
            ],
          ),
          Gap.h12,
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: IconSizes.xs,
                color: palette.textTertiary,
              ),
              Gap.w4,
              Expanded(
                child: Text(
                  document.issueDate.formatWith(dateFormat),
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap.w8,
              Flexible(
                child: Text(
                  DocumentStatusPresentation.endDateLabel(
                    document.status,
                    document.endDate,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: isOverdue ? palette.danger : palette.textSecondary,
                    fontWeight: isOverdue ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
