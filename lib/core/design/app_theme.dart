import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/palette.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/design/typography.dart';

/// Builds the app's light and dark themes from the design tokens.
///
/// Every colour, radius and spacing value a widget needs is reachable from the
/// theme, so widgets never declare their own.
sealed class AppTheme {
  // Built once: a theme is costly to construct, and a fresh instance on every
  // app rebuild would also re-theme every screen for no visible change.
  static final ThemeData light = _build(AppPalette.light);

  static final ThemeData dark = _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final textTheme = AppTypography.textTheme(palette);
    final roles = AppTypography.roles(palette);
    final colorScheme = _colorScheme(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      textTheme: textTheme,
      fontFamily: AppFonts.sans,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [palette, roles],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: Insets.gutter,
        shape: Border(
          bottom: BorderSide(color: palette.border),
        ),
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(
          color: palette.textPrimary,
          size: IconSizes.md,
        ),
        actionsIconTheme: IconThemeData(
          color: palette.textPrimary,
          size: IconSizes.md,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.mdAll,
          side: BorderSide(color: palette.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: Strokes.hairline,
        space: Strokes.hairline,
      ),
      iconTheme: IconThemeData(color: palette.textSecondary, size: IconSizes.md),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        minVerticalPadding: Insets.md,
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg),
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textTertiary),
        labelStyle: textTheme.bodyMedium,
        helperStyle: textTheme.bodySmall,
        helperMaxLines: 3,
        errorStyle: textTheme.bodySmall?.copyWith(color: palette.danger),
        errorMaxLines: 3,
        prefixStyle: textTheme.bodyLarge,
        suffixStyle: textTheme.bodyMedium,
        border: _border(palette.border),
        enabledBorder: _border(palette.border),
        // A visible focus ring: the previous theme used a transparent border
        // for both states, leaving focus invisible.
        focusedBorder: _border(palette.primary, width: Strokes.thick),
        errorBorder: _border(palette.danger),
        focusedErrorBorder: _border(palette.danger, width: Strokes.thick),
        disabledBorder: _border(palette.border),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(textTheme).copyWith(
          backgroundColor: _states(
            enabled: palette.primary,
            disabled: palette.surfaceMuted,
          ),
          foregroundColor: _states(
            enabled: palette.onPrimary,
            disabled: palette.textTertiary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(textTheme).copyWith(
          foregroundColor: _states(
            enabled: palette.textPrimary,
            disabled: palette.textTertiary,
          ),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.disabled)
                ? palette.border
                : palette.borderStrong;
            return BorderSide(color: color);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(textTheme).copyWith(
          foregroundColor: _states(
            enabled: palette.primary,
            disabled: palette.textTertiary,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: _states(
            enabled: palette.textPrimary,
            disabled: palette.textTertiary,
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size.square(Layout.minTapTarget),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 1,
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          color: palette.onPrimary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.lgAll),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.primarySurface,
        disabledColor: palette.surfaceMuted,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: palette.primary,
        ),
        side: BorderSide(color: palette.border),
        shape: const RoundedRectangleBorder(borderRadius: Radii.pillAll),
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.sm,
          vertical: Insets.sm,
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primarySurface,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: Radii.pillAll,
        ),
        height: 64,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? palette.primary : palette.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: IconSizes.md,
            color: selected ? palette.primary : palette.textSecondary,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: palette.surface,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: palette.borderStrong,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(Insets.xl),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.onInverse,
        ),
        actionTextColor: palette.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(Insets.md),
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        textStyle: textTheme.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.smAll,
          side: BorderSide(color: palette.border),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.inverseSurface,
          borderRadius: Radii.smAll,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: palette.onInverse),
        waitDuration: Motion.slow,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return palette.border;
          return states.contains(WidgetState.selected)
              ? palette.onPrimary
              : palette.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return palette.surfaceMuted;
          }
          return states.contains(WidgetState.selected)
              ? palette.primary
              : palette.borderStrong;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? palette.primary
              : palette.borderStrong;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? palette.primary
              : Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(palette.onPrimary),
        side: BorderSide(color: palette.borderStrong, width: Strokes.thick),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.xs)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.surfaceMuted,
        circularTrackColor: palette.surfaceMuted,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: palette.primarySurface,
        headerForegroundColor: palette.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
          side: WidgetStatePropertyAll(
            BorderSide(color: palette.border),
          ),
        ),
      ),
    );
  }

  static ColorScheme _colorScheme(AppPalette palette) {
    return ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: palette.brightness,
    ).copyWith(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primarySurface,
      onPrimaryContainer: palette.primary,
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.primarySurface,
      onSecondaryContainer: palette.primary,
      error: palette.danger,
      onError: palette.onPrimary,
      errorContainer: palette.dangerSurface,
      onErrorContainer: palette.danger,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerLowest: palette.canvas,
      surfaceContainerLow: palette.canvas,
      surfaceContainer: palette.surface,
      surfaceContainerHigh: palette.surfaceMuted,
      surfaceContainerHighest: palette.surfaceMuted,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.borderStrong,
      outlineVariant: palette.border,
      shadow: palette.shadow,
      scrim: palette.overlay,
      inverseSurface: palette.inverseSurface,
      onInverseSurface: palette.onInverse,
    );
  }

  static OutlineInputBorder _border(
    Color color, {
    double width = Strokes.hairline,
  }) {
    return OutlineInputBorder(
      borderRadius: Radii.smAll,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle _buttonStyle(TextTheme textTheme) {
    return ButtonStyle(
      // Finite width: an infinite minimum width crashes any button laid out
      // in a Row, app bar, or dialog. Full-width buttons use AppButton.expand.
      minimumSize: const WidgetStatePropertyAll(
        Size(Layout.minTapTarget, Layout.minTapTarget),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Insets.lg),
      ),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Radii.smAll),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static WidgetStateProperty<Color> _states({
    required Color enabled,
    required Color disabled,
  }) {
    return WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? disabled : enabled,
    );
  }
}
