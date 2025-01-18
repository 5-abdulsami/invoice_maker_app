import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

Future<void> termsDialog(BuildContext context) async {
  var termsController = TextEditingController();
  var width = MediaQuery.of(context).size.width * 1;
  showDialog(
      context: context,
      builder: (context) {
        //initialize invoice provider
        final invoiceProvider = Provider.of<InvoiceProvider>(context);

        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'New Terms & Conditions',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: blueColor, height: 2),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Terms & Conditions Detail',
                  style: TextStyle(
                      fontSize: 14, color: darkGreyColor, height: 2.1),
                ),
                SizedBox(
                  width: width * 0.8,
                  child: CustomTextField(
                    minLines: 6,
                    controller: termsController,
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
                  invoiceProvider.setTerms(termsController.text);
                  Navigator.pop(context);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
