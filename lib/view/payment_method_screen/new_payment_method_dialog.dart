import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/payment_method_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

Future<void> newPaymentMethodDialog(BuildContext context) async {
  var paymentController = TextEditingController();

  var width = MediaQuery.of(context).size.width * 1;
  showDialog(
      context: context,
      builder: (context) {
        //initialize invoice provider
        final paymentProvider =
            Provider.of<PaymentMethodProvider>(context, listen: false);

        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'New Payment Method',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: blueColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Payment Detail',
                  style: TextStyle(
                      fontSize: 12, color: darkGreyColor, height: 2.1),
                ),
                SizedBox(
                  width: width * 0.9,
                  child: CustomTextField(
                    minLines: 6,
                    maxLines: 12,
                    controller: paymentController,
                    hintText: '',
                  ),
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
                  paymentProvider.addPaymentMethod(paymentController.text);
                  Navigator.pop(context);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
  paymentController.dispose();
}
