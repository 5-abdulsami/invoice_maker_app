import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/presentation/common/dialogs/amount_input_dialog.dart';

/// Asks for the shipping charge.
sealed class ShippingDialog {
  /// Returns the new amount, or null when cancelled.
  static Future<double?> show(
    BuildContext context, {
    required Currency currency,
    double? current,
  }) {
    return AmountInputDialog.show(
      context,
      title: AppStrings.shipping,
      fieldLabel: 'Shipping Amount',
      hintText: '${currency.symbol}0',
      initialValue: current,
    );
  }
}
