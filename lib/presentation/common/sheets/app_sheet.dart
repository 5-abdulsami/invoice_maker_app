import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';

/// Opens the app's modal sheets.
///
/// Sheets rather than centre dialogs: they sit near the thumb, can grow to
/// hold a list or a form, and lift above the keyboard without clipping.
sealed class AppSheet {
  /// Shows [builder] inside the standard sheet frame.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext context) builder,
    String? subtitle,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      useSafeArea: true,
      builder: (sheetContext) => _SheetFrame(
        title: title,
        subtitle: subtitle,
        child: builder(sheetContext),
      ),
    );
  }

  /// Asks the user to confirm, returning true only when they do.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.delete,
    String cancelLabel = AppStrings.cancel,
    bool isDestructive = true,
  }) async {
    final confirmed = await show<bool>(
      context: context,
      title: title,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          0,
          Insets.gutter,
          Insets.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: sheetContext.text.bodyLarge),
            Gap.h20,
            if (isDestructive)
              AppButton.danger(
                label: confirmLabel,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              )
            else
              AppButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            Gap.h8,
            AppButton.secondary(
              label: cancelLabel,
              onPressed: () => Navigator.of(sheetContext).pop(false),
            ),
          ],
        ),
      ),
    );

    return confirmed ?? false;
  }

  /// Single-choice list. Resolves to the chosen option, or null if dismissed.
  static Future<T?> choose<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T option) labelOf,
    T? selected,
    String? Function(T option)? subtitleOf,
    Widget? Function(T option)? trailingOf,
    String? subtitle,
  }) {
    return show<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      builder: (sheetContext) {
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: Insets.lg),
          itemCount: options.length,
          itemBuilder: (itemContext, index) {
            final option = options[index];
            final isSelected = option == selected;

            return AppTile(
              title: labelOf(option),
              subtitle: subtitleOf?.call(option),
              showChevron: false,
              onTap: () => Navigator.of(sheetContext).pop(option),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingOf?.call(option) != null) ...[
                    trailingOf!.call(option)!,
                    Gap.w8,
                  ],
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: IconSizes.md,
                    color: isSelected
                        ? itemContext.palette.primary
                        : itemContext.palette.textTertiary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// A menu of actions. Resolves to the chosen one, or null if dismissed.
  static Future<T?> actions<T>(
    BuildContext context, {
    required String title,
    required List<SheetAction<T>> actions,
    String? subtitle,
  }) {
    return show<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.only(bottom: Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              AppTile(
                title: action.label,
                subtitle: action.description,
                icon: action.icon,
                isDestructive: action.isDestructive,
                showChevron: false,
                onTap: () => Navigator.of(sheetContext).pop(action.value),
              ),
          ],
        ),
      ),
    );
  }
}

/// One entry in an action sheet.
@immutable
class SheetAction<T> {
  const SheetAction({
    required this.value,
    required this.label,
    required this.icon,
    this.description,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final String? description;
  final bool isDestructive;
}

/// The frame every sheet shares: a title, a close button and a body that
/// grows with its content but never past the screen.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Tallest a sheet may grow, as a fraction of the screen.
  static const double _maxHeightFactor = 0.9;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.screenSize.height * _maxHeightFactor,
      ),
      child: Padding(
        // Lifts the sheet above the keyboard when it holds a field.
        padding: EdgeInsets.only(bottom: context.keyboardInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.gutter,
                Insets.xs,
                Insets.sm,
                Insets.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: context.text.titleLarge),
                        if (subtitle != null) ...[
                          Gap.h4,
                          Text(subtitle!, style: context.text.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                  Gap.w8,
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, size: IconSizes.md),
                    tooltip: AppStrings.close,
                  ),
                ],
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
