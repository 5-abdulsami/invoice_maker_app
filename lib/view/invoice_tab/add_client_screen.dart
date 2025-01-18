import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/client_tab/edit_client_screen.dart';
import 'package:invoicemaker/view/client_tab/new_client_screen.dart';
import 'package:provider/provider.dart';

class AddClientScreen extends StatelessWidget {
  final bool fromSettings;

  const AddClientScreen({super.key, this.fromSettings = false});

  @override
  Widget build(BuildContext context) {
    // Initialize invoice provider
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Client'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: whiteColor,
              elevation: 3,
              child: SizedBox(
                height: 70,
                child: Center(
                  child: ListTile(
                    leading: const Icon(
                      Icons.add_circle,
                      color: darkBlueColor,
                    ),
                    title: const Text(
                      'New Client',
                      style: TextStyle(
                          fontSize: 20,
                          color: darkBlueColor,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewClientScreen(
                            fromAddClientScreen: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Client List',
              style: TextStyle(
                  fontSize: 16,
                  color: darkBlueColor,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<ClientProvider>(
                builder: (context, clientProvider, child) {
                  return ListView.builder(
                    itemCount: clientProvider.clients.length,
                    itemBuilder: (context, index) {
                      final client = clientProvider.clients[index];
                      final isSelected = client.isSelected;

                      return Card(
                        color: whiteColor,
                        elevation: 3,
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              clientProvider.setClient(client);
                              // clientProvider.selectClient(client.id);
                              invoiceProvider.setTo(client.name);

                              // Pop the screen when the client is selected
                              Navigator.pop(context);
                            },
                            leading: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected ? blueColor : null,
                            ),
                            title: Text(client.name),
                            subtitle: client.emailAddress.isNotEmpty
                                ? Text(
                                    client.emailAddress,
                                    style: const TextStyle(
                                      color: greyColor,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditClientScreen(client: client),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
