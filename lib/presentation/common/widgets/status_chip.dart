import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/palette.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// The pill showing a document's state.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.presentation,
    this.onTap,
    this.isCompact = false,
  });

  /// Built from the document, so the derived overdue and expired states are
  /// shown rather than the raw stored status.
  final DocumentStatusPresentation presentation;

  /// Tapping opens the status picker; omit for a read-only chip.
  final VoidCallback? onTap;

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = context.palette.statusColors(presentation.tone);

    return Material(
      color: colors.background,
      borderRadius: Radii.pillAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? Insets.sm : Insets.md,
            vertical: isCompact ? Insets.xxs : Insets.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                presentation.label,
                style: context.text.labelMedium?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onTap != null) ...[
                Gap.w4,
                Icon(
                  Icons.expand_more,
                  size: IconSizes.xs,
                  color: colors.foreground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small tone-coloured pill for an arbitrary label.
class ToneChip extends StatelessWidget {
  const ToneChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
  });

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.palette.statusColors(tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.sm,
        vertical: Insets.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: Radii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: IconSizes.xs, color: colors.foreground),
            Gap.w4,
          ],
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Marks a paid-tier feature.
///
/// Informational only: nothing in this version is withheld, so the badge says
/// what a feature belongs to rather than blocking it.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) => const ToneChip(
        label: AppStrings.pro,
        tone: AppStatusTone.accent,
      );
}
