import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/search_field.dart';
import 'package:invoicemaker/state/catalog_controller.dart';
import 'package:provider/provider.dart';

/// What the item picker returned.
sealed class CatalogPick {
  const CatalogPick();
}

/// A saved item was chosen, to be pre-filled into the row form.
class CatalogPickSaved extends CatalogPick {
  const CatalogPickSaved(this.item);

  final CatalogItem item;
}

/// The user wants a row that is not from the saved list.
class CatalogPickOneOff extends CatalogPick {
  const CatalogPickOneOff();
}

/// Chooses what to add to a document.
///
/// Opens straight onto the saved items with a one-off option at the top, so
/// a user with nothing saved is one tap from typing a row and a user with a
/// catalogue is one tap from reusing one.
sealed class CatalogPickerSheet {
  static Future<CatalogPick?> show(
    BuildContext context, {
    required MoneyFormat money,
  }) {
    return AppSheet.show<CatalogPick>(
      context: context,
      title: 'Add item',
      builder: (sheetContext) => _CatalogPickerBody(money: money),
    );
  }
}

class _CatalogPickerBody extends StatefulWidget {
  const _CatalogPickerBody({required this.money});

  final MoneyFormat money;

  @override
  State<_CatalogPickerBody> createState() => _CatalogPickerBodyState();
}

class _CatalogPickerBodyState extends State<_CatalogPickerBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CatalogController>();
    final items = controller.search(_query);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!controller.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.gutter),
            child: AppSearchField(
              hint: 'Search saved items',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        Gap.h12,
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: Insets.lg),
            children: [
              AppTile(
                title: 'Type a new item',
                subtitle: 'Not from your saved list',
                icon: Icons.edit_outlined,
                showChevron: false,
                onTap: () =>
                    Navigator.of(context).pop(const CatalogPickOneOff()),
              ),
              if (items.isNotEmpty) ...[
                Divider(height: Insets.lg, color: context.palette.border),
                for (final item in items)
                  AppTile(
                    title: item.name,
                    subtitle: item.description.isEmpty
                        ? null
                        : item.description,
                    value: widget.money.format(item.unitPrice),
                    showChevron: false,
                    onTap: () =>
                        Navigator.of(context).pop(CatalogPickSaved(item)),
                  ),
              ] else if (_query.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Insets.lg),
                  child: Text(
                    'No saved item matches that.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Insets.gutter,
                    Insets.sm,
                    Insets.gutter,
                    Insets.sm,
                  ),
                  child: Text(
                    AppCopy.noItemsBody,
                    style: context.text.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
