import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/payment_method_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:provider/provider.dart';

Future<void> deletePaymentMethodDialog(BuildContext context, int index) async {
  showDialog(
      context: context,
      builder: (context) {
        //initialize invoice provider
        final paymentProvider = Provider.of<PaymentMethodProvider>(context);

        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'Delete Payment Method',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: blueColor),
          ),
          content: const Text(
            'Are you sure to delete your selection?',
            style: TextStyle(fontSize: 17),
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
                  paymentProvider.removePaymentMethod(index);
                  Navigator.pop(context);
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
