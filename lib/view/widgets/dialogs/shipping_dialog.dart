import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

Future<dynamic> shippingDialog(BuildContext context) async {
  var shippingController = TextEditingController();
  var width = MediaQuery.of(context).size.width * 1;
  showDialog(
      context: context,
      builder: (context) {
        //initialize invoice provider
        final invoiceProvider = Provider.of<InvoiceProvider>(context);
        shippingController.text = invoiceProvider.invoice.shippingCharges == 0
            ? ""
            : invoiceProvider.invoice.shippingCharges.toString();

        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'Shipping',
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Shipping Amount',
                style:
                    TextStyle(fontSize: 14, color: darkGreyColor, height: 2.1),
              ),
              SizedBox(
                width: width * 0.8,
                child: CustomTextField(
                  controller: shippingController,
                  hintText: 'Rs0',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Check if the input contains only digits and at most one period (.)
                    final validInput = RegExp(r'^\d*\.?\d*$');

                    // If the input is invalid or contains anything other than numbers or '.'
                    if (!validInput.hasMatch(value)) {
                      shippingController.clear();
                      // Move the cursor to the end of the text
                      shippingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: shippingController.text.length),
                      );
                    } else if (value.contains('-') ||
                        double.tryParse(value) == null ||
                        double.parse(value) < 0) {
                      // Additional checks for negative values or invalid numbers
                      shippingController.clear();
                      shippingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: shippingController.text.length),
                      );
                    }
                  },
                ),
              ),
            ],
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
                  var shippingAmount =
                      double.tryParse(shippingController.text) ?? 0.0;
                  invoiceProvider.setShippingCharges(shippingAmount);
                  Navigator.pop(context, shippingAmount);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
