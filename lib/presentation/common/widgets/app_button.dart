import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// How much weight a button carries.
enum AppButtonStyle {
  /// The one main action on a screen.
  primary,

  /// A secondary action, outlined.
  secondary,

  /// A low-emphasis action with no container.
  quiet,

  /// A destructive action.
  danger,
}

/// The app's button.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
    this.isBusy = false,
    this.expand = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.expand = true,
  }) : style = AppButtonStyle.secondary;

  const AppButton.quiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.expand = false,
  }) : style = AppButtonStyle.quiet;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.expand = true,
  }) : style = AppButtonStyle.danger;

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  final AppButtonStyle style;
  final IconData? icon;

  /// Shows a spinner in place of the label and blocks taps.
  final bool isBusy;

  /// Whether the button fills the width it is given.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveOnPressed = isBusy ? null : onPressed;

    final child = isBusy
        ? SizedBox.square(
            dimension: IconSizes.sm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: style == AppButtonStyle.primary
                  ? palette.onPrimary
                  : palette.primary,
            ),
          )
        : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);

    final button = switch (style) {
      AppButtonStyle.primary => FilledButton(
          onPressed: effectiveOnPressed,
          child: _withIcon(child),
        ),
      AppButtonStyle.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          child: _withIcon(child),
        ),
      AppButtonStyle.quiet => TextButton(
          onPressed: effectiveOnPressed,
          child: _withIcon(child),
        ),
      AppButtonStyle.danger => FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: palette.danger,
            foregroundColor: palette.onPrimary,
          ),
          child: _withIcon(child),
        ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _withIcon(Widget child) {
    if (icon == null || isBusy) return child;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: IconSizes.sm),
        Gap.w8,
        Flexible(child: child),
      ],
    );
  }
}

/// A large tappable call to action, used for the home screen's main button.
class AppHeroButton extends StatelessWidget {
  const AppHeroButton({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.primary,
      borderRadius: Radii.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(Insets.lg),
          child: Row(
            children: [
              Icon(icon, color: palette.onPrimary, size: IconSizes.lg),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.text.titleLarge?.copyWith(
                        color: palette.onPrimary,
                      ),
                    ),
                    Gap.h2,
                    Text(
                      description,
                      style: context.text.bodyMedium?.copyWith(
                        color: palette.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact icon-and-label action, used in a row under a document preview.
class AppIconAction extends StatelessWidget {
  const AppIconAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = isDestructive ? palette.danger : palette.textPrimary;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: Radii.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.sm,
            vertical: Insets.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: IconSizes.md, color: color),
              Gap.h4,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
