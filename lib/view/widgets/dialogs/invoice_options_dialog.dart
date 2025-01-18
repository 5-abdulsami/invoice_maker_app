import 'package:flutter/material.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/pdf_templates/template_1.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';
import 'package:invoicemaker/view/widgets/dialogs/delete_invoice_dialog.dart';
import 'package:provider/provider.dart';

Future<void> invoiceOptionsDialog(BuildContext context, Invoice invoice) async {
  showDialog(
      context: context,
      builder: (context) {
        final signatureProvider = Provider.of<SignatureProvider>(context);
        final signature = signatureProvider.signature ?? transparentPixel;
        return AlertDialog(
          backgroundColor: whiteColor,
          title: Text(
            invoice.invoiceNumber,
            style: const TextStyle(
                color: blueColor, height: 2, fontWeight: FontWeight.bold),
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () async {
                    await Template1(
                      signature: signature,
                      invoice: invoice,
                      action: "share",
                    ).createPdf(context, "share");
                  },
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share'),
                ),
                ListTile(
                  onTap: () {
                    deleteInvoiceDialog(context, invoice);
                  },
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete'),
                ),
                ListTile(
                  onTap: () async {
                    await Template1(
                      signature: signature,
                      invoice: invoice,
                      action: "email",
                    ).createPdf(context, "email");
                  },
                  leading: const Icon(Icons.send_outlined),
                  title: const Text('Send Email'),
                ),
                ListTile(
                  onTap: () async {
                    await Template1(
                      signature: signature,
                      invoice: invoice,
                      action: "print",
                    ).createPdf(context, "print");
                  },
                  leading: const Icon(Icons.print_outlined),
                  title: const Text('Print'),
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
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
