import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';

/// The quantity, discount and tax fields shown only for a document line,
/// plus the running amount they produce.
class ItemPricingFields extends StatelessWidget {
  const ItemPricingFields({
    super.key,
    required this.quantityController,
    required this.discountController,
    required this.taxController,
    required this.subAmount,
    required this.currency,
  });

  final TextEditingController quantityController;
  final TextEditingController discountController;
  final TextEditingController taxController;

  /// Line total for the values currently in the fields.
  final double subAmount;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: 'Item Quantity',
          labelStyle: AppTextStyles.fieldLabelDark,
          child: AppTextField.integer(
            controller: quantityController,
            hintText: '1',
          ),
        ),
        LabeledField(
          label: 'Discount (%)',
          labelStyle: AppTextStyles.fieldLabelDark,
          child: AppTextField.decimal(
            controller: discountController,
            hintText: '0',
            max: 100,
          ),
        ),
        LabeledField(
          label: 'Tax Rate (%)',
          labelStyle: AppTextStyles.fieldLabelDark,
          child: AppTextField.decimal(
            controller: taxController,
            hintText: '0',
            max: 100,
          ),
        ),
        Gap.sm,
        const Text(
          '* The discount and tax is valid on this item only',
          style: AppTextStyles.caption,
        ),
        Gap.sm,
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: ListTile(
            title: const Text('Amount', style: AppTextStyles.subtotalRow),
            trailing: Text(
              subAmount.asCurrency(currency),
              style: AppTextStyles.subtotalRow,
            ),
            textColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
