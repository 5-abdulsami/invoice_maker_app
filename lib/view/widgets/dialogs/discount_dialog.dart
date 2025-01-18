import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

Future<dynamic> discountDialog(BuildContext context) async {
  var discountController = TextEditingController();
  var width = MediaQuery.of(context).size.width * 1;

  //initialize invoice Provider

  showDialog(
      context: context,
      builder: (context) {
        final invoiceProvider = Provider.of<InvoiceProvider>(context);
        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'Discount',
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
          ),
          content: SizedBox(
            width: width * 0.8,
            child: CustomTextField(
              controller: discountController,
              hintText: '0%',
              suffixIcon: const Icon(Icons.arrow_drop_down),
              suffixText: 'Percentage',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                double discountValue = double.tryParse(value) ?? 0.0;
                // Check if the input contains only digits and at most one period (.)
                final validInput = RegExp(r'^\d*\.?\d*$');

                // If the input is invalid or contains anything other than numbers or '.'
                if (!validInput.hasMatch(value)) {
                  discountController.clear();
                  // Move the cursor to the end of the text
                  discountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: discountController.text.length),
                  );
                } else if (value.contains('-') || discountValue < 0) {
                  // Additional checks for negative values or invalid numbers
                  discountController.clear();
                  discountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: discountController.text.length),
                  );
                }
                if (discountValue > 100) {
                  discountController.text = '100';
                  discountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: discountController.text.length),
                  );
                }
              },
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
                  var discountAmount =
                      double.tryParse(discountController.text) ?? 0.0;
                  invoiceProvider.setDiscount(discountAmount);
                  Navigator.pop(context, discountAmount);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
