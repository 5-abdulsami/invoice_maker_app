import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';

/// A dialog holding one multi-line field, used for terms and payment details.
/// Resolves to the entered text, or null if cancelled.
class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    super.key,
    required this.title,
    this.fieldLabel,
    this.initialValue = '',
    this.hintText = '',
    this.minLines = 6,
  });

  final String title;
  final String? fieldLabel;
  final String initialValue;
  final String hintText;
  final int minLines;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? fieldLabel,
    String initialValue = '',
    String hintText = '',
    int minLines = 6,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => TextInputDialog(
        title: title,
        fieldLabel: fieldLabel,
        initialValue: initialValue,
        hintText: hintText,
        minLines: minLines,
      ),
    );
  }

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = AppTextField.multiline(
      controller: _controller,
      hintText: widget.hintText,
      minLines: widget.minLines,
      maxLines: widget.minLines * 2,
      autofocus: true,
    );

    return AlertDialog(
      title: Text(widget.title, style: AppTextStyles.dialogTitle),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: SingleChildScrollView(
          child: widget.fieldLabel == null
              ? field
              : LabeledField(label: widget.fieldLabel!, child: field),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Text(AppStrings.cancel, style: AppTextStyles.dialogCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text(AppStrings.save, style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}
