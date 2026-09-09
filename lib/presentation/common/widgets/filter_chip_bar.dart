import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';

/// A wrapping row of single-choice filter chips.
///
/// Uses [Wrap] rather than a fixed-width horizontal list so every chip stays
/// reachable on narrow screens.
class FilterChipBar<T> extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(labelBuilder(option)),
            selected: option == selected,
            showCheckmark: false,
            backgroundColor: AppColors.white,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: option == selected
                  ? AppColors.filterText
                  : AppColors.black,
            ),
            side: const BorderSide(color: AppColors.lightGrey),
            onSelected: (_) => onSelected(option),
          ),
      ],
    );
  }
}
