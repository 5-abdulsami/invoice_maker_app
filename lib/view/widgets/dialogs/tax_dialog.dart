import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

Future<dynamic> taxDialog(BuildContext context) async {
  var taxNameController = TextEditingController();
  var taxController = TextEditingController();
  var width = MediaQuery.of(context).size.width * 1;
  showDialog(
      context: context,
      builder: (context) {
        // initialize invoice provider
        final invoiceProvider = Provider.of<InvoiceProvider>(context);

        // tax name controller
        taxNameController.text = taxNameController.text.isNotEmpty
            ? invoiceProvider.invoice.taxName
            : "";
        taxController.text = taxController.text.isNotEmpty
            ? invoiceProvider.invoice.tax.toString()
            : "";
        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'Tax',
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
          ),
          content: SizedBox(
            width: width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tax Name',
                  style: TextStyle(
                      fontSize: 14, color: darkGreyColor, height: 2.1),
                ),
                CustomTextField(
                  controller: taxNameController,
                  hintText: 'Enter tax name',
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Tax Rate',
                  style: TextStyle(
                      fontSize: 14, color: darkGreyColor, height: 2.1),
                ),
                CustomTextField(
                  controller: taxController,
                  hintText: '0%',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    double taxValue = double.tryParse(value) ?? 0.0;
                    // Check if the input contains only digits and at most one period (.)
                    final validInput = RegExp(r'^\d*\.?\d*$');

                    // If the input is invalid or contains anything other than numbers or '.'
                    if (!validInput.hasMatch(value)) {
                      taxController.clear();
                      // Move the cursor to the end of the text
                      taxController.selection = TextSelection.fromPosition(
                        TextPosition(offset: taxController.text.length),
                      );
                    } else if (value.contains('-') || taxValue < 0) {
                      // Additional checks for negative values or invalid numbers
                      taxController.clear();
                      taxController.selection = TextSelection.fromPosition(
                        TextPosition(offset: taxController.text.length),
                      );
                    }
                    if (taxValue > 100) {
                      taxController.text = '100';
                      taxController.selection = TextSelection.fromPosition(
                        TextPosition(offset: taxController.text.length),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: greyColor),
                )),
            TextButton(
                onPressed: () {
                  invoiceProvider.setTaxName(taxNameController.text);
                  var taxAmount = double.tryParse(taxController.text) ?? 0.0;
                  invoiceProvider.setTax(taxAmount);
                  Navigator.pop(context, taxAmount);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
