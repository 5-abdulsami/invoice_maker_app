import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/invoice_tab/edit_item_screen.dart';
import 'package:invoicemaker/view/invoice_tab/new_item_screen.dart';
import 'package:provider/provider.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //initialize item provider
    final itemProvider = Provider.of<ItemProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
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
            //New Item Card
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
                      'New Item',
                      style: TextStyle(
                          fontSize: 20,
                          color: darkBlueColor,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      // Show the payment method dialog
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewItemScreen(
                                    fromAddItemScreen: true,
                                  )));
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Item List',
              style: TextStyle(
                  fontSize: 16,
                  color: darkBlueColor,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
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
                                    builder: (context) => EditItemScreen(
                                          item: item,
                                          fromAddItemScreen: true,
                                        )));
                          },
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          trailing: Text(
                            'Rs${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkBlueColor,
                            ),
                          ),
                        ),
                      ),
                    ),
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
