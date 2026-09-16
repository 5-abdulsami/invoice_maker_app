import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';

/// Shown where a list has nothing in it.
///
/// An outlined glyph rather than an illustration: it scales to any width, has
/// no asset to ship and reads the same in dark mode.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Insets.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Insets.lg),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: IconSizes.illustration,
                color: palette.textTertiary,
              ),
            ),
            Gap.h20,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            Gap.h8,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              Gap.h20,
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when something failed and can be tried again.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: IconSizes.lg,
              color: context.palette.danger,
            ),
            Gap.h12,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
            if (onRetry != null) ...[
              Gap.h12,
              AppButton.quiet(label: AppStrings.retry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dims its child and shows a spinner while a long action runs.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;

  /// Optional caption, e.g. "Preparing PDF".
  final String? message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            // Absorbs taps so the underlying form cannot be changed mid-save.
            child: ColoredBox(
              color: palette.overlay,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(Insets.xl),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: Radii.mdAll,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        Gap.h12,
                        Text(message!, style: context.text.bodyMedium),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A centred spinner sized for an inline slot, such as a preview panel.
class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: IconSizes.lg,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (message != null) ...[
            Gap.h12,
            Text(message!, style: context.text.bodySmall),
          ],
        ],
      ),
    );
  }
}
