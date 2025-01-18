import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/item_tab/dialogs/delete_item_dialog.dart';
import 'package:invoicemaker/view/item_tab/edit_item.dart';
import 'package:invoicemaker/view/item_tab/new_item.dart';
import 'package:invoicemaker/view/widgets/drawer.dart';
import 'package:provider/provider.dart';

class ItemTab extends StatefulWidget {
  const ItemTab({super.key});

  @override
  State<ItemTab> createState() => _ItemTabState();
}

class _ItemTabState extends State<ItemTab> {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final tabControllerProvider = Provider.of<TabControllerProvider>(context);
    final controller = tabControllerProvider.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.delete_outline_outlined,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      drawer: drawerWidget(context, controller),
      body: itemProvider.items.isEmpty
          ? const Center(
              child: Text(
                'No items',
                style: TextStyle(
                  fontSize: 18,
                  color: darkBlueColor,
                ),
              ),
            )
          : ListView.builder(
              itemCount: itemProvider.items.length,
              itemBuilder: (context, index) {
                final item = itemProvider.items[index];
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
                                  builder: (context) => EditItem(item: item)));
                        },
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rs${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkBlueColor,
                              ),
                            ),
                            PopupMenuButton<String>(
                              position: PopupMenuPosition.under,
                              color: whiteColor,
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditItem(
                                                item: item,
                                              )));
                                } else if (result == 'delete') {
                                  deleteItemDialog(context, item);
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
            MaterialPageRoute(builder: (context) => const NewItem()),
          );
        },
        child: const Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
    );
  }
}
