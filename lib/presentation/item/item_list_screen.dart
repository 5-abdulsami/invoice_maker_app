import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_drawer.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/search_app_bar.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/item_provider.dart';
import 'package:provider/provider.dart';

/// The item tab: the reusable catalogue of products and services.
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  String _query = '';

  Future<void> _delete(Item item) async {
    final confirmed = await ConfirmDialog.show(context, title: 'Delete Item');
    if (!confirmed || !mounted) return;
    context.read<ItemProvider>().removeItem(item);
  }

  Future<void> _clearAll() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete All Items',
      message: 'This removes every saved item. Continue?',
    );
    if (!confirmed || !mounted) return;
    context.read<ItemProvider>().clearItems();
  }

  void _openForm([Item? item]) {
    Navigator.of(context).pushNamed(
      RouteNames.createEditItem,
      arguments: CreateEditItemArgs(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemProvider>().search(_query);
    final currency = context.watch<InvoiceProvider>().invoice.currency;

    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.item,
        hintText: 'Search items',
        onQueryChanged: (query) => setState(() => _query = query),
        actions: [
          IconButton(
            tooltip: 'Delete all',
            onPressed: items.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_outline_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: items.isEmpty
          ? EmptyStateWidget(
              message: _query.isEmpty ? AppStrings.noItems : 'No matching items',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemTile(
                  item: item,
                  price: item.price.asCurrency(currency),
                  onTap: () => _openForm(item),
                  onEdit: () => _openForm(item),
                  onDelete: () => _delete(item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppStrings.newItem,
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// One catalogue item row.
class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.price,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Item item;
  final String price;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: item.description.isEmpty
            ? null
            : Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                onSelected: (value) =>
                    value == 'edit' ? onEdit?.call() : onDelete?.call(),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
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
