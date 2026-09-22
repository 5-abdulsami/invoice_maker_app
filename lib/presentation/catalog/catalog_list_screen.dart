import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/search_field.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/state/catalog_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// The saved products and services.
class CatalogListScreen extends StatefulWidget {
  const CatalogListScreen({super.key});

  @override
  State<CatalogListScreen> createState() => _CatalogListScreenState();
}

class _CatalogListScreenState extends State<CatalogListScreen> {
  String _query = '';

  Future<void> _open([CatalogItem? item]) async {
    await AppNavigator.openCatalogEditor(context, item: item);
  }

  Future<void> _delete(CatalogItem item) async {
    final confirmed = await AppSheet.confirm(
      context,
      title: AppCopy.deleteItemTitle,
      message: AppCopy.deleteItemBody,
    );
    if (!confirmed || !mounted) return;

    await context.read<CatalogController>().delete(item.id);
    if (mounted) context.showMessage(AppCopy.deletedMessage);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CatalogController>();
    final money = context.watch<SettingsController>().moneyFormat;
    final items = controller.search(_query);
    final hasAny = !controller.isEmpty;

    return AppScaffold(
      title: AppStrings.catalog,
      maxContentWidth: Layout.listWidth,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-items',
        onPressed: _open,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newItem),
      ),
      body: Column(
        children: [
          if (hasAny)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.gutter,
                Insets.md,
                Insets.gutter,
                Insets.md,
              ),
              child: AppSearchField(
                hint: 'Search items',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? _emptyState(hasAny: hasAny)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Insets.gutter,
                      Insets.xs,
                      Insets.gutter,
                      Insets.scrollBottom,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Gap.h8,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CatalogRow(
                        item: item,
                        price: money.format(item.unitPrice),
                        onTap: () => _open(item),
                        onDelete: () => _delete(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required bool hasAny}) {
    if (hasAny) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: AppCopy.noSearchResultsTitle,
        message: AppCopy.noSearchResultsBody,
      );
    }

    return const AppEmptyState(
      icon: Icons.inventory_2_outlined,
      title: AppCopy.noItemsTitle,
      message: AppCopy.noItemsBody,
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({
    required this.item,
    required this.price,
    required this.onTap,
    required this.onDelete,
  });

  final CatalogItem item;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final notes = <String>[
      if (item.unit.trim().isNotEmpty) 'per ${item.unit.trim()}',
      if (item.defaultTaxPercent != null && item.defaultTaxPercent! > 0)
        'tax ${item.defaultTaxPercent!.toStringAsFixed(0)}%',
    ];

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: context.text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description.trim().isNotEmpty) ...[
                  Gap.h2,
                  Text(
                    item.description.trim(),
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (notes.isNotEmpty) ...[
                  Gap.h2,
                  Text(notes.join(' · '), style: context.text.labelSmall),
                ],
              ],
            ),
          ),
          Gap.w8,
          Text(price, style: context.textRoles.amountMedium),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: IconSizes.md,
              color: palette.textTertiary,
            ),
            tooltip: AppStrings.delete,
          ),
        ],
      ),
    );
  }
}
