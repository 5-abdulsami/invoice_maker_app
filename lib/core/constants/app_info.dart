/// Build identity and the external destinations the About screen links to.
///
/// Empty links are treated as "not published yet" by the launcher, which tells
/// the user rather than failing silently.
sealed class AppInfo {
  /// Keep in step with `version:` in pubspec.yaml.
  static const String versionName = '1.0.0';

  /// Address feedback mail is sent to.
  static const String supportEmail = '';

  /// Hosted privacy policy. The app also shows an offline summary.
  static const String privacyPolicyUrl = '';

  /// Play Store listing, used by "Rate this app".
  static const String storeListingUrl = '';

  /// File name stem for exported backups.
  static const String backupFileStem = 'invoice-maker-backup';

  /// Extension and MIME type of an exported backup.
  static const String backupExtension = 'json';
  static const String backupMimeType = 'application/json';

  static const String pdfMimeType = 'application/pdf';
}
