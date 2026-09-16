import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/customer.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/search_field.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/state/customer_controller.dart';
import 'package:provider/provider.dart';

/// What the customer picker returned.
sealed class CustomerPick {
  const CustomerPick();
}

/// An existing saved customer was chosen.
class CustomerPickSaved extends CustomerPick {
  const CustomerPickSaved(this.customer);

  final Customer customer;
}

/// A name was typed for a one-off document, with nothing saved.
class CustomerPickOneOff extends CustomerPick {
  const CustomerPickOneOff(this.name);

  final String name;
}

/// The user asked to create and save a new customer.
class CustomerPickCreate extends CustomerPick {
  const CustomerPickCreate();
}

/// Chooses who a document is for.
///
/// The search box doubles as a one-off name field: typing a name that matches
/// nothing offers to use it directly, which keeps a walk-in sale to a single
/// step without forcing the user to save a customer they will never bill
/// again.
sealed class CustomerPickerSheet {
  static Future<CustomerPick?> show(BuildContext context) {
    return AppSheet.show<CustomerPick>(
      context: context,
      title: 'Bill to',
      builder: (sheetContext) => const _CustomerPickerBody(),
    );
  }
}

class _CustomerPickerBody extends StatefulWidget {
  const _CustomerPickerBody();

  @override
  State<_CustomerPickerBody> createState() => _CustomerPickerBodyState();
}

class _CustomerPickerBodyState extends State<_CustomerPickerBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerController>().search(_query);
    final trimmedQuery = _query.trim();
    final hasExactMatch = customers.any(
      (customer) =>
          customer.name.toLowerCase() == trimmedQuery.toLowerCase(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.gutter),
          child: AppSearchField(
            hint: 'Search or type a name',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Gap.h12,
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: Insets.lg),
            children: [
              if (trimmedQuery.isNotEmpty && !hasExactMatch)
                AppTile(
                  title: 'Use "$trimmedQuery"',
                  subtitle: 'Just for this document',
                  icon: Icons.bolt_outlined,
                  showChevron: false,
                  onTap: () => Navigator.of(context).pop(
                    CustomerPickOneOff(trimmedQuery),
                  ),
                ),
              AppTile(
                title: AppStrings.newCustomer,
                subtitle: 'Save their details for next time',
                icon: Icons.person_add_outlined,
                showChevron: false,
                onTap: () =>
                    Navigator.of(context).pop(const CustomerPickCreate()),
              ),
              if (customers.isNotEmpty) ...[
                Divider(height: Insets.lg, color: context.palette.border),
                for (final customer in customers)
                  AppTile(
                    title: customer.name,
                    subtitle: customer.subtitle.isEmpty
                        ? null
                        : customer.subtitle,
                    showChevron: false,
                    onTap: () => Navigator.of(context).pop(
                      CustomerPickSaved(customer),
                    ),
                  ),
              ] else if (trimmedQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Insets.lg),
                  child: Text(
                    'No saved customer matches that name.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: Insets.md),
                  child: AppEmptyState(
                    icon: Icons.people_outline,
                    title: AppCopy.noCustomersTitle,
                    message: AppCopy.noCustomersBody,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
