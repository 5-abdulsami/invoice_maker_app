import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/validators.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/state/customer_controller.dart';
import 'package:provider/provider.dart';

/// Creates or edits a saved customer.
///
/// Pops with the stored [Customer], so the document editor can use a customer
/// created mid-flow without the user having to find them again.
class CustomerEditorScreen extends StatefulWidget {
  const CustomerEditorScreen({super.key, this.customer});

  final Customer? customer;

  bool get isEditing => customer != null;

  @override
  State<CustomerEditorScreen> createState() => _CustomerEditorScreenState();
}

class _CustomerEditorScreenState extends State<CustomerEditorScreen>
    with AsyncAction {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final Customer? _original = widget.customer;

  late final TextEditingController _name =
      TextEditingController(text: _original?.name ?? '');
  late final TextEditingController _email =
      TextEditingController(text: _original?.email ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: _original?.phone ?? '');
  late final TextEditingController _address =
      TextEditingController(text: _original?.address ?? '');
  late final TextEditingController _taxNumber =
      TextEditingController(text: _original?.taxNumber ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: _original?.notes ?? '');

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _address,
      _taxNumber,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final customers = context.read<CustomerController>();
    final existing = _original;

    final customer = existing == null
        ? Customer.create(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            taxNumber: _taxNumber.text.trim(),
            notes: _notes.text.trim(),
          )
        : existing.copyWith(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            taxNumber: _taxNumber.text.trim(),
            notes: _notes.text.trim(),
          );

    var didSave = false;
    await run(
      () async {
        await customers.save(customer);
        didSave = true;
      },
      successMessage: AppCopy.savedMessage,
    );
    if (!didSave || !mounted) return;

    Navigator.of(context).pop(customer);
  }

  Future<void> _delete() async {
    final customer = _original;
    if (customer == null) return;

    final confirmed = await AppSheet.confirm(
      context,
      title: AppCopy.deleteCustomerTitle,
      message: AppCopy.deleteCustomerBody,
    );
    if (!confirmed || !mounted) return;

    await context.read<CustomerController>().delete(customer.id);
    if (!mounted) return;

    context.showMessage(AppCopy.deletedMessage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? 'Edit customer' : AppStrings.newCustomer,
      actions: [
        if (widget.isEditing)
          IconButton(
            onPressed: isBusy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.delete,
          ),
      ],
      bottomBar: BottomActionBar(
        children: [
          AppButton(
            label: widget.isEditing ? AppStrings.saveChanges : AppStrings.save,
            icon: Icons.check,
            isBusy: isBusy,
            onPressed: _save,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        child: Form(
          key: _formKey,
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
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _name,
                          label: AppStrings.customerName,
                          hint: 'Person or company',
                          validator: Validators.required,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _email,
                          label: AppStrings.email,
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                          validator: Validators.optionalEmail,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _phone,
                          label: AppStrings.phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap.h16,
                        AppTextField.multiline(
                          controller: _address,
                          label: AppStrings.address,
                          hint: 'Street, city, postcode',
                          minLines: 2,
                          maxLines: 4,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _taxNumber,
                          label: AppStrings.taxNumber,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    child: AppTextField.multiline(
                      controller: _notes,
                      label: 'Private notes',
                      hint: 'Never printed on a document',
                      maxLines: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
