import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/state/document_editor.dart';

/// Who the document is for, and who it is from.
///
/// The recipient is the one thing a new document always needs, so it gets a
/// full-width action rather than a row buried in a list.
class EditorRecipientCard extends StatelessWidget {
  const EditorRecipientCard({
    super.key,
    required this.editor,
    required this.onChooseRecipient,
    required this.onClearRecipient,
    required this.onEditBusiness,
  });

  final DocumentEditor editor;
  final VoidCallback onChooseRecipient;
  final VoidCallback onClearRecipient;
  final VoidCallback onEditBusiness;

  @override
  Widget build(BuildContext context) {
    final document = editor.document;
    final recipient = document.recipient;
    final issuer = document.issuer;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: AppStrings.billedTo),
          if (recipient.isEmpty)
            AppButton.secondary(
              label: 'Choose who this is for',
              icon: Icons.person_search_outlined,
              onPressed: onChooseRecipient,
            )
          else
            _RecipientSummary(
              name: recipient.name,
              details: recipient.contactLines,
              onChange: onChooseRecipient,
              onClear: onClearRecipient,
            ),
          Gap.h20,
          const SectionHeader(title: AppStrings.billedFrom),
          if (issuer.isEmpty)
            AppButton.secondary(
              label: AppCopy.setUpBusinessAction,
              icon: Icons.storefront_outlined,
              onPressed: onEditBusiness,
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issuer.name, style: context.text.titleMedium),
                      if (issuer.contactLines.isNotEmpty) ...[
                        Gap.h2,
                        Text(
                          issuer.contactLines.first,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                AppButton.quiet(
                  label: AppStrings.edit,
                  onPressed: onEditBusiness,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecipientSummary extends StatelessWidget {
  const _RecipientSummary({
    required this.name,
    required this.details,
    required this.onChange,
    required this.onClear,
  });

  final String name;
  final List<String> details;
  final VoidCallback onChange;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.text.titleLarge),
              for (final line in details) ...[
                Gap.h2,
                Text(line, style: context.text.bodySmall),
              ],
            ],
          ),
        ),
        Gap.w8,
        IconButton(
          onPressed: onChange,
          icon: const Icon(Icons.swap_horiz, size: IconSizes.md),
          tooltip: 'Change customer',
        ),
        IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.close, size: IconSizes.md),
          tooltip: 'Remove customer',
        ),
      ],
    );
  }
}
