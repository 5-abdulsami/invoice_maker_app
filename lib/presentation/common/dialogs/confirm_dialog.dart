import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// A yes/no dialog, used for every delete confirmation in the app.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message = AppStrings.confirmDelete,
    this.confirmLabel = AppStrings.delete,
    this.cancelLabel = AppStrings.cancel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Shows the dialog and resolves to true only when the user confirms.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String message = AppStrings.confirmDelete,
    String confirmLabel = AppStrings.delete,
    String cancelLabel = AppStrings.cancel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.dialogTitle),
      content: Text(message, style: const TextStyle(fontSize: 17)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel, style: AppTextStyles.dialogCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel, style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}
