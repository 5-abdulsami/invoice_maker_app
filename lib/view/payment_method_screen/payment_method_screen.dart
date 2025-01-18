import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/payment_method_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/payment_method_screen/delete_payment_method_dialog.dart';
import 'package:invoicemaker/view/payment_method_screen/edit_payment_method_dialog.dart';
import 'package:provider/provider.dart';
import 'new_payment_method_dialog.dart'; // Import the dialog

class PaymentMethodScreen extends StatelessWidget {
  final bool fromSettings;
  const PaymentMethodScreen({super.key, this.fromSettings = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        actions: [
          IconButton(
              onPressed: () {
                if (fromSettings) {
                  // if coming from settings screen, simply pop the context
                  Navigator.pop(context);
                } else {
                  //initialize payment provider
                  final paymentProvider = Provider.of<PaymentMethodProvider>(
                      context,
                      listen: false);

                  //if the list is empty and check is pressed, simply pop
                  if (paymentProvider.paymentMethods.isEmpty) {
                    Navigator.pop(context);
                  } else {
                    // Set the selected payment method
                    final selectedPaymentMethod =
                        paymentProvider.getSelectedPaymentMethod();

                    if (selectedPaymentMethod != null) {
                      Navigator.pop(context, selectedPaymentMethod);
                    } else {
                      // If the user didn't select any payment method and tapped the check icon
                      if (paymentProvider.paymentMethods.isNotEmpty) {
                        // Prompt the user to select a payment method
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select a payment method before proceeding.')),
                        );
                      } else {
                        // If no payment methods are available, just pop the screen
                        Navigator.pop(context);
                      }
                    }
                  }
                }
              },
              icon: const Icon(Icons.check)),
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
                      'New Payment Method',
                      style: TextStyle(
                          fontSize: 20,
                          color: darkBlueColor,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      // Show the payment method dialog
                      newPaymentMethodDialog(context);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Payment Method List',
              style: TextStyle(
                  fontSize: 16,
                  color: darkBlueColor,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Consumer<PaymentMethodProvider>(
              builder: (context, paymentProvider, child) {
                final paymentMethods = paymentProvider.paymentMethods;

                if (paymentMethods.isEmpty) {
                  return Container(); // Return an empty container if no payment methods
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final paymentMethod = paymentMethods[index];
                      return Card(
                        color: whiteColor,
                        elevation: 3,
                        child: Center(
                          child: fromSettings
                              ? ListTile(
                                  title: Text(paymentMethod.details),
                                  trailing: PopupMenuButton<String>(
                                    position: PopupMenuPosition.under,
                                    color: whiteColor,
                                    onSelected: (String result) {
                                      if (result == 'edit') {
                                        editPaymentMethodDialog(context, index);
                                      } else if (result == 'delete') {
                                        deletePaymentMethodDialog(
                                            context, index);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: blackColor),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: blackColor),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                  // Add additional options or actions if needed
                                )
                              : ListTile(
                                  leading: IconButton(
                                    onPressed: () {
                                      paymentProvider
                                          .togglePaymentMethodSelection(index);
                                    },
                                    icon: Icon(
                                      paymentMethod.isSelected!
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: paymentMethod.isSelected!
                                          ? blueColor
                                          : null,
                                    ),
                                  ),
                                  title: Text(paymentMethod.details),
                                  trailing: IconButton(
                                      onPressed: () {
                                        editPaymentMethodDialog(context, index);
                                      },
                                      icon: const Icon(Icons.edit_outlined))
                                  // Add additional options or actions if needed
                                  ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
