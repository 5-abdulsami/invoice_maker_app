import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/estimate_status.dart';
import 'package:invoicemaker/data/models/estimate.dart';
import 'package:invoicemaker/data/models/item.dart';

/// Holds the estimate being edited plus every saved estimate.
class EstimateProvider extends ChangeNotifier {
  EstimateProvider() {
    _draft = _createDraft();
  }

  final List<Estimate> _estimates = [];
  late Estimate _draft;
  int _nextEstimateNumber = 1;

  Estimate get estimate => _draft;

  List<Estimate> get estimates => List.unmodifiable(_estimates);

  bool get hasEstimates => _estimates.isNotEmpty;

  /// Applies [updater] to the draft in one notification.
  void updateDraft(Estimate Function(Estimate current) updater) {
    _draft = updater(_draft);
    notifyListeners();
  }

  void setDraft(Estimate estimate) => updateDraft((_) => estimate);

  /// Starts a fresh draft with the next free estimate number.
  void resetDraft({Currency currency = Currency.pkr, int dueTermDays = 7}) {
    _draft = _createDraft(currency: currency, dueTermDays: dueTermDays);
    notifyListeners();
  }

  Estimate _createDraft({
    Currency currency = Currency.pkr,
    int dueTermDays = 7,
  }) =>
      Estimate.blank(
        estimateNumber: nextEstimateNumber(),
        currency: currency,
        dueTermDays: dueTermDays,
      );

  String nextEstimateNumber() {
    var candidate = _nextEstimateNumber;
    String format(int value) => 'EST${value.toString().padLeft(5, '0')}';
    while (_estimates
        .any((estimate) => estimate.estimateNumber == format(candidate))) {
      candidate++;
    }
    return format(candidate);
  }

  bool isEstimateNumberUnique(String number, {String? exceptId}) =>
      !_estimates.any(
        (estimate) =>
            estimate.id != exceptId && estimate.estimateNumber == number,
      );

  // ---------------------------------------------------------------- draft

  void setCreationDate(DateTime creationDate) => updateDraft((estimate) {
        final dueDate = creationDate.isAfter(estimate.dueDate)
            ? creationDate
            : estimate.dueDate;
        return estimate.copyWith(
          creationDate: creationDate,
          dueDate: dueDate,
          dueTerms: dueDate.difference(creationDate).inDays,
        );
      });

  void setDueDate(DateTime dueDate) => updateDraft(
        (estimate) => estimate.copyWith(
          dueDate: dueDate,
          dueTerms: dueDate.difference(estimate.creationDate).inDays,
        ),
      );

  void setItems(List<Item> items) => updateDraft(
        (estimate) => _recalculated(estimate.copyWith(items: items)),
      );

  void addItem(Item item) => setItems([..._draft.items, item]);

  void removeItem(Item item) =>
      setItems(_draft.items.where((current) => current.id != item.id).toList());

  void updateItem(String itemId, Item updated) {
    final index = _draft.items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;
    setItems(List<Item>.of(_draft.items)..[index] = updated);
  }

  /// Moves the item at [oldIndex] to [newIndex], using the post-removal
  /// index reported by `ReorderableListView.onReorderItem`.
  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _draft.items.length) return;
    final items = List<Item>.of(_draft.items);
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex.clamp(0, items.length), moved);
    setItems(items);
  }

  void recalculateTotals() => updateDraft(_recalculated);

  Estimate _recalculated(Estimate estimate) {
    final subTotal = estimate.items.fold<double>(
      0,
      (sum, item) => sum + item.subAmount,
    );
    final withSubTotal = estimate.copyWith(subTotal: subTotal);
    return withSubTotal.copyWith(total: withSubTotal.computedTotal);
  }

  // ----------------------------------------------------------------- list

  /// Saves [estimate], adding it or replacing the entry with its id.
  void saveEstimate(Estimate estimate) {
    final index = _estimates.indexWhere((current) => current.id == estimate.id);
    if (index == -1) {
      _estimates.add(estimate);
      _nextEstimateNumber++;
    } else {
      _estimates[index] = estimate;
    }
    notifyListeners();
  }

  void updateEstimate(Estimate estimate) {
    final index = _estimates.indexWhere((current) => current.id == estimate.id);
    if (index == -1) return;
    _estimates[index] = estimate;
    notifyListeners();
  }

  void removeEstimate(Estimate estimate) {
    if (_estimates.remove(estimate)) notifyListeners();
  }

  void clearEstimates() {
    if (_estimates.isEmpty) return;
    _estimates.clear();
    notifyListeners();
  }

  Estimate? getEstimateById(String id) {
    final index = _estimates.indexWhere((estimate) => estimate.id == id);
    return index == -1 ? null : _estimates[index];
  }

  void setStatus(String id, EstimateStatus status) {
    final estimate = getEstimateById(id);
    if (estimate == null) return;
    updateEstimate(estimate.copyWith(status: status));
  }

  /// Saved estimates matching [status] and [query], newest first.
  ///
  /// A null [status] means "all"; pass [overdueOnly] for the overdue filter,
  /// which is derived from the due date rather than the stored status.
  List<Estimate> filtered({
    EstimateStatus? status,
    String query = '',
    bool overdueOnly = false,
  }) {
    final trimmed = query.trim().toLowerCase();

    return _estimates.reversed.where((estimate) {
      if (overdueOnly && !estimate.isOverdue) return false;
      if (status != null && estimate.status != status) return false;
      if (trimmed.isEmpty) return true;

      return estimate.estimateNumber.toLowerCase().contains(trimmed) ||
          estimate.to.toLowerCase().contains(trimmed) ||
          estimate.total.toStringAsFixed(0).contains(trimmed);
    }).toList(growable: false);
  }
}
