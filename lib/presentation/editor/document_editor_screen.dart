import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/catalog_item.dart';
import 'package:invoicemaker/data/models/line_item.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/catalog/catalog_picker_sheet.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/presentation/customers/customer_picker_sheet.dart';
import 'package:invoicemaker/presentation/editor/sheets/editor_sheets.dart';
import 'package:invoicemaker/presentation/editor/sheets/line_item_sheet.dart';
import 'package:invoicemaker/presentation/editor/widgets/editor_details_card.dart';
import 'package:invoicemaker/presentation/editor/widgets/editor_header_card.dart';
import 'package:invoicemaker/presentation/editor/widgets/editor_items_card.dart';
import 'package:invoicemaker/presentation/editor/widgets/editor_recipient_card.dart';
import 'package:invoicemaker/presentation/editor/widgets/editor_totals_card.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:invoicemaker/state/catalog_controller.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/document_editor.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// Creates or edits an invoice or estimate.
///
/// Holds its own [DocumentEditor], so the draft cannot leak into another
/// document, and writes to storage only when the user saves.
class DocumentEditorScreen extends StatefulWidget {
  const DocumentEditorScreen({
    super.key,
    required this.kind,
    this.documentId,
  });

  final DocumentKind kind;

  /// Null to create a new document.
  final String? documentId;

  bool get isEditing => documentId != null;

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen>
    with AsyncAction {
  late final DocumentEditor _editor;
  late final TextEditingController _numberController;
  late final TextEditingController _referenceController;

  @override
  void initState() {
    super.initState();

    final documents = context.read<DocumentController>();
    final existing = documents.byId(widget.documentId);

    _editor = DocumentEditor(
      document: existing ?? documents.newDraft(widget.kind),
      isNew: existing == null,
    );

    _numberController = TextEditingController(text: _editor.document.number);
    _referenceController =
        TextEditingController(text: _editor.document.reference);
  }

  @override
  void dispose() {
    _editor.dispose();
    _numberController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- recipient

  Future<void> _chooseRecipient() async {
    final pick = await CustomerPickerSheet.show(context);
    if (pick == null || !mounted) return;

    switch (pick) {
      case CustomerPickSaved(:final customer):
        _editor.setRecipientFromCustomer(customer);
      case CustomerPickOneOff(:final name):
        _editor.setRecipientName(name);
      case CustomerPickCreate():
        final created = await AppNavigator.openCustomerEditor(context);
        if (created != null) _editor.setRecipientFromCustomer(created);
    }
  }

  Future<void> _openBusinessProfile() async {
    await AppNavigator.openBusinessProfile(context);
    if (!mounted) return;

    // Pick up details entered just now, so the new document is not left
    // with the empty issuer it was created with.
    final business = context.read<BusinessController>();
    _editor.setIssuer(
      business.profile.toSnapshot(),
      logoPath: business.profile.logoPath,
    );
  }

  // ------------------------------------------------------------------ lines

  Future<void> _addLine() async {
    final money = _money;
    final pick = await CatalogPickerSheet.show(context, money: money);
    if (pick == null || !mounted) return;

    final CatalogItem? saved = switch (pick) {
      CatalogPickSaved(:final item) => item,
      CatalogPickOneOff() => null,
    };

    final result = await LineItemSheet.show(
      context,
      currency: _editor.currency,
      money: money,
      documentTaxPercent: _editor.document.taxPercent,
      line: saved?.toLineItem(),
      offerSaveToCatalog: saved == null,
    );
    if (result == null || !mounted) return;

    _editor.addLine(result.line);
    if (result.saveToCatalog) await _saveLineToCatalog(result.line);
  }

  Future<void> _editLine(LineItem line) async {
    final result = await LineItemSheet.show(
      context,
      currency: _editor.currency,
      money: _money,
      documentTaxPercent: _editor.document.taxPercent,
      line: line,
    );
    if (result == null || !mounted) return;

    if (result.delete) {
      _editor.removeLine(line.id);
      return;
    }
    _editor.updateLine(result.line);
  }

  /// Keeps a one-off row as a reusable saved item.
  Future<void> _saveLineToCatalog(LineItem line) async {
    await context.read<CatalogController>().save(
          CatalogItem.create(
            name: line.name,
            description: line.description,
            unit: line.unit,
            unitPrice: line.unitPrice,
            defaultDiscountPercent: line.discountPercent,
            defaultTaxPercent: line.taxPercent,
          ),
        );
  }

  // ------------------------------------------------------------------ money

  Future<void> _editDiscount() async {
    final discount = await DiscountSheet.show(
      context,
      current: _editor.document.discount,
      money: _money,
    );
    if (discount == null) return;
    _editor.setDiscount(discount);
  }

  Future<void> _editTax() async {
    final tax = await TaxSheet.show(
      context,
      currentLabel: _editor.document.taxLabel,
      currentPercent: _editor.document.taxPercent,
    );
    if (tax == null) return;
    _editor.setTax(label: tax.label, percent: tax.percent);
  }

  Future<void> _editShipping() async {
    final amount = await AmountSheet.show(
      context,
      title: AppStrings.shipping,
      fieldLabel: 'Shipping amount',
      currency: _editor.currency,
      current: _editor.document.shipping,
    );
    if (amount == null) return;
    _editor.setShipping(amount);
  }

  Future<void> _pickCurrency() async {
    final currency = await AppSheet.choose<Currency>(
      context,
      title: AppStrings.currency,
      options: Currency.values,
      selected: _editor.currency,
      labelOf: (option) => option.pickerLabel,
      subtitleOf: (option) => option.symbol,
    );
    if (currency == null) return;
    _editor.setCurrency(currency);
  }

  Future<void> _pickTemplate() async {
    final template = await AppNavigator.openTemplatePicker(
      context,
      document: _editor.document,
    );
    if (template == null) return;
    _editor.setTemplate(template);
  }

  Future<void> _editStatus() async {
    final status = await AppSheet.choose<DocumentStatus>(
      context,
      title: AppStrings.markAs,
      options: DocumentStatus.forKind(_editor.kind),
      selected: _editor.document.status,
      labelOf: (option) => option.label,
    );
    if (status == null || !mounted) return;

    if (!status.tracksPartialPayment) {
      _editor.setStatus(status);
      return;
    }

    final total = _editor.totals.total;
    final paid = await AmountSheet.show(
      context,
      title: AppStrings.amountPaid,
      fieldLabel: 'Amount received',
      currency: _editor.currency,
      current: _editor.document.amountPaid,
      max: total,
      helper: 'Cannot be more than ${_money.format(total)}',
    );
    if (paid == null) return;

    _editor.setStatus(status, amountPaid: paid);
  }

  // ------------------------------------------------------------------- text

  Future<void> _editTextBlock({
    required String title,
    required String fieldLabel,
    required String current,
    required ValueChanged<String> onSaved,
    String? hint,
  }) async {
    final value = await TextBlockSheet.show(
      context,
      title: title,
      fieldLabel: fieldLabel,
      current: current,
      hint: hint,
    );
    if (value == null) return;
    onSaved(value);
  }

  // ------------------------------------------------------------------ dates

  Future<void> _pickIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editor.document.issueDate,
      firstDate: _earliestDate,
      lastDate: _latestDate,
      helpText: _editor.kind.issueDateLabel,
    );
    if (picked == null) return;
    _editor.setIssueDate(picked);
  }

  Future<void> _pickEndDate() async {
    final document = _editor.document;
    final picked = await showDatePicker(
      context: context,
      initialDate: document.endDate.isBefore(document.issueDate)
          ? document.issueDate
          : document.endDate,
      // Never before the issue date, so a term can never be negative.
      firstDate: document.issueDate,
      lastDate: _latestDate,
      helpText: _editor.kind.endDateLabel,
    );
    if (picked == null) return;
    _editor.setEndDate(picked);
  }

  // ------------------------------------------------------------------- save

  Future<void> _save() async {
    final documents = context.read<DocumentController>();

    final error = _editor.validate(
      isNumberAvailable: documents.isNumberAvailable(
        _editor.document.number,
        kind: _editor.kind,
        exceptId: _editor.document.id,
      ),
    );
    if (error != null) {
      context.showErrorMessage(error);
      return;
    }

    final document = _editor.buildForSave();
    var didSave = false;

    await run(
      () async {
        await documents.save(document);
        didSave = true;
      },
      successMessage: AppCopy.documentSavedMessage,
    );
    if (!didSave || !mounted) return;

    if (_editor.isNew) {
      // A new document opens straight onto its preview, which is where the
      // user shares or prints it.
      await AppNavigator.openDocumentDetail(context, document, replace: true);
      return;
    }
    Navigator.of(context).pop(document);
  }

  Future<void> _preview() async {
    await AppNavigator.openDocumentPreview(context, _editor.document);
  }

  /// Warns before discarding an edited document.
  Future<bool> _confirmDiscard() async {
    if (!_editor.isDirty) return true;

    return AppSheet.confirm(
      context,
      title: AppCopy.discardChangesTitle,
      message: AppCopy.discardChangesBody,
      confirmLabel: AppCopy.discardAction,
      cancelLabel: AppCopy.keepEditingAction,
    );
  }

  /// Formatter for the currency this document is billed in.
  MoneyFormat get _money =>
      context.read<SettingsController>().moneyFormatFor(_editor.currency);

  static final DateTime _earliestDate = DateTime(2000);
  static final DateTime _latestDate = DateTime(2100, 12, 31);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final business = context.watch<BusinessController>();
    final money = settings.moneyFormatFor(_editor.currency);

    return PopScope(
      canPop: !_editor.isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // Resolved before the sheet opens, so no context is used after it.
        final navigator = Navigator.of(context);
        final shouldDiscard = await _confirmDiscard();
        if (!shouldDiscard || !mounted) return;
        navigator.pop();
      },
      child: ListenableBuilder(
        listenable: _editor,
        builder: (context, _) {
          return AppScaffold(
            title: widget.isEditing
                ? 'Edit ${_editor.kind.label.toLowerCase()}'
                : 'New ${_editor.kind.label.toLowerCase()}',
            actions: [
              IconButton(
                onPressed: isBusy ? null : _preview,
                icon: const Icon(Icons.visibility_outlined),
                tooltip: AppStrings.preview,
              ),
            ],
            bottomBar: BottomActionBar(
              children: [
                AppButton.secondary(
                  label: AppStrings.preview,
                  onPressed: isBusy ? null : _preview,
                ),
                AppButton(
                  label: widget.isEditing
                      ? AppStrings.saveChanges
                      : AppStrings.save,
                  icon: Icons.check,
                  isBusy: isBusy,
                  onPressed: _save,
                ),
              ],
            ),
            body: LoadingOverlay(
              isLoading: isBusy,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Insets.gutter,
                  Insets.lg,
                  Insets.gutter,
                  Insets.xl,
                ),
                children: [
                  CardColumn(
                    children: [
                      EditorHeaderCard(
                        editor: _editor,
                        dateFormat: settings.dateFormat,
                        numberController: _numberController,
                        referenceController: _referenceController,
                        onPickIssueDate: _pickIssueDate,
                        onPickEndDate: _pickEndDate,
                      ),
                      EditorRecipientCard(
                        editor: _editor,
                        onChooseRecipient: _chooseRecipient,
                        onClearRecipient: _editor.clearRecipient,
                        onEditBusiness: _openBusinessProfile,
                      ),
                      EditorItemsCard(
                        editor: _editor,
                        money: money,
                        onAddLine: _addLine,
                        onEditLine: _editLine,
                      ),
                      EditorTotalsCard(
                        editor: _editor,
                        money: money,
                        onEditDiscount: _editDiscount,
                        onEditTax: _editTax,
                        onEditShipping: _editShipping,
                      ),
                      EditorDetailsCard(
                        editor: _editor,
                        money: money,
                        hasBusinessSignature: business.profile.hasSignature,
                        onPickCurrency: _pickCurrency,
                        onPickTemplate: _pickTemplate,
                        onEditStatus: _editStatus,
                        onEditNotes: () => _editTextBlock(
                          title: AppStrings.notes,
                          fieldLabel: AppStrings.notes,
                          current: _editor.document.notes,
                          hint: 'Thanks for your business',
                          onSaved: _editor.setNotes,
                        ),
                        onEditPaymentTerms: () => _editTextBlock(
                          title: AppStrings.paymentTerms,
                          fieldLabel: AppStrings.paymentTerms,
                          current: _editor.document.paymentTerms,
                          hint: 'Payment due within 14 days',
                          onSaved: _editor.setPaymentTerms,
                        ),
                        onEditPaymentDetails: () => _editTextBlock(
                          title: AppStrings.paymentDetails,
                          fieldLabel: AppStrings.paymentDetails,
                          current: _editor.document.paymentDetails,
                          hint: 'Bank name, account number, reference',
                          onSaved: _editor.setPaymentDetails,
                        ),
                        onToggleSignature: (enabled) =>
                            _editor.setSignaturePath(
                          enabled ? business.profile.signaturePath : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
