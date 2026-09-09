import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/search_app_bar.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/presentation/item/item_list_screen.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/item_provider.dart';
import 'package:provider/provider.dart';

/// Picks a catalogue item to add as a line on the current invoice.
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, this.args = const AddItemArgs()});

  final AddItemArgs args;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String _query = '';

  /// Opens the line form pre-filled from [item], then closes this picker.
  Future<void> _addLine({Item? item}) async {
    final added = await Navigator.of(context).pushNamed(
      RouteNames.createEditItem,
      arguments: CreateEditItemArgs(
        item: item,
        mode: widget.args.mode,
        addToInvoice: item != null,
      ),
    );
    if (added is Item && mounted) Navigator.of(context).pop(added);
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemProvider>().search(_query);
    final currency = widget.args.mode == ItemFormMode.estimateLine
        ? context.watch<EstimateProvider>().estimate.currency
        : context.watch<InvoiceProvider>().invoice.currency;

    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.addItem,
        hintText: 'Search items',
        onQueryChanged: (query) => setState(() => _query = query),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SectionCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.add_circle),
                title: const Text(
                  AppStrings.newItem,
                  style: AppTextStyles.listHeader,
                ),
                onTap: _addLine,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('Item List', style: AppTextStyles.listHeader),
          ),
          Gap.sm,
          Expanded(
            child: items.isEmpty
                ? EmptyStateWidget(
                    message:
                        _query.isEmpty ? AppStrings.noItems : 'No matching items',
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemTile(
                        item: item,
                        price: item.price.asCurrency(currency),
                        onTap: () => _addLine(item: item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
