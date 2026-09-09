import 'package:flutter/material.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';

/// Runs async work with a busy flag and a snackbar on failure.
///
/// Gives every screen the same loading and error behaviour without repeating
/// the try/catch and `setState` bookkeeping.
mixin AsyncActionMixin<T extends StatefulWidget> on State<T> {
  bool _isBusy = false;

  /// True while [runGuarded] is in flight; drive a [LoadingOverlay] with it.
  bool get isBusy => _isBusy;

  /// Awaits [action], reporting any [AppException] to the user.
  ///
  /// Returns null when the action fails or another one is already running.
  Future<R?> runGuarded<R>(Future<R> Function() action) async {
    if (_isBusy) return null;
    setState(() => _isBusy = true);
    try {
      return await action();
    } on AppException catch (error) {
      _report(error.message);
      return null;
    } on Object {
      _report('Something went wrong. Please try again.');
      return null;
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _report(String message) {
    if (!mounted) return;
    context.showSnackBar(message, isError: true);
  }
}
