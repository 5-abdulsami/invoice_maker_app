import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// A small all-caps heading above a block, with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;

  /// Text of a quiet action on the right, e.g. "View all".
  final String? actionLabel;

  final VoidCallback? onAction;

  /// Replaces the text action.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: context.textRoles.overline,
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, Insets.xxl),
                padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// A money row: label on the left, amount on the right.
///
/// Used by the editor's totals block and the detail screen, so both read the
/// same and both align their figures.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.emphasis = AmountEmphasis.normal,
    this.onTap,
    this.caption,
  });

  final String label;
  final String amount;
  final AmountEmphasis emphasis;

  /// Makes the row tappable, for the editable discount and tax rows.
  final VoidCallback? onTap;

  /// A quiet note under the label, e.g. the rate applied.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final roles = context.textRoles;

    final labelStyle = switch (emphasis) {
      AmountEmphasis.normal => context.text.bodyMedium,
      AmountEmphasis.strong => context.text.titleMedium,
      AmountEmphasis.total => context.text.titleLarge,
    };

    final amountStyle = switch (emphasis) {
      AmountEmphasis.normal => roles.amountSmall,
      AmountEmphasis.strong => roles.amountMedium,
      AmountEmphasis.total => roles.amountLarge,
    };

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: labelStyle),
                if (caption != null) ...[
                  Gap.h2,
                  Text(caption!, style: context.text.bodySmall),
                ],
              ],
            ),
          ),
          Gap.w12,
          Flexible(
            child: Text(
              amount,
              textAlign: TextAlign.end,
              style: amountStyle,
            ),
          ),
          if (onTap != null) ...[
            Gap.w4,
            Icon(
              Icons.chevron_right,
              size: IconSizes.sm,
              color: palette.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.smAll,
      child: row,
    );
  }
}

/// How much weight an [AmountRow] carries.
enum AmountEmphasis { normal, strong, total }
