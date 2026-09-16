import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/search_field.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/state/customer_controller.dart';
import 'package:provider/provider.dart';

/// The saved customers.
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _query = '';

  Future<void> _open([Customer? customer]) async {
    await AppNavigator.openCustomerEditor(context, customer: customer);
  }

  Future<void> _delete(Customer customer) async {
    final confirmed = await AppSheet.confirm(
      context,
      title: AppCopy.deleteCustomerTitle,
      message: AppCopy.deleteCustomerBody,
    );
    if (!confirmed || !mounted) return;

    await context.read<CustomerController>().delete(customer.id);
    if (mounted) context.showMessage(AppCopy.deletedMessage);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomerController>();
    final customers = controller.search(_query);
    final hasAny = !controller.isEmpty;

    return AppScaffold(
      title: AppStrings.customers,
      maxContentWidth: Layout.listWidth,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-customers',
        onPressed: _open,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(AppStrings.newCustomer),
      ),
      body: Column(
        children: [
          if (hasAny)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.gutter,
                Insets.md,
                Insets.gutter,
                Insets.md,
              ),
              child: AppSearchField(
                hint: 'Search customers',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          Expanded(
            child: customers.isEmpty
                ? _emptyState(hasAny: hasAny)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Insets.gutter,
                      Insets.xs,
                      Insets.gutter,
                      Insets.scrollBottom,
                    ),
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => Gap.h8,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _CustomerRow(
                        customer: customer,
                        onTap: () => _open(customer),
                        onDelete: () => _delete(customer),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required bool hasAny}) {
    if (hasAny) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: AppCopy.noSearchResultsTitle,
        message: AppCopy.noSearchResultsBody,
      );
    }

    return AppEmptyState(
      icon: Icons.people_outline,
      title: AppCopy.noCustomersTitle,
      message: AppCopy.noCustomersBody,
      actionLabel: AppStrings.newCustomer,
      onAction: _open,
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.customer,
    required this.onTap,
    required this.onDelete,
  });

  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.md,
      ),
      child: Row(
        children: [
          _Initials(name: customer.name),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customer.name,
                  style: context.text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.subtitle.isNotEmpty) ...[
                  Gap.h2,
                  Text(
                    customer.subtitle,
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: IconSizes.md,
              color: palette.textTertiary,
            ),
            tooltip: AppStrings.delete,
          ),
        ],
      ),
    );
  }
}

/// A monogram, so the list has something to scan without needing avatars.
class _Initials extends StatelessWidget {
  const _Initials({required this.name});

  final String name;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? parts.first.substring(0, 1)
            : '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primarySurface,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials.toUpperCase(),
        style: context.text.labelLarge?.copyWith(color: palette.primary),
      ),
    );
  }
}
