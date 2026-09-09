import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:provider/provider.dart';

/// Creates a client or edits an existing one.
class CreateEditClientScreen extends StatefulWidget {
  const CreateEditClientScreen({super.key, required this.args});

  final CreateEditClientArgs args;

  @override
  State<CreateEditClientScreen> createState() => _CreateEditClientScreenState();
}

class _CreateEditClientScreenState extends State<CreateEditClientScreen> {
  late final Client? _client = widget.args.client;

  late final TextEditingController _nameController =
      TextEditingController(text: _client?.name ?? '');
  late final TextEditingController _emailController =
      TextEditingController(text: _client?.emailAddress ?? '');
  late final TextEditingController _phoneController =
      TextEditingController(text: _client?.phone ?? '');
  late final TextEditingController _billingController =
      TextEditingController(text: _client?.billingAddress ?? '');
  late final TextEditingController _shippingController =
      TextEditingController(text: _client?.shippingAddress ?? '');
  late final TextEditingController _detailController =
      TextEditingController(text: _client?.detail ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _billingController.dispose();
    _shippingController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showSnackBar('Client name is required.', isError: true);
      return;
    }

    final clients = context.read<ClientProvider>();

    final client = (_client ?? Client.empty()).copyWith(
      name: name,
      emailAddress: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      billingAddress: _billingController.text.trim(),
      shippingAddress: _shippingController.text.trim(),
      detail: _detailController.text,
    );

    if (widget.args.isEditing) {
      clients.updateClient(client);
    } else {
      clients.addClient(client);
      if (widget.args.selectOnCreate) clients.selectClient(client.id);
    }

    Navigator.of(context).pop(client);
  }

  Future<void> _delete() async {
    final client = _client;
    if (client == null) return;

    final confirmed = await ConfirmDialog.show(context, title: 'Delete Client');
    if (!confirmed || !mounted) return;

    context.read<ClientProvider>().removeClient(client);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.isEditing ? AppStrings.clientInfo : AppStrings.newClient,
        ),
        actions: [
          if (widget.args.isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outlined),
            ),
          IconButton(
            tooltip: AppStrings.save,
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
          Gap.wSm,
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledField(
                        label: 'Client Name',
                        child: AppTextField(
                          controller: _nameController,
                          hintText: 'Enter client name',
                        ),
                      ),
                      LabeledField(
                        label: 'Email Address',
                        child: AppTextField(
                          controller: _emailController,
                          hintText: 'Enter client email address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      LabeledField(
                        label: 'Phone',
                        child: AppTextField(
                          controller: _phoneController,
                          hintText: 'Enter client phone number',
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                        ),
                      ),
                      LabeledField(
                        label: 'Billing Address',
                        child: AppTextField(
                          controller: _billingController,
                          hintText: 'Enter billing address',
                        ),
                      ),
                      LabeledField(
                        label: 'Shipping Address',
                        child: AppTextField(
                          controller: _shippingController,
                          hintText: 'Enter shipping address',
                        ),
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  child: LabeledField(
                    label: 'Client Detail (Not shown on invoice)',
                    labelStyle: AppTextStyles.fieldLabelDark,
                    child: AppTextField.multiline(
                      controller: _detailController,
                      hintText: 'Enter client detail',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
