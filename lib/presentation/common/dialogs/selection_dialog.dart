import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// A single-choice list dialog.
///
/// Backs the language, currency, due terms, number format and date format
/// pickers. Resolves to the chosen option, or null if cancelled.
class SelectionDialog<T> extends StatelessWidget {
  const SelectionDialog({
    super.key,
    required this.title,
    required this.options,
    required this.labelBuilder,
    this.selected,
    this.subtitleBuilder,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T option) labelBuilder;
  final String? Function(T option)? subtitleBuilder;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T option) labelBuilder,
    T? selected,
    String? Function(T option)? subtitleBuilder,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => SelectionDialog<T>(
        title: title,
        options: options,
        labelBuilder: labelBuilder,
        selected: selected,
        subtitleBuilder: subtitleBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.dialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final option in options)
              ListTile(
                title: Text(labelBuilder(option)),
                subtitle: switch (subtitleBuilder?.call(option)) {
                  final String subtitle => Text(
                      subtitle,
                      style: AppTextStyles.caption,
                    ),
                  null => null,
                },
                tileColor: option == selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                trailing: option == selected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
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
      ],
    );
  }
}
