import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// A single-select row of chips.
///
/// Scrolls horizontally rather than wrapping, so the filter bar keeps a fixed
/// height and the list below it never jumps as the label lengths change.
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.countOf,
    this.padding = const EdgeInsets.symmetric(horizontal: Insets.gutter),
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;

  /// Optional count shown after the label, e.g. `Unpaid 3`.
  final int? Function(T option)? countOf;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) Gap.w8,
            _Chip(
              label: labelOf(options[i]),
              count: countOf?.call(options[i]),
              isSelected: options[i] == selected,
              onTap: () => onSelected(options[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    final foreground =
        isSelected ? colors.onPrimary : colors.textSecondary;

    return Material(
      color: isSelected ? colors.primary : colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.pillAll,
        side: BorderSide(
          color: isSelected ? colors.primary : colors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count != null && count! > 0) ...[
                Gap.w4,
                Text(
                  '$count',
                  style: context.text.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
