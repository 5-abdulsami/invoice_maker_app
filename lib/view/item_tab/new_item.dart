import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  // Declare all controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final descriptionController = TextEditingController();

  late double price = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize values of these controllers
    priceController.text = '0';
  }

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    priceController.dispose();
    unitController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Item Provider
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    // Initialize Invoice Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
        actions: [
          IconButton(
            onPressed: () {
              // Generate a new id for the item
              final String newItemId = DateTime.now().toIso8601String();

              // Update the provider's item with new id
              itemProvider.setItem(itemProvider.item.copyWith(id: newItemId));
              itemProvider.setName(nameController.text);
              itemProvider.setPrice(double.parse(priceController.text));
              itemProvider.setQuantity(1);
              itemProvider.setUnitOfMeasure(unitController.text);
              itemProvider.setDescription(descriptionController.text);
              itemProvider.setSubAmount(double.parse(priceController.text));

              // Add the item to the ItemProvider's list of items
              itemProvider.addItem(itemProvider.item);

              // Optionally, you can navigate back or show a confirmation message
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Item Info Card
              Card(
                color: whiteColor,
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      CustomTextField(
                        controller: nameController,
                        hintText: 'Enter Item Name',
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Item Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      CustomTextField(
                        controller: priceController,
                        hintText: 'Rs0',
                        keyboardType: TextInputType.number,
                        selectAllOnFocus: true,
                        onChanged: (value) {
                          double priceValue = double.tryParse(value) ?? 0.0;
                          // Check if the input contains only digits and at most one period (.)
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          // If the input is invalid or contains anything other than numbers or '.'
                          if (!validInput.hasMatch(value)) {
                            priceController.clear();
                            // Move the cursor to the end of the text
                            priceController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: priceController.text.length),
                            );
                          } else if (value.contains('-') || priceValue < 0) {
                            // Additional checks for negative values or invalid numbers
                            priceController.clear();
                            priceController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: priceController.text.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Unit of Measure',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      CustomTextField(
                        controller: unitController,
                        hintText: 'None',
                      ),
                    ],
                  ),
                ),
              ),
              // Item Description Card
              Card(
                color: whiteColor,
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item Description',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter item description',
                          hintStyle: const TextStyle(color: hintTextColor),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: lightGreyColor,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        minLines: 4,
                        maxLines: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
