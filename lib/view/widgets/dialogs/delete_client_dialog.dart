import 'package:flutter/material.dart';
import 'package:invoicemaker/model/client_model.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:provider/provider.dart';

Future<void> deleteClientDialog(BuildContext context, Client client) async {
  showDialog(
      context: context,
      builder: (context) {
        //initialize item provider
        final clientProvider = Provider.of<ClientProvider>(context);

        return AlertDialog(
          title: const Text(
            'Delete Item',
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
                  clientProvider.removeClient(client);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: blueColor),
                )),
          ],
        );
      });
}
