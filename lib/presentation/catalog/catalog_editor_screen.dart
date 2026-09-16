import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/validators.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/state/catalog_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// Creates or edits a saved product or service.
class CatalogEditorScreen extends StatefulWidget {
  const CatalogEditorScreen({super.key, this.item});

  final CatalogItem? item;

  bool get isEditing => item != null;

  @override
  State<CatalogEditorScreen> createState() => _CatalogEditorScreenState();
}

class _CatalogEditorScreenState extends State<CatalogEditorScreen>
    with AsyncAction {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final CatalogItem? _original = widget.item;

  late final TextEditingController _name =
      TextEditingController(text: _original?.name ?? '');
  late final TextEditingController _description =
      TextEditingController(text: _original?.description ?? '');
  late final TextEditingController _unit =
      TextEditingController(text: _original?.unit ?? '');
  late final TextEditingController _price = TextEditingController(
    text: _original == null || _original.unitPrice == 0
        ? ''
        : _original.unitPrice.toString(),
  );
  late final TextEditingController _discount = TextEditingController(
    text: (_original?.defaultDiscountPercent ?? 0) == 0
        ? ''
        : _original!.defaultDiscountPercent.toStringAsFixed(0),
  );
  late final TextEditingController _tax = TextEditingController(
    text: _original?.defaultTaxPercent == null
        ? ''
        : _original!.defaultTaxPercent!.toStringAsFixed(0),
  );

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _unit,
      _price,
      _discount,
      _tax,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final catalog = context.read<CatalogController>();
    final existing = _original;

    final taxText = _tax.text.trim();
    final taxPercent =
        taxText.isEmpty ? null : Validators.parsePercent(taxText);

    final item = existing == null
        ? CatalogItem.create(
            name: _name.text.trim(),
            description: _description.text.trim(),
            unit: _unit.text.trim(),
            unitPrice: Validators.parseAmount(_price.text),
            defaultDiscountPercent: Validators.parsePercent(_discount.text),
            defaultTaxPercent: taxPercent,
          )
        : existing.copyWith(
            name: _name.text.trim(),
            description: _description.text.trim(),
            unit: _unit.text.trim(),
            unitPrice: Validators.parseAmount(_price.text),
            defaultDiscountPercent: Validators.parsePercent(_discount.text),
            defaultTaxPercent: taxPercent,
            clearDefaultTaxPercent: taxPercent == null,
          );

    var didSave = false;
    await run(
      () async {
        await catalog.save(item);
        didSave = true;
      },
      successMessage: AppCopy.savedMessage,
    );
    if (!didSave || !mounted) return;

    Navigator.of(context).pop(item);
  }

  Future<void> _delete() async {
    final item = _original;
    if (item == null) return;

    final confirmed = await AppSheet.confirm(
      context,
      title: AppCopy.deleteItemTitle,
      message: AppCopy.deleteItemBody,
    );
    if (!confirmed || !mounted) return;

    await context.read<CatalogController>().delete(item.id);
    if (!mounted) return;

    context.showMessage(AppCopy.deletedMessage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsController>().settings.defaultCurrency;

    return AppScaffold(
      title: widget.isEditing ? 'Edit item' : AppStrings.newItem,
      actions: [
        if (widget.isEditing)
          IconButton(
            onPressed: isBusy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.delete,
          ),
      ],
      bottomBar: BottomActionBar(
        children: [
          AppButton(
            label: widget.isEditing ? AppStrings.saveChanges : AppStrings.save,
            icon: Icons.check,
            isBusy: isBusy,
            onPressed: _save,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.gutter,
              Insets.lg,
              Insets.gutter,
              Insets.xl,
            ),
            children: [
              CardColumn(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _name,
                          label: AppStrings.itemName,
                          hint: 'What you are selling',
                          validator: Validators.required,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap.h16,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppTextField.money(
                                controller: _price,
                                currencySymbol: currency.symbol,
                                label: AppStrings.unitPrice,
                                decimalDigits: currency.decimalDigits,
                              ),
                            ),
                            Gap.w12,
                            Expanded(
                              child: AppTextField(
                                controller: _unit,
                                label: AppStrings.unit,
                                hint: 'hr',
                                textCapitalization: TextCapitalization.none,
                              ),
                            ),
                          ],
                        ),
                        Gap.h16,
                        AppTextField.multiline(
                          controller: _description,
                          label: AppStrings.description,
                          hint: 'Printed under the name on a document',
                          minLines: 2,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Applied automatically whenever this item is added '
                          'to a document.',
                          style: context.text.bodySmall,
                        ),
                        Gap.h16,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField.percent(
                                controller: _discount,
                                label: AppStrings.discount,
                              ),
                            ),
                            Gap.w12,
                            Expanded(
                              child: AppTextField.percent(
                                controller: _tax,
                                label: AppStrings.taxRate,
                                helper: 'Blank uses the document rate',
                              ),
                            ),
                          ],
                        ),
                      ],
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
