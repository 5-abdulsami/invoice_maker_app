import 'package:flutter/foundation.dart';

/// Lets a controller update the UI before storage confirms a change.
///
/// Repositories apply every change in memory synchronously, before their first
/// await, and only then write it to disk. So by the time a write's future
/// exists, the new state is already readable, and listeners can rebuild on the
/// next frame instead of waiting on the file system.
///
/// The returned future still completes when the write lands and still fails
/// if it does, so callers report storage errors exactly as before.
mixin OptimisticNotifier on ChangeNotifier {
  /// Notifies listeners now, then hands back [write] to await.
  Future<T> commit<T>(Future<T> write) {
    notifyListeners();
    return write;
  }
}
