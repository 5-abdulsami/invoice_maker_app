import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// A card with the app's standard padding, used to group form sections.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.padding = AppSpacing.card,
  });

  final Widget child;

  /// Optional caption shown above the content, e.g. "Business".
  final String? title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg),
                child: Text(title!, style: AppTextStyles.sectionTitle),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/// A rounded grey strip used for read-only rows such as dates and totals.
class FieldTile extends StatelessWidget {
  const FieldTile({
    super.key,
    required this.child,
    this.color,
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
