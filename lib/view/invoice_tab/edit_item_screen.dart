import 'package:flutter/material.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({
    super.key,
    required this.item,
    required this.fromAddItemScreen,
  });

  final Item item;
  final bool fromAddItemScreen;

  @override
  // ignore: library_private_types_in_public_api
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  // Controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantController = TextEditingController();
  final unitController = TextEditingController();
  final discountController = TextEditingController();
  final taxController = TextEditingController();
  final descriptionController = TextEditingController();

  late double price;
  late int quantity;
  late double discount;
  late double tax;
  late double subAmount;

  @override
  void initState() {
    super.initState();

    // Initialize variables
    price = widget.item.price;
    quantity = widget.item.quantity;
    discount = widget.item.discount;
    tax = widget.item.tax;
    subAmount = widget.item.subAmount;

    // Initialize controllers
    nameController.text = widget.item.name;
    priceController.text = widget.item.price.toString();
    quantController.text = widget.item.quantity.toString();
    discountController.text = widget.item.discount.toString();
    taxController.text = widget.item.tax.toString();
    descriptionController.text = widget.item.description;

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
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          widget.fromAddItemScreen
              ? Container()
              : IconButton(
                  onPressed: () {
                    // Remove the item from the InvoiceProvider's list
                    invoiceProvider.invoice.items.remove(widget.item);

                    // Update the subTotal after item removal
                    double subTotal = invoiceProvider.invoice.items
                        .fold(0, (sum, item) => sum + item.subAmount);

                    // Update the InvoiceProvider's subTotal
                    invoiceProvider.setSubTotal(subTotal);

                    // Navigate back
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: () {
              final updatedItem = Item(
                id: widget.fromAddItemScreen
                    ? DateTime.now().toIso8601String()
                    : widget.item.id,
                name: nameController.text,
                price: price,
                quantity: quantity,
                unitOfMeasure: unitController.text,
                discount: discount,
                tax: tax,
                subAmount: subAmount,
                description: descriptionController.text,
              );

              // Update the item in the ItemProvider
              itemProvider.setItem(updatedItem);

              // Update or add the item in the invoice
              if (widget.fromAddItemScreen) {
                invoiceProvider.setItems([
                  ...invoiceProvider.invoice.items,
                  updatedItem,
                ]);
              } else {
                invoiceProvider.updateItem(widget.item.id, updatedItem);
              }

              // Recalculate totals
              invoiceProvider.recalculateTotals();

              if (widget.fromAddItemScreen) {
                Navigator.of(context)
                  ..pop(updatedItem)
                  ..pop();
              } else {
                Navigator.pop(context, updatedItem);
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
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          if (!validInput.hasMatch(value)) {
                            priceController.clear();
                            priceController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: priceController.text.length),
                            );
                          } else if (value.contains('-') || priceValue < 0) {
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
                          final validInput = RegExp(r'^\d*$');

                          if (!validInput.hasMatch(value)) {
                            quantController.clear();
                            quantController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: quantController.text.length),
                            );
                          } else if (value.contains('-') || quantValue < 0) {
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
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          if (!validInput.hasMatch(value)) {
                            discountController.clear();
                            discountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: discountController.text.length),
                            );
                          } else if (value.contains('-') || discountValue < 0) {
                            discountController.clear();
                            discountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: discountController.text.length),
                            );
                          } else if (discountValue > 100) {
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
                        'Tax (%)',
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
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          if (!validInput.hasMatch(value)) {
                            taxController.clear();
                            taxController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: taxController.text.length),
                            );
                          } else if (value.contains('-') || taxValue < 0) {
                            taxController.clear();
                            taxController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: taxController.text.length),
                            );
                          } else if (taxValue > 100) {
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
            ],
          ),
        ),
      ),
    );
  }
}
