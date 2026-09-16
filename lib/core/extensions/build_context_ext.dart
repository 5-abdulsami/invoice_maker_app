import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/palette.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/design/typography.dart';

/// Theme and layout lookups, so widgets never reach for raw `MediaQuery`
/// arithmetic or a `Theme.of(context).extension<...>()!` chain.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get text => Theme.of(this).textTheme;

  /// Semantic colour roles for the active theme.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// Amount and document-number text styles.
  AppTextRoles get textRoles =>
      Theme.of(this).extension<AppTextRoles>() ??
      AppTypography.roles(AppPalette.light);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// Screen-size questions, answered by name rather than by pixel comparison.
extension AppLayoutContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Very narrow phones, where side-by-side rows must stack.
  bool get isCompactWidth => screenSize.width < Layout.compactWidth;

  /// Tablets and large foldables.
  bool get isMediumWidth => screenSize.width >= Layout.mediumWidth;

  bool get isExpandedWidth => screenSize.width >= Layout.expandedWidth;

  /// True while the software keyboard covers part of the screen.
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Height of the on-screen keyboard, for padding a scroll view.
  double get keyboardInset => MediaQuery.viewInsetsOf(this).bottom;

  /// Safe-area inset at the bottom, e.g. the gesture bar.
  double get bottomSafeInset => MediaQuery.paddingOf(this).bottom;

  /// Picks the value matching the current width.
  T byWidth<T>({required T compact, T? medium, T? expanded}) {
    if (isExpandedWidth && expanded != null) return expanded;
    if (isMediumWidth && medium != null) return medium;
    return compact;
  }
}

const Duration _messageDuration = Duration(seconds: 3);

/// Failures stay longer, since they carry something to act on.
const Duration _errorDuration = Duration(seconds: 5);

/// Feedback and focus helpers.
extension AppFeedbackContext on BuildContext {
  /// Shows a transient confirmation.
  ///
  /// Replaces the previous message rather than queueing, so rapid actions do
  /// not leave the user waiting through a backlog of snackbars.
  void showMessage(String message) => _showSnackBar(message);

  /// Shows a failure, tinted with the danger role.
  void showErrorMessage(String message) =>
      _showSnackBar(message, isError: true);

  /// Shows a confirmation with a single undo-style action.
  void showMessageWithAction(
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    _showSnackBar(
      message,
      action: SnackBarAction(label: actionLabel, onPressed: onAction),
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? palette.danger : null,
          duration: isError ? _errorDuration : _messageDuration,
          action: action,
        ),
      );
  }

  /// Drops focus, dismissing the keyboard.
  void dismissKeyboard() => FocusScope.of(this).unfocus();
}
