import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/state/document_editor.dart';

/// The document's number, dates and reference.
class EditorHeaderCard extends StatelessWidget {
  const EditorHeaderCard({
    super.key,
    required this.editor,
    required this.dateFormat,
    required this.numberController,
    required this.referenceController,
    required this.onPickIssueDate,
    required this.onPickEndDate,
  });

  final DocumentEditor editor;
  final DateFormatOption dateFormat;
  final TextEditingController numberController;
  final TextEditingController referenceController;
  final VoidCallback onPickIssueDate;
  final VoidCallback onPickEndDate;

  @override
  Widget build(BuildContext context) {
    final document = editor.document;
    final kind = document.kind;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: numberController,
            label: '${kind.label} ${AppStrings.documentNumber.toLowerCase()}',
            hint: '${kind.numberPrefix}-0001',
            textCapitalization: TextCapitalization.characters,
            onChanged: editor.setNumber,
          ),
          Gap.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppFieldButton(
                  label: kind.issueDateLabel,
                  value: document.issueDate.formatWith(dateFormat),
                  icon: Icons.event_outlined,
                  onTap: onPickIssueDate,
                ),
              ),
              Gap.w12,
              Expanded(
                child: AppFieldButton(
                  label: kind.endDateLabel,
                  value: document.endDate.formatWith(dateFormat),
                  icon: Icons.event_outlined,
                  onTap: onPickEndDate,
                ),
              ),
            ],
          ),
          Gap.h8,
          Text(
            DocumentStatusPresentation.endDateLabel(
              document.status,
              document.endDate,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Gap.h16,
          AppTextField(
            controller: referenceController,
            label: AppStrings.reference,
            hint: 'Purchase order or job number',
            textCapitalization: TextCapitalization.characters,
            onChanged: editor.setReference,
          ),
        ],
      ),
    );
  }
}
