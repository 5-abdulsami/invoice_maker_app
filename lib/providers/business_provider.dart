import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/business.dart';

/// The user's own business details.
class BusinessProvider extends ChangeNotifier {
  Business _business = const Business.empty();

  Business get business => _business;

  bool get isConfigured => _business.businessName.trim().isNotEmpty;

  /// Applies [updater] in one notification.
  void update(Business Function(Business current) updater) {
    final updated = updater(_business);
    if (updated == _business) return;
    _business = updated;
    notifyListeners();
  }

  /// Replaces the whole record, as the business form does on save.
  void save(Business business) => update((_) => business);

  void setLogoPath(String? path) => update(
        (business) => path == null
            ? business.copyWith(clearLogo: true)
            : business.copyWith(logoPath: path),
      );
}
