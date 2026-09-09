import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/presentation/common/dialogs/text_input_dialog.dart';

/// Asks for the invoice terms and conditions.
sealed class TermsDialog {
  /// Returns the new text, or null when cancelled.
  static Future<String?> show(BuildContext context, {String current = ''}) {
    return TextInputDialog.show(
      context,
      title: 'New ${AppStrings.terms}',
      fieldLabel: '${AppStrings.terms} Detail',
      initialValue: current,
    );
  }
}
