import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// The app's single card surface.
///
/// One bordered, flat surface everywhere rather than stacked drop shadows:
/// depth is carried by the border and background, which stays legible in
/// dark mode and does not turn a list into a pile of floating tiles.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Draws the primary-tinted border used for a chosen item.
  final bool isSelected;

  /// Adds a vertical accent rail down the leading edge.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = accentColor;

    final content = Padding(padding: padding, child: child);

    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      // Only `shape` here: Material rejects being given both.
      shape: RoundedRectangleBorder(
        borderRadius: Radii.mdAll,
        side: BorderSide(
          color: isSelected ? palette.primary : palette.border,
          width: isSelected ? Strokes.thick : Strokes.hairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: accent == null
            ? content
            // IntrinsicHeight gives the row a bounded height so the rail can
            // stretch to it. Without it, `stretch` inside a scroll view hands
            // the rail an infinite height and layout asserts.
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: Strokes.accentRail,
                      child: ColoredBox(color: accent),
                    ),
                    Expanded(child: content),
                  ],
                ),
              ),
      ),
    );
  }
}

/// A recessed strip used for read-only rows and totals.
class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.md),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.palette.surfaceMuted,
      clipBehavior: Clip.antiAlias,
      borderRadius: Radii.smAll,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Vertical spacing between the cards on a screen.
class CardColumn extends StatelessWidget {
  const CardColumn({
    super.key,
    required this.children,
    this.spacing = Insets.md,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          children[i],
        ],
      ],
    );
  }
}
