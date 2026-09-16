import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/core/utils/validators.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';

/// What the line sheet returned.
@immutable
class LineItemResult {
  const LineItemResult({
    required this.line,
    this.saveToCatalog = false,
    this.delete = false,
  });

  final LineItem line;

  /// Whether the user also wants this kept as a reusable saved item.
  final bool saveToCatalog;

  /// Whether the row should be removed from the document.
  final bool delete;
}

/// Adds or edits one row on a document.
///
/// Shows the row's own total as the fields change, so the effect of a
/// quantity or discount is visible before the sheet is dismissed.
sealed class LineItemSheet {
  static Future<LineItemResult?> show(
    BuildContext context, {
    required Currency currency,
    required MoneyFormat money,
    required double documentTaxPercent,
    LineItem? line,
    bool offerSaveToCatalog = false,
  }) {
    final isEditing = line != null;

    return AppSheet.show<LineItemResult>(
      context: context,
      title: isEditing ? 'Edit item' : AppStrings.newItem,
      builder: (sheetContext) => _LineItemForm(
        currency: currency,
        money: money,
        documentTaxPercent: documentTaxPercent,
        line: line,
        offerSaveToCatalog: offerSaveToCatalog,
      ),
    );
  }
}

class _LineItemForm extends StatefulWidget {
  const _LineItemForm({
    required this.currency,
    required this.money,
    required this.documentTaxPercent,
    required this.offerSaveToCatalog,
    this.line,
  });

  final Currency currency;
  final MoneyFormat money;
  final double documentTaxPercent;
  final LineItem? line;
  final bool offerSaveToCatalog;

  @override
  State<_LineItemForm> createState() => _LineItemFormState();
}

class _LineItemFormState extends State<_LineItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final LineItem? _original = widget.line;
  late final bool _isEditing = _original != null;

  late final TextEditingController _nameController =
      TextEditingController(text: _original?.name ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: _original?.description ?? '');
  late final TextEditingController _unitController =
      TextEditingController(text: _original?.unit ?? '');
  late final TextEditingController _quantityController = TextEditingController(
    text: _original?.quantityLabel ?? '1',
  );
  late final TextEditingController _priceController = TextEditingController(
    text: _original == null || _original.unitPrice == 0
        ? ''
        : _original.unitPrice.toStringAsFixed(widget.currency.decimalDigits),
  );
  late final TextEditingController _discountController = TextEditingController(
    text: (_original?.discountPercent ?? 0) == 0
        ? ''
        : _original!.discountPercent.toStringAsFixed(0),
  );
  late final TextEditingController _taxController = TextEditingController(
    text: _original?.taxPercent == null
        ? ''
        : _original!.taxPercent!.toStringAsFixed(0),
  );

  final FocusNode _quantityFocus = FocusNode();

  bool _saveToCatalog = false;
  bool _showMoreOptions = false;

  @override
  void initState() {
    super.initState();
    _showMoreOptions = (_original?.discountPercent ?? 0) > 0 ||
        _original?.taxPercent != null ||
        (_original?.description.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _descriptionController,
      _unitController,
      _quantityController,
      _priceController,
      _discountController,
      _taxController,
    ]) {
      controller.dispose();
    }
    _quantityFocus.dispose();
    super.dispose();
  }

  /// The row as currently typed, used for the live total and for saving.
  LineItem get _draft {
    final base = _original;
    final quantity = Validators.parseQuantity(_quantityController.text);
    final price = Validators.parseAmount(_priceController.text);
    final discount = Validators.parsePercent(_discountController.text);
    final taxText = _taxController.text.trim();
    final tax = taxText.isEmpty ? null : Validators.parsePercent(taxText);

    if (base == null) {
      return LineItem.create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        unit: _unitController.text.trim(),
        quantity: quantity,
        unitPrice: price,
        discountPercent: discount,
        taxPercent: tax,
      );
    }

    return base.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      unit: _unitController.text.trim(),
      quantity: quantity,
      unitPrice: price,
      discountPercent: discount,
      taxPercent: tax,
      clearTaxPercent: tax == null,
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      LineItemResult(line: _draft, saveToCatalog: _saveToCatalog),
    );
  }

  void _delete() {
    final line = _original;
    if (line == null) return;
    Navigator.of(context).pop(LineItemResult(line: line, delete: true));
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    final effectiveTax = draft.effectiveTaxPercent(widget.documentTaxPercent);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          0,
          Insets.gutter,
          Insets.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _nameController,
              label: AppStrings.itemName,
              hint: 'Design work, Coffee beans, Repair',
              validator: Validators.required,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _quantityFocus.requestFocus(),
            ),
            Gap.h16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField.quantity(
                    controller: _quantityController,
                    label: AppStrings.quantity,
                    focusNode: _quantityFocus,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Gap.w12,
                Expanded(
                  flex: 2,
                  child: AppTextField.money(
                    controller: _priceController,
                    currencySymbol: widget.currency.symbol,
                    label: AppStrings.unitPrice,
                    decimalDigits: widget.currency.decimalDigits,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ],
            ),
            Gap.h12,
            AppPanel(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Line total',
                      style: context.text.titleMedium,
                    ),
                  ),
                  Text(
                    widget.money.format(draft.netAmount),
                    style: context.textRoles.amountMedium,
                  ),
                ],
              ),
            ),
            Gap.h12,
            if (!_showMoreOptions)
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton.quiet(
                  label: 'More options',
                  icon: Icons.tune,
                  onPressed: () => setState(() => _showMoreOptions = true),
                ),
              )
            else
              _moreOptions(effectiveTax),
            if (widget.offerSaveToCatalog) ...[
              Gap.h12,
              _SaveToCatalogToggle(
                value: _saveToCatalog,
                onChanged: (value) => setState(() => _saveToCatalog = value),
              ),
            ],
            Gap.h20,
            AppButton(
              label: _isEditing ? AppStrings.saveChanges : AppStrings.add,
              onPressed: _submit,
            ),
            if (_isEditing) ...[
              Gap.h8,
              AppButton.secondary(
                label: AppStrings.remove,
                icon: Icons.delete_outline,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _moreOptions(double effectiveTax) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Details'),
        AppTextField.multiline(
          controller: _descriptionController,
          label: AppStrings.description,
          hint: 'Printed under the item name',
          minLines: 2,
          maxLines: 4,
        ),
        Gap.h16,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _unitController,
                label: AppStrings.unit,
                hint: 'hr, kg, pcs',
                textCapitalization: TextCapitalization.none,
              ),
            ),
            Gap.w12,
            Expanded(
              child: AppTextField.percent(
                controller: _discountController,
                label: AppStrings.discount,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Gap.h16,
        AppTextField.percent(
          controller: _taxController,
          label: '${AppStrings.taxRate} for this item',
          helper: _taxController.text.trim().isEmpty
              ? 'Using the document rate of ${widget.money.percent(widget.documentTaxPercent)}'
              : null,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

/// Offers to keep a one-off row as a reusable saved item.
class _SaveToCatalogToggle extends StatelessWidget {
  const _SaveToCatalogToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
          ),
          Gap.w4,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Save to my items', style: context.text.titleMedium),
                Text(
                  'Reuse it on future documents',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
