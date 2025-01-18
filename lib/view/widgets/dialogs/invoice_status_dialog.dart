import 'package:flutter/material.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

Future<void> invoiceStatusDialog(BuildContext context, Invoice invoice) async {
  final paidAmountController = TextEditingController();
  Color helperTextColor = Colors.black;
  String? selectedStatus = invoice.status; // Use the passed invoice's status

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: whiteColor,
            title: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Mark as',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blueColor),
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...['Unpaid', 'Paid', 'Partially Paid'].map((status) {
                    return ListTile(
                      tileColor: selectedStatus == status
                          ? blueColor.withOpacity(0.1)
                          : null,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      title: Text(status),
                      trailing: selectedStatus == status
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedStatus = status;
                          if (status == 'Partially Paid') {
                            paidAmountController.text = '';
                            helperTextColor = Colors.black;
                          } else {
                            paidAmountController.text = '';
                            helperTextColor = Colors.black;
                          }
                        });
                      },
                    );
                  }),
                  if (selectedStatus == 'Partially Paid')
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomTextField(
                        controller: paidAmountController,
                        hintText: 'Rs0',
                        helperText:
                            'Must be less than the invoice total amount and not be 0',
                        helperTextColor: helperTextColor,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          double paidValue = double.tryParse(value) ?? 0.0;
                          // Check if the input contains only digits and at most one period (.)
                          final validInput = RegExp(r'^\d*\.?\d*$');

                          // If the input is invalid or contains anything other than numbers or '.'
                          if (!validInput.hasMatch(value)) {
                            paidAmountController.clear();
                            // Move the cursor to the end of the text
                            paidAmountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: paidAmountController.text.length),
                            );
                          } else if (value.contains('-') || paidValue < 0) {
                            // Additional checks for negative values or invalid numbers
                            paidAmountController.text = '0';
                            paidAmountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: paidAmountController.text.length),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: greyColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  final invoiceProvider = context.read<InvoiceProvider>();

                  if (selectedStatus != null) {
                    if (selectedStatus == 'Partially Paid') {
                      final paidAmount =
                          double.tryParse(paidAmountController.text) ?? 0.0;

                      // Validate paidAmount
                      if (paidAmount <= 0 || paidAmount > invoice.total) {
                        setState(() {
                          helperTextColor =
                              Colors.red; // Update helper text color to red
                        });
                        return; // Don't close the dialog or set the paid amount
                      }

                      // Set the paid amount for the specific invoice
                      final updatedInvoice = invoice.copyWith(
                        paidAmount: paidAmount,
                      );
                      invoiceProvider.updateInvoice(updatedInvoice);
                    }

                    // Set the status for the specific invoice
                    final updatedInvoice = invoice.copyWith(
                      status: selectedStatus!,
                    );
                    invoiceProvider.updateInvoice(updatedInvoice);

                    Navigator.of(context)
                        .pop(); // Dismiss the dialog after saving
                  }
                },
                child: const Text(
                  'CHANGE',
                  style: TextStyle(color: blueColor),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
