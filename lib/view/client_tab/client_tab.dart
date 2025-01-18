import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/dialogs/delete_client_dialog.dart';
import 'package:invoicemaker/view/client_tab/edit_client_screen.dart';
import 'package:invoicemaker/view/client_tab/new_client_screen.dart';
import 'package:invoicemaker/view/widgets/drawer.dart';
import 'package:provider/provider.dart';

class ClientTab extends StatefulWidget {
  const ClientTab({super.key});

  @override
  State<ClientTab> createState() => _ClientTabState();
}

class _ClientTabState extends State<ClientTab> {
  @override
  Widget build(BuildContext context) {
    //initialize providers

    //client provider
    final clientProvider = Provider.of<ClientProvider>(context);

    //tabcontroller provider
    final tabControllerProvider = Provider.of<TabControllerProvider>(context);
    final controller = tabControllerProvider.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: whiteColor,
              )),
          const SizedBox(
            width: 5,
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.delete_outline_outlined,
                color: whiteColor,
              )),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      drawer: drawerWidget(context, controller),
      body: clientProvider.clients.isEmpty
          ? const Center(
              child: Text(
                'No Clients',
                style: TextStyle(
                  fontSize: 18,
                  color: darkBlueColor,
                ),
              ),
            )
          : ListView.builder(
              itemCount: clientProvider.clients.length,
              itemBuilder: (context, index) {
                final client = clientProvider.clients[index];
                return Card(
                  color: whiteColor,
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: SizedBox(
                    height: 75,
                    child: Center(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditClientScreen(client: client)));
                        },
                        title: Text(
                          client.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: client.emailAddress.isNotEmpty
                            ? Text(
                                client.emailAddress,
                                style: const TextStyle(color: greyColor),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              position: PopupMenuPosition.under,
                              color: whiteColor,
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditClientScreen(
                                                  client: client)));
                                } else if (result == 'delete') {
                                  deleteClientDialog(context, client);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined,
                                          color: blackColor),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          color: blackColor),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: blueColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NewClientScreen(
                        fromAddClientScreen: false,
                      )));
        },
        child: const Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
    );
  }
}
