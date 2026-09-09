import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/app_language.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/dialogs/discount_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/selection_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/shipping_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/tax_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/terms_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/invoice/widgets/additional_details_card.dart';
import 'package:invoicemaker/presentation/invoice/widgets/from_to_section_card.dart';
import 'package:invoicemaker/presentation/invoice/widgets/info_section_card.dart';
import 'package:invoicemaker/presentation/invoice/widgets/items_section_card.dart';
import 'package:invoicemaker/presentation/invoice/widgets/language_template_card.dart';
import 'package:invoicemaker/presentation/invoice/widgets/totals_section_card.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/item_provider.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:provider/provider.dart';

/// Creates a new invoice or edits a saved one.
///
/// All edits go through the provider's draft; saving writes the draft back to
/// the invoice list.
class CreateEditInvoiceScreen extends StatefulWidget {
  const CreateEditInvoiceScreen({super.key, required this.args});

  final CreateEditInvoiceArgs args;

  @override
  State<CreateEditInvoiceScreen> createState() =>
      _CreateEditInvoiceScreenState();
}

class _CreateEditInvoiceScreenState extends State<CreateEditInvoiceScreen> {
  @override
  void initState() {
    super.initState();
    final invoiceId = widget.args.invoiceId;
    if (invoiceId == null) return;

    // Load the saved invoice into the draft so the form edits the real record.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<InvoiceProvider>();
      final saved = provider.getInvoiceById(invoiceId);
      if (saved != null) provider.setDraft(saved);
    });
  }

  InvoiceProvider get _invoices => context.read<InvoiceProvider>();

  Future<void> _pickCurrency(Invoice invoice) async {
    final currency = await SelectionDialog.show<Currency>(
      context,
      title: AppStrings.currency,
      options: Currency.values,
      selected: invoice.currency,
      labelBuilder: (value) => value.label,
      subtitleBuilder: (value) => value.name,
    );
    if (currency == null) return;
    _invoices.updateDraft((draft) => draft.copyWith(currency: currency));
  }

  Future<void> _pickLanguage(Invoice invoice) async {
    final language = await SelectionDialog.show<AppLanguage>(
      context,
      title: AppStrings.invoiceLanguage,
      options: AppLanguage.values,
      selected: invoice.language,
      labelBuilder: (value) => value.label,
    );
    if (language == null) return;
    _invoices.updateDraft((draft) => draft.copyWith(language: language));
  }

  Future<void> _pickTemplate(Invoice invoice) async {
    final signature = context.read<SignatureProvider>().signature;
    final template = await Navigator.of(context).pushNamed(
      RouteNames.templateSelection,
      arguments: TemplateSelectionArgs(invoice: invoice, signature: signature),
    );
    if (template is! InvoiceTemplate) return;
    _invoices.updateDraft((draft) => draft.copyWith(template: template));
  }

  Future<void> _editTerms(Invoice invoice) async {
    final terms = await TermsDialog.show(context, current: invoice.terms);
    if (terms == null) return;
    _invoices.updateDraft((draft) => draft.copyWith(terms: terms));
  }

  Future<void> _pickPaymentMethod() async {
    final method = await Navigator.of(context).pushNamed(
      RouteNames.paymentMethod,
      arguments: const PaymentMethodArgs(),
    );
    if (method is! String) return;
    _invoices.updateDraft((draft) => draft.copyWith(paymentMethod: method));
  }

  Future<void> _editDiscount(Invoice invoice) async {
    final discount =
        await DiscountDialog.show(context, current: invoice.discount);
    if (discount == null) return;
    _invoices.updateDraft((draft) => draft.copyWith(discount: discount));
    _invoices.recalculateTotals();
  }

  Future<void> _editTax(Invoice invoice) async {
    final tax = await TaxDialog.show(
      context,
      currentName: invoice.taxName,
      currentRate: invoice.tax,
    );
    if (tax == null) return;
    _invoices.updateDraft(
      (draft) => draft.copyWith(taxName: tax.name, tax: tax.rate),
    );
    _invoices.recalculateTotals();
  }

  Future<void> _editShipping(Invoice invoice) async {
    final shipping = await ShippingDialog.show(
      context,
      currency: invoice.currency,
      current: invoice.shippingCharges,
    );
    if (shipping == null) return;
    _invoices.updateDraft(
      (draft) => draft.copyWith(shippingCharges: shipping),
    );
    _invoices.recalculateTotals();
  }

  /// Opens the catalogue picker, or the blank item form when it is empty.
  void _addItem() {
    final hasCatalogue = context.read<ItemProvider>().hasItems;
    Navigator.of(context).pushNamed(
      hasCatalogue ? RouteNames.addItem : RouteNames.createEditItem,
      arguments: hasCatalogue
          ? null
          : const CreateEditItemArgs(mode: ItemFormMode.invoiceLine),
    );
  }

  void _editItem(Item item) {
    Navigator.of(context).pushNamed(
      RouteNames.createEditItem,
      arguments: CreateEditItemArgs(
        item: item,
        mode: ItemFormMode.invoiceLine,
      ),
    );
  }

  /// Opens the client picker, or the blank client form when none exist, then
  /// mirrors the chosen client into the draft's "Bill To" line.
  Future<void> _pickClient() async {
    final hasClients = context.read<ClientProvider>().hasClients;
    await Navigator.of(context).pushNamed(
      hasClients ? RouteNames.addClient : RouteNames.createEditClient,
      arguments: hasClients
          ? null
          : const CreateEditClientArgs(selectOnCreate: true),
    );
    if (!mounted) return;
    _syncBillTo();
  }

  void _syncBillTo() {
    final client = context.read<ClientProvider>().selectedClient;
    if (client == null) return;
    _invoices.updateDraft((draft) => draft.copyWith(to: client.name));
  }

  void _save(Invoice invoice) {
    if (invoice.items.isEmpty) {
      context.showSnackBar('Add at least one item first.', isError: true);
      return;
    }

    // Pick up a client renamed since it was chosen.
    _syncBillTo();
    _invoices.recalculateTotals();
    final saved = _invoices.invoice;
    _invoices.saveInvoice(saved);

    if (!mounted) return;
    if (widget.args.isEditing) {
      Navigator.of(context).pop(saved);
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      RouteNames.invoiceDetail,
      arguments: InvoiceDetailArgs(invoice: saved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoice = context.watch<InvoiceProvider>().invoice;
    final signatureProvider = context.watch<SignatureProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.isEditing ? AppStrings.editInvoice : AppStrings.newInvoice,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                InfoSectionCard(
                  documentNumber: invoice.invoiceNumber,
                  creationDate: invoice.creationDate,
                  dueDate: invoice.dueDate,
                  onTap: () => Navigator.of(context).pushNamed(
                    RouteNames.invoiceInfo,
                    arguments: InvoiceInfoArgs(invoice: invoice),
                  ),
                ),
                LanguageTemplateCard(
                  language: invoice.language,
                  templateLabel: invoice.template.label,
                  onLanguageTap: () => _pickLanguage(invoice),
                  onTemplateTap: () => _pickTemplate(invoice),
                ),
                FromToSectionCard(
                  from: invoice.from,
                  to: invoice.to,
                  onFromTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.businessInfo),
                  onToTap: _pickClient,
                ),
                ItemsSectionCard(
                  items: invoice.items,
                  subTotal: invoice.subTotal,
                  currency: invoice.currency,
                  onAddItem: _addItem,
                  onEditItem: _editItem,
                  onReorder: context.read<InvoiceProvider>().reorderItems,
                  footer: TotalsSectionCard(
                    currency: invoice.currency,
                    subTotal: invoice.subTotal,
                    discount: invoice.discount,
                    taxName: invoice.taxName,
                    tax: invoice.tax,
                    shippingCharges: invoice.shippingCharges,
                    total: invoice.computedTotal,
                    onDiscountTap: () => _editDiscount(invoice),
                    onTaxTap: () => _editTax(invoice),
                    onShippingTap: () => _editShipping(invoice),
                  ),
                ),
                AdditionalDetailsCard(
                  currency: invoice.currency,
                  terms: invoice.terms,
                  paymentMethod: invoice.paymentMethod,
                  signature: signatureProvider.hasSignature
                      ? signatureProvider.signature
                      : null,
                  onCurrencyTap: () => _pickCurrency(invoice),
                  onSignatureTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.signature),
                  onTermsTap: () => _editTerms(invoice),
                  onPaymentMethodTap: _pickPaymentMethod,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          AppButton(
            label: AppStrings.preview,
            variant: AppButtonVariant.outline,
            onPressed: () => _pickTemplate(invoice),
          ),
          AppButton(
            label: AppStrings.save,
            onPressed: () => _save(invoice),
          ),
        ],
      ),
    );
  }
}
