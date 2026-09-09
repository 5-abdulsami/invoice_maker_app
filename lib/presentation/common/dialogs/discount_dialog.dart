import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/presentation/common/dialogs/amount_input_dialog.dart';

/// Asks for the invoice-wide discount percentage.
sealed class DiscountDialog {
  /// Returns the new percentage, or null when cancelled.
  static Future<double?> show(BuildContext context, {double? current}) {
    return AmountInputDialog.show(
      context,
      title: AppStrings.discount,
      hintText: '0%',
      suffixText: 'Percentage',
      initialValue: current,
      max: 100,
    );
  }
}
