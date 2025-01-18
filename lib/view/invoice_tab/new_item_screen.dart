import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class NewItemScreen extends StatefulWidget {
  NewItemScreen({super.key, required this.fromAddItemScreen});
  bool fromAddItemScreen;

  @override
  // ignore: library_private_types_in_public_api
  _NewItemScreenState createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  // Declare all controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantController = TextEditingController();
  final unitController = TextEditingController();
  final discountController = TextEditingController();
  final taxController = TextEditingController();
  final descriptionController = TextEditingController();

  late double price = 0.0;
  late int quantity = 1;
  late double discount = 0.0;
  late double tax = 0.0;
  double subAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize values of these controllers
    priceController.text = '0';
    quantController.text = '1';
    discountController.text = '0';
    taxController.text = '0';

    // Add listeners to controllers
    priceController.addListener(_calculateSubAmount);
    quantController.addListener(_calculateSubAmount);
    discountController.addListener(_calculateSubAmount);
    taxController.addListener(_calculateSubAmount);
  }

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    priceController.dispose();
    quantController.dispose();
    unitController.dispose();
    discountController.dispose();
    taxController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Calculate amount method
  double calculateItemAmount({
    required double price,
    required int quantity,
    required double discountPercentage,
    required double taxPercentage,
  }) {
    double total = price * quantity;
    double discountAmount = total * (discountPercentage / 100);
    double totalAfterDiscount = total - discountAmount;
    double taxAmount = totalAfterDiscount * (taxPercentage / 100);
    double finalAmount = totalAfterDiscount + taxAmount;

    return finalAmount;
  }

  void _calculateSubAmount() {
    setState(() {
      price = double.tryParse(priceController.text) ?? 0.0;
      quantity = int.tryParse(quantController.text) ?? 1;
      discount = double.tryParse(discountController.text) ?? 0.0;
      tax = double.tryParse(taxController.text) ?? 0.0;

      subAmount = calculateItemAmount(
        price: price,
        quantity: quantity,
        discountPercentage: discount,
        taxPercentage: tax,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Item Provider
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    // Initialize Invoice Provider
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
        actions: [
          IconButton(
            onPressed: () {
              // Generate a new id for the item
              final String newItemId = DateTime.now().toIso8601String();

              // Update the provider's item with new id using copyWith
              final updatedItem = itemProvider.item.copyWith(
                id: newItemId,
                name: nameController.text,
                price: price,
                quantity: quantity,
                unitOfMeasure: unitController.text,
                discount: discount,
                tax: tax,
                subAmount: subAmount,
                description: descriptionController.text,
              );

              // Update the ItemProvider with the new item
              itemProvider.setItem(updatedItem);

              // Add the item to the ItemProvider's list of items
              itemProvider.addItem(updatedItem);

              // Add item into invoice items list using copyWith
              final updatedInvoice = invoiceProvider.invoice.copyWith(
                items: [...invoiceProvider.invoice.items, updatedItem],
              );

              // Update the InvoiceProvider with the new invoice
              invoiceProvider.setInvoice(updatedInvoice);

              // Calculating subtotal by adding all items in the invoice
              double subTotal = updatedInvoice.items
                  .fold(0, (sum, item) => sum + item.subAmount);

              invoiceProvider.setSubTotal(subTotal);

              // Update total
              double total = invoiceProvider.calculateTotal();
              invoiceProvider.setTotal(total);

              // Handle navigation
              if (widget.fromAddItemScreen) {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              } else {
                Navigator.pop(context);
              }
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
                        'Item Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      CustomTextField(
                        controller: quantController,
                        hintText: '1',
                        keyboardType: TextInputType.number,
                        selectAllOnFocus: true,
                        onChanged: (value) {
                          int quantValue = int.tryParse(value) ?? 0;
                          // Check if the input contains only digits and at most one period (.)
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          // If the input is invalid or contains anything other than numbers or '.'
                          if (!validInput.hasMatch(value)) {
                            quantController.clear();
                            // Move the cursor to the end of the text
                            quantController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: quantController.text.length),
                            );
                          } else if (value.contains('-') || quantValue < 0) {
                            // Additional checks for negative values or invalid numbers
                            quantController.clear();
                            quantController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: quantController.text.length),
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
                      const SizedBox(height: 15),
                      const Text(
                        'Discount (%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      CustomTextField(
                        controller: discountController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        selectAllOnFocus: true,
                        onChanged: (value) {
                          double discountValue = double.tryParse(value) ?? 0.0;
                          // Check if the input contains only digits and at most one period (.)
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          // If the input is invalid or contains anything other than numbers or '.'
                          if (!validInput.hasMatch(value)) {
                            discountController.clear();
                            // Move the cursor to the end of the text
                            discountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: discountController.text.length),
                            );
                          } else if (value.contains('-') || discountValue < 0) {
                            // Additional checks for negative values or invalid numbers
                            discountController.clear();
                            discountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: discountController.text.length),
                            );
                          }
                          if (discountValue > 100) {
                            discountController.text = '100';
                            discountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: discountController.text.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tax Rate (%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlueColor,
                          height: 2.1,
                        ),
                      ),
                      CustomTextField(
                        controller: taxController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        selectAllOnFocus: true,
                        onChanged: (value) {
                          double taxValue = double.tryParse(value) ?? 0.0;
                          // Check if the input contains only digits and at most one period (.)
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          // If the input is invalid or contains anything other than numbers or '.'
                          if (!validInput.hasMatch(value)) {
                            taxController.clear();
                            // Move the cursor to the end of the text
                            taxController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: taxController.text.length),
                            );
                          } else if (value.contains('-') || taxValue < 0) {
                            // Additional checks for negative values or invalid numbers
                            taxController.clear();
                            taxController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: taxController.text.length),
                            );
                          }
                          if (taxValue > 100) {
                            taxController.text = '100';
                            taxController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: taxController.text.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '* The discount and tax is valid on this item only',
                        style: TextStyle(
                          color: greyColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: darkBlueColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: const Text(
                            'Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: whiteColor,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Text(
                            "Rs${subAmount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: whiteColor,
                            ),
                          ),
                        ),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
