import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:invoicemaker/core/constants/app_info.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';
import 'package:invoicemaker/data/models/backup_bundle.dart';
import 'package:invoicemaker/data/models/business_profile.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// How a restore treats what is already on the device.
enum RestoreMode {
  /// Keep existing records and add anything missing.
  merge,

  /// Delete everything first, then restore the backup exactly.
  replace,
}

/// Exports and restores the single backup file.
///
/// Export goes through the share sheet rather than writing to a folder
/// directly: it needs no storage permission, and "Save to Files" or a cloud
/// app are both one tap away.
class BackupService {
  BackupService(this._repositories);

  final AppRepositories _repositories;

  /// A bundle holding everything currently stored.
  Future<BackupBundle> buildBundle() async {
    final business = _repositories.business;

    return BackupBundle.snapshot(
      settings: _repositories.settings.settings,
      business: business.profile,
      customers: _repositories.customers.all,
      catalogItems: _repositories.catalog.all,
      documents: _repositories.documents.all,
      logoBytes: await business.readLogoBytes(),
      signatureBytes: await business.readSignatureBytes(),
    );
  }

  /// Writes a backup to a temporary file and offers it to the share sheet.
  ///
  /// Returns the bundle that was exported, for the confirmation message.
  Future<BackupBundle> exportAndShare() async {
    final bundle = await buildBundle();

    try {
      final directory = await getTemporaryDirectory();
      final name =
          '${AppInfo.backupFileStem}-${DateTime.now().fileStamp}'
          '.${AppInfo.backupExtension}';
      final file = File('${directory.path}/$name');
      await file.writeAsString(bundle.encode(), flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: AppInfo.backupMimeType)],
        subject: '${AppInfo.backupFileStem} ${DateTime.now().fileStamp}',
      );
      return bundle;
    } on Object catch (error) {
      throw BackupExportException(error);
    }
  }

  /// Asks the user for a backup file and parses it.
  ///
  /// Returns null when the picker was dismissed. The file type is not
  /// filtered, because providers report a backup's type inconsistently and a
  /// filtered picker would hide valid files; the contents are validated
  /// instead, which gives a clearer message when the file is wrong.
  Future<BackupBundle?> pickBundle() async {
    final XFile? file;
    try {
      file = await openFile(
        acceptedTypeGroups: const [XTypeGroup(label: 'Backup file')],
      );
    } on Object catch (error) {
      throw BackupImportException(
        'Could not open the file picker.',
        error,
      );
    }

    if (file == null) return null;

    final String raw;
    try {
      raw = await file.readAsString();
    } on Object catch (error) {
      throw BackupImportException(
        'That file could not be read.',
        error,
      );
    }

    return BackupBundle.decode(raw);
  }

  /// Writes [bundle] into storage.
  ///
  /// The logo and signature are written back as files and every record that
  /// referenced them is repointed, since the paths inside the backup came
  /// from the device it was exported on.
  Future<void> restore(BackupBundle bundle, {required RestoreMode mode}) async {
    final replacing = mode == RestoreMode.replace;
    if (replacing) {
      await _repositories.clearEverything();
    }

    await _restoreProfile(bundle, replacing: replacing);
    final documents = _repointAssets(bundle.documents);

    final customers = _repositories.customers;
    final catalog = _repositories.catalog;
    final documentRepository = _repositories.documents;

    if (replacing) {
      await customers.replaceAll(bundle.customers);
      await catalog.replaceAll(bundle.catalogItems);
      await documentRepository.replaceAll(documents);
      await _repositories.settings.save(bundle.settings);
    } else {
      // Merging keeps this device's own preferences and adds only records it
      // does not already have, matched by id.
      await customers.mergeAll(bundle.customers);
      await catalog.mergeAll(bundle.catalogItems);
      await documentRepository.mergeAll(documents);
    }
  }

  /// Deletes every record and stored image.
  Future<void> clearAll() => _repositories.clearEverything();

  /// Restores the business profile and its images.
  ///
  /// When merging, an existing profile is left alone: the user's current
  /// details should win over an older backup.
  Future<void> _restoreProfile(
    BackupBundle bundle, {
    required bool replacing,
  }) async {
    final business = _repositories.business;
    final keepExisting = !replacing && business.profile.isConfigured;
    if (keepExisting) return;

    final vault = _repositories.vault;
    String? logoPath;
    String? signaturePath;

    if (vault != null) {
      final logo = bundle.logoBytes;
      if (logo != null) {
        logoPath = await vault.storeBytes(logo, prefix: 'logo');
      }
      final signature = bundle.signatureBytes;
      if (signature != null) {
        signaturePath = await vault.storeBytes(signature, prefix: 'signature');
      }
    }

    await business.replace(
      BusinessProfile(
        name: bundle.business.name,
        email: bundle.business.email,
        phone: bundle.business.phone,
        address: bundle.business.address,
        taxNumber: bundle.business.taxNumber,
        website: bundle.business.website,
        logoPath: logoPath,
        signaturePath: signaturePath,
      ),
    );
  }

  /// Points each document's logo and signature at the files that now exist.
  List<SalesDocument> _repointAssets(List<SalesDocument> documents) {
    final profile = _repositories.business.profile;

    return documents.map((document) {
      final wantsLogo = document.issuerLogoPath != null;
      final wantsSignature = document.signaturePath != null;

      return document.copyWith(
        issuerLogoPath: wantsLogo ? profile.logoPath : null,
        clearIssuerLogo: !wantsLogo || profile.logoPath == null,
        signaturePath: wantsSignature ? profile.signaturePath : null,
        clearSignature: !wantsSignature || profile.signaturePath == null,
        updatedAt: document.updatedAt,
      );
    }).toList(growable: false);
  }
}
