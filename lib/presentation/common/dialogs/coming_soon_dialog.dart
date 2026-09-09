import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// Explains that a listed feature has not been built yet.
///
/// Used by the settings entries that previously had an empty `onTap`.
class ComingSoonDialog extends StatelessWidget {
  const ComingSoonDialog({super.key, required this.feature});

  final String feature;

  static Future<void> show(BuildContext context, String feature) {
    return showDialog<void>(
      context: context,
      builder: (_) => ComingSoonDialog(feature: feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(feature, style: AppTextStyles.dialogTitle),
      content: const Text(AppStrings.featureComingSoon),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK', style: AppTextStyles.dialogConfirm),
        ),
      ],
    );
  }
}
