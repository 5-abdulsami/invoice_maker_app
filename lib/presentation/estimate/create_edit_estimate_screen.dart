import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/data/models/estimate.dart';
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
import 'package:invoicemaker/presentation/invoice/widgets/totals_section_card.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:invoicemaker/providers/item_provider.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:provider/provider.dart';

/// Creates a new estimate or edits a saved one.
class CreateEditEstimateScreen extends StatefulWidget {
  const CreateEditEstimateScreen({super.key, required this.args});

  final CreateEditEstimateArgs args;

  @override
  State<CreateEditEstimateScreen> createState() =>
      _CreateEditEstimateScreenState();
}

class _CreateEditEstimateScreenState extends State<CreateEditEstimateScreen> {
  @override
  void initState() {
    super.initState();
    final estimateId = widget.args.estimateId;
    if (estimateId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<EstimateProvider>();
      final saved = provider.getEstimateById(estimateId);
      if (saved != null) provider.setDraft(saved);
    });
  }

  EstimateProvider get _estimates => context.read<EstimateProvider>();

  Future<void> _pickCurrency(Estimate estimate) async {
    final currency = await SelectionDialog.show<Currency>(
      context,
      title: AppStrings.currency,
      options: Currency.values,
      selected: estimate.currency,
      labelBuilder: (value) => value.label,
      subtitleBuilder: (value) => value.name,
    );
    if (currency == null) return;
    _estimates.updateDraft((draft) => draft.copyWith(currency: currency));
  }

  Future<void> _editTerms(Estimate estimate) async {
    final terms = await TermsDialog.show(context, current: estimate.terms);
    if (terms == null) return;
    _estimates.updateDraft((draft) => draft.copyWith(terms: terms));
  }

  Future<void> _editDiscount(Estimate estimate) async {
    final discount =
        await DiscountDialog.show(context, current: estimate.discount);
    if (discount == null) return;
    _estimates.updateDraft((draft) => draft.copyWith(discount: discount));
    _estimates.recalculateTotals();
  }

  Future<void> _editTax(Estimate estimate) async {
    final tax = await TaxDialog.show(
      context,
      currentName: estimate.taxName,
      currentRate: estimate.tax,
    );
    if (tax == null) return;
    _estimates.updateDraft(
      (draft) => draft.copyWith(taxName: tax.name, tax: tax.rate),
    );
    _estimates.recalculateTotals();
  }

  Future<void> _editShipping(Estimate estimate) async {
    final shipping = await ShippingDialog.show(
      context,
      currency: estimate.currency,
      current: estimate.shippingCharges,
    );
    if (shipping == null) return;
    _estimates.updateDraft((draft) => draft.copyWith(shippingCharges: shipping));
    _estimates.recalculateTotals();
  }

  void _addItem() {
    final hasCatalogue = context.read<ItemProvider>().hasItems;
    Navigator.of(context).pushNamed(
      hasCatalogue ? RouteNames.addItem : RouteNames.createEditItem,
      arguments: hasCatalogue
          ? const AddItemArgs(mode: ItemFormMode.estimateLine)
          : const CreateEditItemArgs(mode: ItemFormMode.estimateLine),
    );
  }

  void _editItem(Item item) {
    Navigator.of(context).pushNamed(
      RouteNames.createEditItem,
      arguments: CreateEditItemArgs(
        item: item,
        mode: ItemFormMode.estimateLine,
      ),
    );
  }

  /// Opens the client picker, then mirrors the choice into the draft.
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
    _estimates.updateDraft((draft) => draft.copyWith(to: client.name));
  }

  void _openBusinessInfo() {
    Navigator.of(context).pushNamed(RouteNames.businessInfo).then((_) {
      if (!mounted) return;
      final name = context.read<BusinessProvider>().business.businessName;
      _estimates.updateDraft((draft) => draft.copyWith(from: name));
    });
  }

  void _save(Estimate estimate) {
    if (estimate.items.isEmpty) {
      context.showSnackBar('Add at least one item first.', isError: true);
      return;
    }

    _syncBillTo();
    _estimates.recalculateTotals();
    _estimates.saveEstimate(_estimates.estimate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final estimate = context.watch<EstimateProvider>().estimate;
    final signatureProvider = context.watch<SignatureProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.isEditing
              ? AppStrings.editEstimate
              : AppStrings.newEstimate,
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
                  documentNumber: estimate.estimateNumber,
                  creationDate: estimate.creationDate,
                  dueDate: estimate.dueDate,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.estimateInfo),
                ),
                FromToSectionCard(
                  from: estimate.from,
                  to: estimate.to,
                  onFromTap: _openBusinessInfo,
                  onToTap: _pickClient,
                ),
                ItemsSectionCard(
                  items: estimate.items,
                  subTotal: estimate.subTotal,
                  currency: estimate.currency,
                  onAddItem: _addItem,
                  onEditItem: _editItem,
                  onReorder: _estimates.reorderItems,
                  footer: TotalsSectionCard(
                    currency: estimate.currency,
                    subTotal: estimate.subTotal,
                    discount: estimate.discount,
                    taxName: estimate.taxName,
                    tax: estimate.tax,
                    shippingCharges: estimate.shippingCharges,
                    total: estimate.computedTotal,
                    onDiscountTap: () => _editDiscount(estimate),
                    onTaxTap: () => _editTax(estimate),
                    onShippingTap: () => _editShipping(estimate),
                  ),
                ),
                AdditionalDetailsCard(
                  currency: estimate.currency,
                  terms: estimate.terms,
                  paymentMethod: '',
                  signature: signatureProvider.hasSignature
                      ? signatureProvider.signature
                      : null,
                  onCurrencyTap: () => _pickCurrency(estimate),
                  onSignatureTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.signature),
                  onTermsTap: () => _editTerms(estimate),
                  onPaymentMethodTap: () => Navigator.of(context).pushNamed(
                    RouteNames.paymentMethod,
                    arguments: const PaymentMethodArgs(manageOnly: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          AppButton(
            label: AppStrings.save,
            onPressed: () => _save(estimate),
          ),
        ],
      ),
    );
  }
}
