import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';

/// A dialog holding one numeric field, used for discount, tax rate and
/// shipping. Resolves to the entered amount, or null if cancelled.
class AmountInputDialog extends StatefulWidget {
  const AmountInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    this.fieldLabel,
    this.initialValue,
    this.max,
    this.suffixText,
  });

  final String title;
  final String hintText;

  /// Caption above the field; omit for a bare field.
  final String? fieldLabel;
  final double? initialValue;

  /// Largest accepted value, e.g. 100 for a percentage.
  final double? max;
  final String? suffixText;

  static Future<double?> show(
    BuildContext context, {
    required String title,
    required String hintText,
    String? fieldLabel,
    double? initialValue,
    double? max,
    String? suffixText,
  }) {
    return showDialog<double>(
      context: context,
      builder: (_) => AmountInputDialog(
        title: title,
        hintText: hintText,
        fieldLabel: fieldLabel,
        initialValue: initialValue,
        max: max,
        suffixText: suffixText,
      ),
    );
  }

  @override
  State<AmountInputDialog> createState() => _AmountInputDialogState();
}

class _AmountInputDialogState extends State<AmountInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: (widget.initialValue ?? 0) == 0
        ? ''
        : widget.initialValue!.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = AppTextField.decimal(
      controller: _controller,
      hintText: widget.hintText,
      max: widget.max,
      suffixText: widget.suffixText,
    );

    return AlertDialog(
      title: Text(widget.title, style: AppTextStyles.dialogTitle),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.fieldLabel != null)
              LabeledField(label: widget.fieldLabel!, child: field)
            else
              field,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel, style: AppTextStyles.dialogCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            double.tryParse(_controller.text) ?? 0,
          ),
          child: const Text(AppStrings.save, style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}
