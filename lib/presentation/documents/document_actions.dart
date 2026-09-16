import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/editor/sheets/editor_sheets.dart';
import 'package:invoicemaker/services/pdf/document_pdf_service.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// What can be done with a saved document.
enum DocumentAction {
  share,
  print,
  edit,
  changeStatus,
  duplicate,
  convertToInvoice,
  delete,
}

/// The menu of things to do with a document.
///
/// One definition used by both the list and the detail screen, so an action
/// cannot exist in one place and not the other.
sealed class DocumentActionsSheet {
  static Future<DocumentAction?> show(
    BuildContext context, {
    required SalesDocument document,
    bool includeEdit = true,
  }) {
    return AppSheet.actions<DocumentAction>(
      context,
      title: document.number,
      subtitle: document.recipientName,
      actions: [
        const SheetAction(
          value: DocumentAction.share,
          label: AppStrings.share,
          icon: Icons.ios_share,
          description: 'Send the PDF, or save it to your device',
        ),
        const SheetAction(
          value: DocumentAction.print,
          label: AppStrings.print,
          icon: Icons.print_outlined,
        ),
        if (includeEdit)
          const SheetAction(
            value: DocumentAction.edit,
            label: AppStrings.edit,
            icon: Icons.edit_outlined,
          ),
        if (document.isInvoice)
          const SheetAction(
            value: DocumentAction.changeStatus,
            label: AppStrings.markAs,
            icon: Icons.flag_outlined,
          ),
        const SheetAction(
          value: DocumentAction.duplicate,
          label: AppStrings.duplicate,
          icon: Icons.copy_outlined,
          description: 'Create a new copy with a new number',
        ),
        if (!document.isInvoice)
          const SheetAction(
            value: DocumentAction.convertToInvoice,
            label: AppStrings.convertToInvoice,
            icon: Icons.receipt_long_outlined,
          ),
        const SheetAction(
          value: DocumentAction.delete,
          label: AppStrings.delete,
          icon: Icons.delete_outline,
          isDestructive: true,
        ),
      ],
    );
  }
}

/// Carries out the document actions that do not need to navigate.
///
/// Sharing, printing, status changes, duplication, conversion and deletion
/// all behave identically wherever they are triggered from.
sealed class DocumentActionRunner {
  /// Renders [document] and hands it to the share sheet or the printer.
  static Future<void> output(
    BuildContext context, {
    required SalesDocument document,
    required PdfAction action,
  }) async {
    final settings = context.read<SettingsController>();
    final service = context.read<DocumentPdfService>();

    await service.execute(
      document: document,
      action: action,
      grouping: settings.settings.numberGrouping,
      dateFormat: settings.dateFormat,
    );
  }

  /// Asks for a new status, and for the amount when it is a part payment.
  ///
  /// Returns true when something changed.
  static Future<bool> changeStatus(
    BuildContext context, {
    required SalesDocument document,
  }) async {
    final documents = context.read<DocumentController>();
    final money = context
        .read<SettingsController>()
        .moneyFormatFor(document.currency);

    final status = await AppSheet.choose<DocumentStatus>(
      context,
      title: AppStrings.markAs,
      options: DocumentStatus.forKind(document.kind),
      selected: document.status,
      labelOf: (option) => option.label,
    );
    if (status == null || !context.mounted) return false;

    if (!status.tracksPartialPayment) {
      await documents.setStatus(document.id, status);
      return true;
    }

    final total = document.totals.total;
    final paid = await AmountSheet.show(
      context,
      title: AppStrings.amountPaid,
      fieldLabel: 'Amount received',
      currency: document.currency,
      current: document.amountPaid,
      max: total,
      helper: 'Cannot be more than ${money.format(total)}',
    );
    if (paid == null) return false;

    await documents.setStatus(document.id, status, amountPaid: paid);
    return true;
  }

  /// Confirms, then deletes. Returns true when the document was removed.
  static Future<bool> delete(
    BuildContext context, {
    required SalesDocument document,
  }) async {
    final documents = context.read<DocumentController>();

    final confirmed = await AppSheet.confirm(
      context,
      title: AppCopy.deleteDocumentTitle,
      message: AppCopy.deleteDocumentBody,
    );
    if (!confirmed) return false;

    await documents.delete(document.id);
    return true;
  }
}
