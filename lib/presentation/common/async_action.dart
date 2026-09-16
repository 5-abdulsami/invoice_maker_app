import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// Runs async work with a busy flag and a message on failure.
///
/// Gives every screen the same loading and error behaviour without repeating
/// the try/catch and `setState` bookkeeping, and refuses to start a second
/// action while one is running so a double tap cannot save twice.
mixin AsyncAction<T extends StatefulWidget> on State<T> {
  bool _isBusy = false;

  /// True while [run] is in flight; drive a [LoadingOverlay] with it.
  bool get isBusy => _isBusy;

  /// Awaits [action], reporting any [AppException] to the user.
  ///
  /// Returns null when the action failed, was ignored because another was
  /// already running, or the widget left the tree.
  Future<R?> run<R>(
    Future<R> Function() action, {
    String? successMessage,
  }) async {
    if (_isBusy) return null;
    setState(() => _isBusy = true);

    try {
      final result = await action();
      if (mounted && successMessage != null) {
        context.showMessage(successMessage);
      }
      return result;
    } on AppException catch (error) {
      _report(error.message);
      return null;
    } on Object {
      _report(AppCopy.genericFailure);
      return null;
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _report(String message) {
    if (!mounted) return;
    context.showErrorMessage(message);
  }
}
