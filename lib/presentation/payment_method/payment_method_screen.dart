import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/text_input_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/payment_method_provider.dart';
import 'package:provider/provider.dart';

/// Lists saved payment methods, and picks one for an invoice.
///
/// Opened from settings it only manages the list; opened from the invoice form
/// it pops with the selected method's details.
class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key, required this.args});

  final PaymentMethodArgs args;

  Future<void> _create(BuildContext context) async {
    final details = await TextInputDialog.show(
      context,
      title: 'New ${AppStrings.paymentMethod}',
      fieldLabel: 'Payment Detail',
    );
    if (details == null || details.trim().isEmpty || !context.mounted) return;
    context.read<PaymentMethodProvider>().addPaymentMethod(details);
  }

  Future<void> _edit(BuildContext context, int index) async {
    final provider = context.read<PaymentMethodProvider>();
    final details = await TextInputDialog.show(
      context,
      title: 'Edit ${AppStrings.paymentMethod}',
      fieldLabel: 'Payment Detail',
      initialValue: provider.paymentMethods[index].details,
    );
    if (details == null || details.trim().isEmpty) return;
    provider.updatePaymentMethod(index, details);
  }

  Future<void> _delete(BuildContext context, int index) async {
    final provider = context.read<PaymentMethodProvider>();
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${AppStrings.paymentMethod}',
    );
    if (!confirmed) return;
    provider.removePaymentMethod(index);
  }

  void _confirmSelection(BuildContext context) {
    final provider = context.read<PaymentMethodProvider>();

    if (args.manageOnly || provider.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final selected = provider.selectedPaymentMethod;
    if (selected == null) {
      context.showSnackBar(AppStrings.selectPaymentMethodFirst, isError: true);
      return;
    }
    Navigator.of(context).pop(selected.details);
  }

  @override
  Widget build(BuildContext context) {
    final methods = context.watch<PaymentMethodProvider>().paymentMethods;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.paymentMethod),
        actions: [
          IconButton(
            tooltip: args.manageOnly ? 'Done' : 'Use this method',
            onPressed: () => _confirmSelection(context),
            icon: const Icon(Icons.check),
          ),
          Gap.wSm,
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SectionCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.add_circle),
                title: const Text(
                  'New ${AppStrings.paymentMethod}',
                  style: AppTextStyles.listHeader,
                ),
                onTap: () => _create(context),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Payment Method List',
              style: AppTextStyles.listHeader,
            ),
          ),
          Gap.sm,
          Expanded(
            child: methods.isEmpty
                ? const EmptyStateWidget(
                    message: 'No payment methods yet',
                    showImage: false,
                  )
                : ListView.builder(
                    itemCount: methods.length,
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: ListTile(
                          onTap: args.manageOnly
                              ? () => _edit(context, index)
                              : () => context
                                  .read<PaymentMethodProvider>()
                                  .togglePaymentMethodSelection(index),
                          leading: args.manageOnly
                              ? null
                              : Icon(
                                  method.isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: method.isSelected
                                      ? AppColors.primary
                                      : null,
                                ),
                          title: Text(method.details),
                          trailing: args.manageOnly
                              ? PopupMenuButton<String>(
                                  position: PopupMenuPosition.under,
                                  onSelected: (value) => value == 'edit'
                                      ? _edit(context, index)
                                      : _delete(context, index),
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete'),
                                      ),
                                    ),
                                  ],
                                )
                              : IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => _edit(context, index),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
