import 'package:flutter/material.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/dashboard_screen/dashboard_screen.dart';
import 'package:provider/provider.dart';

Future<void> deleteInvoiceDialog(BuildContext context, Invoice invoice,
    {bool fromInvoiceTab = false}) async {
  showDialog(
      context: context,
      builder: (context) {
        //initialize item provider
        final invoiceProvider = Provider.of<InvoiceProvider>(context);

        return AlertDialog(
          backgroundColor: whiteColor,
          title: const Text(
            'Delete Invoice',
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
                  invoiceProvider.removeInvoice(invoice);
                  if (fromInvoiceTab) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardScreen()));
                  }
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
