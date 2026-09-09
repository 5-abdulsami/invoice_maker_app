import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_drawer.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/search_app_bar.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:provider/provider.dart';

/// The client tab: search, edit and delete saved clients.
class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  String _query = '';

  Future<void> _delete(Client client) async {
    final confirmed = await ConfirmDialog.show(context, title: 'Delete Client');
    if (!confirmed || !mounted) return;
    context.read<ClientProvider>().removeClient(client);
  }

  Future<void> _clearAll() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete All Clients',
      message: 'This removes every saved client. Continue?',
    );
    if (!confirmed || !mounted) return;
    context.read<ClientProvider>().clearClients();
  }

  void _openForm([Client? client]) {
    Navigator.of(context).pushNamed(
      RouteNames.createEditClient,
      arguments: CreateEditClientArgs(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().search(_query);

    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.client,
        hintText: 'Search clients',
        onQueryChanged: (query) => setState(() => _query = query),
        actions: [
          IconButton(
            tooltip: 'Delete all',
            onPressed: clients.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_outline_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: clients.isEmpty
          ? EmptyStateWidget(
              message:
                  _query.isEmpty ? AppStrings.noClients : 'No matching clients',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ClientTile(
                  client: client,
                  onTap: () => _openForm(client),
                  onEdit: () => _openForm(client),
                  onDelete: () => _delete(client),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppStrings.newClient,
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// One client row, with an optional overflow menu.
class ClientTile extends StatelessWidget {
  const ClientTile({
    super.key,
    required this.client,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.leading,
  });

  final Client client;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          client.name.isEmpty ? AppStrings.unknownClient : client.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: client.emailAddress.isEmpty
            ? null
            : Text(client.emailAddress, style: AppTextStyles.caption),
        trailing: onEdit == null && onDelete == null
            ? null
            : PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                onSelected: (value) =>
                    value == 'edit' ? onEdit?.call() : onDelete?.call(),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
