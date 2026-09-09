import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/presentation/item/widgets/item_pricing_fields.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/item_provider.dart';
import 'package:provider/provider.dart';

/// Creates or edits an item, either in the catalogue or on an invoice.
///
/// The invoice-line mode adds quantity, discount, tax and a live amount; the
/// catalogue mode keeps just the reusable fields.
class CreateEditItemScreen extends StatefulWidget {
  const CreateEditItemScreen({super.key, required this.args});

  final CreateEditItemArgs args;

  @override
  State<CreateEditItemScreen> createState() => _CreateEditItemScreenState();
}

class _CreateEditItemScreenState extends State<CreateEditItemScreen> {
  late final Item? _item = widget.args.item;
  bool get _isLine => widget.args.mode.isLine;
  bool get _isEstimate => widget.args.mode == ItemFormMode.estimateLine;

  late final TextEditingController _nameController =
      TextEditingController(text: _item?.name ?? '');
  late final TextEditingController _priceController = TextEditingController(
    text: (_item?.price ?? 0).toStringAsFixed(0),
  );
  late final TextEditingController _quantityController = TextEditingController(
    text: (_item?.quantity ?? 1).toString(),
  );
  late final TextEditingController _unitController =
      TextEditingController(text: _item?.unitOfMeasure ?? '');
  late final TextEditingController _discountController = TextEditingController(
    text: (_item?.discount ?? 0).toStringAsFixed(0),
  );
  late final TextEditingController _taxController = TextEditingController(
    text: (_item?.tax ?? 0).toStringAsFixed(0),
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: _item?.description ?? '');

  double _subAmount = 0;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _priceController,
      _quantityController,
      _discountController,
      _taxController,
    ]) {
      controller.addListener(_recalculate);
    }
    _subAmount = _amountFromFields();
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _priceController,
      _quantityController,
      _unitController,
      _discountController,
      _taxController,
      _descriptionController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double _amountFromFields() => Item.calculateAmount(
        price: double.tryParse(_priceController.text) ?? 0,
        quantity: _isLine ? (int.tryParse(_quantityController.text) ?? 1) : 1,
        discountPercentage:
            _isLine ? (double.tryParse(_discountController.text) ?? 0) : 0,
        taxPercentage:
            _isLine ? (double.tryParse(_taxController.text) ?? 0) : 0,
      );

  void _recalculate() {
    final amount = _amountFromFields();
    if (amount == _subAmount) return;
    setState(() => _subAmount = amount);
  }

  Item _buildItem({required bool newId}) {
    return Item(
      id: newId || _item == null
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : _item.id,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      quantity: _isLine ? (int.tryParse(_quantityController.text) ?? 1) : 1,
      unitOfMeasure: _unitController.text.trim(),
      discount: _isLine ? (double.tryParse(_discountController.text) ?? 0) : 0,
      tax: _isLine ? (double.tryParse(_taxController.text) ?? 0) : 0,
      description: _descriptionController.text,
      subAmount: _subAmount,
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      context.showSnackBar('Item name is required.', isError: true);
      return;
    }

    final items = context.read<ItemProvider>();

    if (!_isLine) {
      final item = _buildItem(newId: false);
      if (widget.args.isEditing) {
        items.updateItem(item);
      } else {
        items.addItem(item);
      }
      Navigator.of(context).pop(item);
      return;
    }

    if (widget.args.isEditing) {
      final item = _buildItem(newId: false);
      _updateLine(item);
      Navigator.of(context).pop(item);
      return;
    }

    // A new line: keep it in the catalogue too, as the old flow did.
    final item = _buildItem(newId: true);
    if (_item == null) items.addItem(item);
    _addLine(item);
    Navigator.of(context).pop(item);
  }

  void _addLine(Item item) {
    if (_isEstimate) {
      context.read<EstimateProvider>().addItem(item);
    } else {
      context.read<InvoiceProvider>().addItem(item);
    }
  }

  void _updateLine(Item item) {
    if (_isEstimate) {
      context.read<EstimateProvider>().updateItem(item.id, item);
    } else {
      context.read<InvoiceProvider>().updateItem(item.id, item);
    }
  }

  Future<void> _delete() async {
    final item = _item;
    if (item == null) return;

    final confirmed = await ConfirmDialog.show(context, title: 'Delete Item');
    if (!confirmed || !mounted) return;

    if (_isEstimate) {
      context.read<EstimateProvider>().removeItem(item);
    } else if (_isLine) {
      context.read<InvoiceProvider>().removeItem(item);
    } else {
      context.read<ItemProvider>().removeItem(item);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currency = _isEstimate
        ? context.watch<EstimateProvider>().estimate.currency
        : context.watch<InvoiceProvider>().invoice.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.isEditing ? AppStrings.editItem : AppStrings.newItem,
        ),
        actions: [
          if (widget.args.isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          IconButton(
            tooltip: AppStrings.save,
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
          Gap.wSm,
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              SectionCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledField(
                      label: 'Item Name',
                      labelStyle: AppTextStyles.fieldLabelDark,
                      child: AppTextField(
                        controller: _nameController,
                        hintText: 'Enter Item Name',
                      ),
                    ),
                    LabeledField(
                      label: 'Item Price',
                      labelStyle: AppTextStyles.fieldLabelDark,
                      child: AppTextField.decimal(
                        controller: _priceController,
                        hintText: '${currency.symbol}0',
                      ),
                    ),
                    LabeledField(
                      label: 'Unit of Measure',
                      labelStyle: AppTextStyles.fieldLabelDark,
                      child: AppTextField(
                        controller: _unitController,
                        hintText: 'None',
                      ),
                    ),
                    if (_isLine)
                      ItemPricingFields(
                        quantityController: _quantityController,
                        discountController: _discountController,
                        taxController: _taxController,
                        subAmount: _subAmount,
                        currency: currency,
                      ),
                  ],
                ),
              ),
              SectionCard(
                child: LabeledField(
                  label: 'Item Description',
                  labelStyle: AppTextStyles.fieldLabelDark,
                  child: AppTextField.multiline(
                    controller: _descriptionController,
                    hintText: 'Enter item description',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
