import 'package:flutter/material.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/presentation/business/business_profile_screen.dart';
import 'package:invoicemaker/presentation/catalog/catalog_editor_screen.dart';
import 'package:invoicemaker/presentation/catalog/catalog_list_screen.dart';
import 'package:invoicemaker/presentation/customers/customer_editor_screen.dart';
import 'package:invoicemaker/presentation/customers/customer_list_screen.dart';
import 'package:invoicemaker/presentation/documents/document_detail_screen.dart';
import 'package:invoicemaker/presentation/documents/document_preview_screen.dart';
import 'package:invoicemaker/presentation/documents/template_picker_screen.dart';
import 'package:invoicemaker/presentation/editor/document_editor_screen.dart';
import 'package:invoicemaker/presentation/settings/about_screen.dart';
import 'package:invoicemaker/presentation/settings/backup_screen.dart';
import 'package:invoicemaker/presentation/settings/document_defaults_screen.dart';
import 'package:invoicemaker/presentation/settings/numbering_screen.dart';
import 'package:invoicemaker/presentation/settings/settings_screen.dart';
import 'package:invoicemaker/presentation/signature/signature_capture_screen.dart';

/// Every navigation the app performs.
///
/// Screens are pushed through typed methods rather than named routes with
/// `Object?` arguments: the argument types are then checked at compile time,
/// and a screen's constructor stays the single description of what it needs.
sealed class AppNavigator {
  /// Opens the editor. Resolves to the saved document, or null if abandoned.
  static Future<SalesDocument?> openEditor(
    BuildContext context, {
    required DocumentKind kind,
    String? documentId,
  }) {
    return _push<SalesDocument>(
      context,
      DocumentEditorScreen(kind: kind, documentId: documentId),
    );
  }

  /// Opens a saved document.
  ///
  /// Pass [replace] after creating one, so the back button returns to the
  /// list rather than to the form the user has finished with.
  static Future<void> openDocumentDetail(
    BuildContext context,
    SalesDocument document, {
    bool replace = false,
  }) {
    final route = MaterialPageRoute<void>(
      builder: (_) => DocumentDetailScreen(document: document),
    );

    final navigator = Navigator.of(context);
    return replace
        ? navigator.pushReplacement(route)
        : navigator.push(route);
  }

  /// Shows the document full screen, without saving it first.
  static Future<void> openDocumentPreview(
    BuildContext context,
    SalesDocument document,
  ) {
    return _push<void>(context, DocumentPreviewScreen(document: document));
  }

  /// Resolves to the chosen template, or null if dismissed.
  static Future<InvoiceTemplate?> openTemplatePicker(
    BuildContext context, {
    required SalesDocument document,
  }) {
    return _push<InvoiceTemplate>(
      context,
      TemplatePickerScreen(document: document),
    );
  }

  static Future<void> openCustomerList(BuildContext context) =>
      _push<void>(context, const CustomerListScreen());

  /// Resolves to the saved customer, or null if abandoned.
  static Future<Customer?> openCustomerEditor(
    BuildContext context, {
    Customer? customer,
  }) {
    return _push<Customer>(
      context,
      CustomerEditorScreen(customer: customer),
    );
  }

  static Future<void> openCatalogList(BuildContext context) =>
      _push<void>(context, const CatalogListScreen());

  /// Resolves to the saved item, or null if abandoned.
  static Future<CatalogItem?> openCatalogEditor(
    BuildContext context, {
    CatalogItem? item,
  }) {
    return _push<CatalogItem>(context, CatalogEditorScreen(item: item));
  }

  static Future<void> openBusinessProfile(BuildContext context) =>
      _push<void>(context, const BusinessProfileScreen());

  static Future<void> openSignatureCapture(BuildContext context) =>
      _push<void>(context, const SignatureCaptureScreen());

  static Future<void> openSettings(BuildContext context) =>
      _push<void>(context, const SettingsScreen());

  static Future<void> openDocumentDefaults(BuildContext context) =>
      _push<void>(context, const DocumentDefaultsScreen());

  static Future<void> openNumbering(BuildContext context) =>
      _push<void>(context, const NumberingScreen());

  static Future<void> openBackup(BuildContext context) =>
      _push<void>(context, const BackupScreen());

  static Future<void> openAbout(BuildContext context) =>
      _push<void>(context, const AboutScreen());

  static Future<T?> _push<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(builder: (_) => screen),
    );
  }
}
