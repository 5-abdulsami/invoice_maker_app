import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';

/// The line items, the "Add Item" row and the subtotal.
///
/// The totals rows that follow it live in `TotalsSectionCard`, which the form
/// passes in as [footer] so both keep sharing one card.
class ItemsSectionCard extends StatelessWidget {
  const ItemsSectionCard({
    super.key,
    required this.items,
    required this.subTotal,
    required this.currency,
    required this.onAddItem,
    required this.onEditItem,
    required this.onReorder,
    this.footer,
  });

  final List<Item> items;
  final double subTotal;
  final Currency currency;
  final VoidCallback onAddItem;
  final ValueChanged<Item> onEditItem;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            leading: const Icon(Icons.add_shopping_cart),
            title: Text(
              items.isEmpty
                  ? AppStrings.items
                  : '${AppStrings.items}(${items.length})',
              style: AppTextStyles.tileTitleDark,
            ),
          ),
          if (items.isNotEmpty)
            ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              onReorderItem: onReorder,
              itemBuilder: (context, index) => Padding(
                key: ValueKey(items[index].id),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: _ItemRow(
                  item: items[index],
                  currency: currency,
                  onTap: () => onEditItem(items[index]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: FieldTile(
              color: AppColors.lightGrey,
              onTap: onAddItem,
              child: const ListTile(
                leading: Icon(Icons.add_circle),
                title: Text(
                  AppStrings.addItem,
                  style: AppTextStyles.tileSubtitle,
                ),
              ),
            ),
          ),
          FieldTile(
            color: AppColors.lightGrey,
            child: ListTile(
              title: const Text(
                AppStrings.subtotal,
                style: AppTextStyles.subtotalRow,
              ),
              trailing: Text(
                subTotal.asCurrency(currency),
                style: AppTextStyles.subtotalRow,
              ),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

/// One draggable line item.
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.currency,
    required this.onTap,
  });

  final Item item;
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FieldTile(
      color: AppColors.lightGrey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu, color: AppColors.primaryDark),
            Gap.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '${AppStrings.discount} (${item.discount.asPercent})',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                  Text(
                    '${AppStrings.tax} (${item.tax.asPercent})',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            Gap.wMd,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.quantity} x ${item.price.asCurrency(currency)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  '-${item.discountAmount.asCurrency(currency)}',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                Text(
                  item.taxAmount.asCurrency(currency),
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                Text(
                  item.subAmount.asCurrency(currency),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
