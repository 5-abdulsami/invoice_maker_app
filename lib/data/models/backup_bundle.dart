import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/constants/app_info.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/data/models/app_settings.dart';
import 'package:invoicemaker/data/models/business_profile.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/json_read.dart';
import 'package:invoicemaker/data/models/sales_document.dart';

/// Everything the app stores, in one portable file.
///
/// The logo and signature travel as base64 rather than as paths, because a
/// path from the old device means nothing on the new one. Restoring writes
/// the bytes back into local storage and repoints the records at them.
@immutable
class BackupBundle {
  const BackupBundle({
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.settings,
    required this.business,
    required this.customers,
    required this.catalogItems,
    required this.documents,
    this.logoBytes,
    this.signatureBytes,
  });

  /// Bumped whenever the file layout changes in a way readers must know about.
  static const int currentVersion = 1;

  /// Marker proving the file came from this app.
  static const String _marker = 'invoicemaker';

  final int version;
  final DateTime exportedAt;
  final String appVersion;

  final AppSettings settings;
  final BusinessProfile business;
  final List<Customer> customers;
  final List<CatalogItem> catalogItems;
  final List<SalesDocument> documents;

  final Uint8List? logoBytes;
  final Uint8List? signatureBytes;

  int get invoiceCount =>
      documents.where((document) => document.isInvoice).length;

  int get estimateCount =>
      documents.where((document) => !document.isInvoice).length;

  /// Total records, for the confirmation the user sees before restoring.
  int get recordCount =>
      documents.length + customers.length + catalogItems.length;

  /// Pretty-printed so the file is human-readable if anyone opens it.
  String encode() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'app': _marker,
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'appVersion': appVersion,
      'settings': settings.toJson(),
      'business': business.toJson(),
      'assets': {
        'logo': logoBytes == null ? null : base64Encode(logoBytes!),
        'signature':
            signatureBytes == null ? null : base64Encode(signatureBytes!),
      },
      'customers':
          customers.map((customer) => customer.toJson()).toList(growable: false),
      'catalogItems':
          catalogItems.map((item) => item.toJson()).toList(growable: false),
      'documents': documents
          .map((document) => document.toJson())
          .toList(growable: false),
    });
  }

  /// Builds a bundle from the current data.
  factory BackupBundle.snapshot({
    required AppSettings settings,
    required BusinessProfile business,
    required List<Customer> customers,
    required List<CatalogItem> catalogItems,
    required List<SalesDocument> documents,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    DateTime? now,
  }) {
    return BackupBundle(
      version: currentVersion,
      exportedAt: now ?? DateTime.now(),
      appVersion: AppInfo.versionName,
      settings: settings,
      business: business,
      customers: customers,
      catalogItems: catalogItems,
      documents: documents,
      logoBytes: logoBytes,
      signatureBytes: signatureBytes,
    );
  }

  /// Parses [raw], rejecting anything that is not one of our backups.
  ///
  /// Throws a [BackupImportException] with a message worth showing, rather
  /// than letting a decode error reach the user.
  factory BackupBundle.decode(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on Object catch (error) {
      throw BackupImportException(
        'That file could not be read as a backup.',
        error,
      );
    }

    if (decoded is! Map<Object?, Object?>) {
      throw const BackupImportException();
    }

    final json = Json.coerce(decoded);
    if (Json.string(json, 'app') != _marker) {
      throw const BackupImportException();
    }

    final version = Json.integer(json, 'version', or: 1);
    if (version > currentVersion) {
      throw const BackupImportException(
        'This backup was made by a newer version of the app. Update the app '
        'and try again.',
      );
    }

    final assets = Json.object(json, 'assets') ?? const {};

    return BackupBundle(
      version: version,
      exportedAt: Json.date(json, 'exportedAt'),
      appVersion: Json.string(json, 'appVersion'),
      settings: AppSettings.fromJson(Json.object(json, 'settings') ?? const {}),
      business: BusinessProfile.fromJson(
        Json.object(json, 'business') ?? const {},
      ),
      customers: Json.objects(json, 'customers')
          .map(Customer.fromJson)
          .toList(growable: false),
      catalogItems: Json.objects(json, 'catalogItems')
          .map(CatalogItem.fromJson)
          .toList(growable: false),
      documents: Json.objects(json, 'documents')
          .map(SalesDocument.fromJson)
          .toList(growable: false),
      logoBytes: _decodeAsset(assets, 'logo'),
      signatureBytes: _decodeAsset(assets, 'signature'),
    );
  }

  /// Decodes one base64 asset, treating a damaged one as absent.
  static Uint8List? _decodeAsset(JsonMap assets, String key) {
    final encoded = Json.stringOrNull(assets, key);
    if (encoded == null) return null;
    try {
      return base64Decode(encoded);
    } on Object {
      return null;
    }
  }
}
