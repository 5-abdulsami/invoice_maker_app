/// External destinations the About settings link to.
///
/// These are empty until the app has real published URLs; the launcher falls
/// back to a "coming soon" dialog while they are.
sealed class AppLinks {
  /// Address that feedback emails are sent to, e.g. `support@example.com`.
  static const String supportEmail = '';

  /// Public privacy policy page.
  static const String privacyPolicyUrl = '';

  /// Store listing used by "Rate Us".
  static const String storeListingUrl = '';

  /// Page for translation contributions.
  static const String translationUrl = '';
}
