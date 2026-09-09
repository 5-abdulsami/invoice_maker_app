import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';

/// Visual weight of an [AppButton].
enum AppButtonVariant {
  /// Filled blue — the primary action on a screen.
  primary,

  /// Filled light blue — a secondary but still filled action.
  secondary,

  /// White with a grey border — cancel-style actions.
  outline,
}

/// The app's button, replacing the separate save, preview and share buttons.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isBusy = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Shows a spinner and blocks taps while an action runs.
  final bool isBusy;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label, textAlign: TextAlign.center);

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(_height)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    );

    final onTap = isBusy ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.primary => FilledButton.icon(
          onPressed: onTap,
          style: style.merge(
            const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primary),
              foregroundColor: WidgetStatePropertyAll(AppColors.white),
            ),
          ),
          icon: icon == null ? null : Icon(icon),
          label: child,
        ),
      AppButtonVariant.secondary => FilledButton.icon(
          onPressed: onTap,
          style: style.merge(
            const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.buttonLightBlue),
              foregroundColor: WidgetStatePropertyAll(AppColors.primary),
            ),
          ),
          icon: icon == null ? null : Icon(icon),
          label: child,
        ),
      AppButtonVariant.outline => OutlinedButton.icon(
          onPressed: onTap,
          style: style.merge(
            const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.white),
              foregroundColor: WidgetStatePropertyAll(AppColors.darkGrey),
              side: WidgetStatePropertyAll(
                BorderSide(color: AppColors.darkGrey),
              ),
            ),
          ),
          icon: icon == null ? null : Icon(icon),
          label: child,
        ),
    };
  }
}

/// The sticky bar at the bottom of the invoice and estimate forms.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 1,
            offset: Offset(0, -0.75),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Gap.wMd,
              Expanded(flex: i == children.length - 1 ? 2 : 1, child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}
