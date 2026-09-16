import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/state/document_editor.dart';

/// The rows on the document, with add and reorder.
class EditorItemsCard extends StatelessWidget {
  const EditorItemsCard({
    super.key,
    required this.editor,
    required this.money,
    required this.onAddLine,
    required this.onEditLine,
  });

  final DocumentEditor editor;
  final MoneyFormat money;
  final VoidCallback onAddLine;
  final ValueChanged<LineItem> onEditLine;

  @override
  Widget build(BuildContext context) {
    final lines = editor.lines;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        Insets.lg,
        Insets.lg,
        Insets.lg,
        Insets.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: lines.isEmpty
                ? AppStrings.lineItems
                : '${AppStrings.lineItems} · ${lines.length}',
          ),
          if (lines.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.md),
              child: Text(AppCopy.noLinesBody, style: context.text.bodyMedium),
            )
          else
            // shrinkWrap so the list sits inside the page scroll view; the
            // page itself does the scrolling.
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: lines.length,
              onReorder: editor.reorderLines,
              itemBuilder: (context, index) {
                final line = lines[index];
                return _LineRow(
                  key: ValueKey(line.id),
                  index: index,
                  line: line,
                  money: money,
                  documentTaxPercent: editor.document.taxPercent,
                  onTap: () => onEditLine(line),
                );
              },
            ),
          Gap.h8,
          AppButton.secondary(
            label: 'Add item',
            icon: Icons.add,
            onPressed: onAddLine,
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    super.key,
    required this.index,
    required this.line,
    required this.money,
    required this.documentTaxPercent,
    required this.onTap,
  });

  final int index;
  final LineItem line;
  final MoneyFormat money;
  final double documentTaxPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final notes = <String>[
      '${line.quantityWithUnit} × ${money.format(line.unitPrice)}',
      if (line.discountPercent > 0)
        '−${money.percent(line.discountPercent)}',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm),
      child: Material(
        color: palette.surfaceMuted,
        borderRadius: Radii.smAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.sm,
              vertical: Insets.md,
            ),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: Insets.sm),
                    child: Icon(
                      Icons.drag_indicator,
                      size: IconSizes.md,
                      color: palette.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        line.name.trim().isEmpty ? 'Untitled item' : line.name,
                        style: context.text.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h2,
                      Text(
                        notes.join('  ·  '),
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Gap.w8,
                Text(
                  money.format(line.netAmount),
                  style: context.textRoles.amountMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
