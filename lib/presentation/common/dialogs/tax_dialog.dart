import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';

/// The tax name and rate chosen for an invoice.
typedef TaxSelection = ({String name, double rate});

/// Asks for a tax name and its percentage.
class TaxDialog extends StatefulWidget {
  const TaxDialog({super.key, this.currentName = '', this.currentRate = 0});

  final String currentName;
  final double currentRate;

  /// Returns the chosen name and rate, or null when cancelled.
  static Future<TaxSelection?> show(
    BuildContext context, {
    String currentName = '',
    double currentRate = 0,
  }) {
    return showDialog<TaxSelection>(
      context: context,
      builder: (_) => TaxDialog(
        currentName: currentName,
        currentRate: currentRate,
      ),
    );
  }

  @override
  State<TaxDialog> createState() => _TaxDialogState();
}

class _TaxDialogState extends State<TaxDialog> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.currentName);
  late final TextEditingController _rateController = TextEditingController(
    text: widget.currentRate == 0 ? '' : widget.currentRate.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.tax, style: AppTextStyles.dialogTitle),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledField(
              label: 'Tax Name',
              child: AppTextField(
                controller: _nameController,
                hintText: 'Enter tax name',
              ),
            ),
            Gap.md,
            LabeledField(
              label: 'Tax Rate',
              child: AppTextField.decimal(
                controller: _rateController,
                hintText: '0%',
                max: 100,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Text(AppStrings.cancel, style: AppTextStyles.dialogCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop((
            name: _nameController.text.trim(),
            rate: double.tryParse(_rateController.text) ?? 0,
          )),
          child: const Text(AppStrings.save, style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}
