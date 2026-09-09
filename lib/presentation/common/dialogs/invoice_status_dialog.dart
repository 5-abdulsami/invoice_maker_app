import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';

/// The status a user picked, plus the amount paid when partially paid.
typedef StatusSelection = ({InvoiceStatus status, double paidAmount});

/// The "Mark as" dialog for an invoice's payment state.
class InvoiceStatusDialog extends StatefulWidget {
  const InvoiceStatusDialog({
    super.key,
    required this.status,
    required this.total,
    required this.currency,
    this.paidAmount = 0,
  });

  final InvoiceStatus status;
  final double total;
  final Currency currency;
  final double paidAmount;

  /// Returns the chosen status, or null when cancelled.
  static Future<StatusSelection?> show(
    BuildContext context, {
    required InvoiceStatus status,
    required double total,
    required Currency currency,
    double paidAmount = 0,
  }) {
    return showDialog<StatusSelection>(
      context: context,
      builder: (_) => InvoiceStatusDialog(
        status: status,
        total: total,
        currency: currency,
        paidAmount: paidAmount,
      ),
    );
  }

  @override
  State<InvoiceStatusDialog> createState() => _InvoiceStatusDialogState();
}

class _InvoiceStatusDialogState extends State<InvoiceStatusDialog> {
  late final TextEditingController _paidController = TextEditingController(
    text: widget.paidAmount == 0 ? '' : widget.paidAmount.toStringAsFixed(0),
  );

  late InvoiceStatus _selected = widget.status == InvoiceStatus.overdue
      ? InvoiceStatus.unpaid
      : widget.status;
  bool _showAmountError = false;

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_selected != InvoiceStatus.partiallyPaid) {
      Navigator.of(context).pop((status: _selected, paidAmount: 0.0));
      return;
    }

    final paid = double.tryParse(_paidController.text) ?? 0;
    if (paid <= 0 || paid > widget.total) {
      setState(() => _showAmountError = true);
      return;
    }
    Navigator.of(context).pop((status: _selected, paidAmount: paid));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: Text('Mark as', style: AppTextStyles.heading2),
      ),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final status in InvoiceStatus.selectable)
              ListTile(
                title: Text(status.label),
                tileColor: _selected == status
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                trailing: _selected == status
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => setState(() {
                  _selected = status;
                  _showAmountError = false;
                }),
              ),
            if (_selected == InvoiceStatus.partiallyPaid)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: AppTextField.decimal(
                  controller: _paidController,
                  hintText: '${widget.currency.symbol}0',
                  max: widget.total,
                  helperText:
                      'Must be less than the invoice total amount and not be 0',
                  helperTextColor:
                      _showAmountError ? AppColors.red : AppColors.black,
                  onChanged: (_) {
                    if (_showAmountError) {
                      setState(() => _showAmountError = false);
                    }
                  },
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
          onPressed: _confirm,
          child:
              const Text(AppStrings.change, style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}
