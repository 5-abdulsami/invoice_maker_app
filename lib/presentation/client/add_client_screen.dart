import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/client/client_list_screen.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/search_app_bar.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:provider/provider.dart';

/// Picks the client an invoice is billed to.
class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  String _query = '';

  void _select(Client client) {
    context.read<ClientProvider>().selectClient(client.id);
    Navigator.of(context).pop(client);
  }

  Future<void> _createClient() async {
    final created = await Navigator.of(context).pushNamed(
      RouteNames.createEditClient,
      arguments: const CreateEditClientArgs(selectOnCreate: true),
    );
    // A brand new client is the one the user wants to bill.
    if (created is Client && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();
    final clients = provider.search(_query);

    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.addClient,
        hintText: 'Search clients',
        onQueryChanged: (query) => setState(() => _query = query),
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
                  AppStrings.newClient,
                  style: AppTextStyles.listHeader,
                ),
                onTap: _createClient,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('Client List', style: AppTextStyles.listHeader),
          ),
          Gap.sm,
          Expanded(
            child: clients.isEmpty
                ? EmptyStateWidget(
                    message: _query.isEmpty
                        ? AppStrings.noClients
                        : 'No matching clients',
                  )
                : ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      final isSelected =
                          provider.selectedClient?.id == client.id;

                      return ClientTile(
                        client: client,
                        onTap: () => _select(client),
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? AppColors.primary : null,
                        ),
                        onEdit: () => Navigator.of(context).pushNamed(
                          RouteNames.createEditClient,
                          arguments: CreateEditClientArgs(client: client),
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
