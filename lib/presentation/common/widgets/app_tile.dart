import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// A tappable settings-style row: title, optional subtitle, optional value,
/// and a chevron when it leads somewhere.
class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;

  /// Right-aligned current value, e.g. the selected currency.
  final String? value;

  final IconData? icon;

  /// Replaces the leading icon.
  final Widget? leading;

  /// Replaces the value and chevron, e.g. with a switch.
  final Widget? trailing;

  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final titleColor = isDestructive ? palette.danger : palette.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.lg,
          vertical: Insets.md,
        ),
        child: Row(
          children: [
            if (leading != null)
              leading!
            else if (icon != null)
              Icon(
                icon,
                size: IconSizes.md,
                color: isDestructive ? palette.danger : palette.textSecondary,
              ),
            if (leading != null || icon != null) Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.text.titleMedium?.copyWith(
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Gap.h2,
                    Text(subtitle!, style: context.text.bodySmall),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              Gap.w12,
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.screenSize.width * _valueWidthFraction,
                ),
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: context.text.bodyMedium,
                ),
              ),
            ],
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: Insets.sm),
                child: trailing,
              )
            else if (showChevron && onTap != null)
              Padding(
                padding: const EdgeInsets.only(left: Insets.xs),
                child: Icon(
                  Icons.chevron_right,
                  size: IconSizes.md,
                  color: palette.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Caps the value column so a long value cannot squeeze out the title.
  static const double _valueWidthFraction = 0.35;
}

/// A list of [AppTile]s separated by hairlines, as one grouped block.
class AppTileGroup extends StatelessWidget {
  const AppTileGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Divider(
              height: Strokes.hairline,
              thickness: Strokes.hairline,
              indent: Insets.lg,
              endIndent: Insets.lg,
              color: palette.border,
            ),
          children[i],
        ],
      ],
    );
  }
}

/// A label and value side by side, for read-only detail rows.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
    this.isMuted = false,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: isMuted ? context.text.bodySmall : context.text.bodyMedium,
            ),
          ),
          Gap.w12,
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: valueStyle ??
                  context.text.bodyMedium?.copyWith(
                    color: context.palette.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
