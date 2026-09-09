import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// What the user picked from an invoice's long-press menu.
enum InvoiceOption { share, delete, email, print }

/// The long-press menu on an invoice card.
class InvoiceOptionsDialog extends StatelessWidget {
  const InvoiceOptionsDialog({super.key, required this.invoiceNumber});

  final String invoiceNumber;

  /// Returns the chosen option, or null when dismissed.
  static Future<InvoiceOption?> show(
    BuildContext context, {
    required String invoiceNumber,
  }) {
    return showDialog<InvoiceOption>(
      context: context,
      builder: (_) => InvoiceOptionsDialog(invoiceNumber: invoiceNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(invoiceNumber, style: AppTextStyles.dialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      content: const SizedBox(
        width: AppSpacing.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              icon: Icons.share_outlined,
              label: AppStrings.share,
              option: InvoiceOption.share,
            ),
            _OptionTile(
              icon: Icons.send_outlined,
              label: AppStrings.sendEmail,
              option: InvoiceOption.email,
            ),
            _OptionTile(
              icon: Icons.print_outlined,
              label: AppStrings.print,
              option: InvoiceOption.print,
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              label: 'Delete',
              option: InvoiceOption.delete,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Text(AppStrings.cancel, style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.option,
  });

  final IconData icon;
  final String label;
  final InvoiceOption option;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => Navigator.of(context).pop(option),
    );
  }
}
