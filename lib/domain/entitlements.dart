/// Capabilities that a future paid version will unlock.
enum ProFeature {
  premiumTemplates,
  removeDocumentBranding,
  multipleBusinessProfiles,
  advancedExport,
}

/// What the current user is allowed to do.
///
/// The only seam monetisation needs: swap the implementation for one backed by
/// Google Play Billing and nothing else in the app changes. Deliberately has
/// no UI, no network and no stored receipt.
abstract interface class Entitlements {
  /// Whether the paid version is active.
  bool get isPro;

  /// Whether [feature] may be used right now.
  bool allows(ProFeature feature);

  /// A short note explaining the current state, shown beside Pro markers.
  String get statusNote;
}

/// The shipping implementation: everything is usable, and nothing is sold yet.
///
/// Pro-tier templates are marked in the picker so the tiering is honest, but
/// no feature is withheld, so the app is never crippled to advertise a
/// purchase that does not exist.
class EarlyAccessEntitlements implements Entitlements {
  const EarlyAccessEntitlements();

  @override
  bool get isPro => false;

  @override
  bool allows(ProFeature feature) => true;

  @override
  String get statusNote => 'Included free in this version';
}
