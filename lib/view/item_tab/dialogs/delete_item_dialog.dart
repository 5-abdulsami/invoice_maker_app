import 'package:flutter/material.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:provider/provider.dart';

Future<void> deleteItemDialog(BuildContext context, Item item) async {
  showDialog(
      context: context,
      builder: (context) {
        //initialize item provider
        final itemProvider = Provider.of<ItemProvider>(context);

        return AlertDialog(
          backgroundColor: whiteColor,
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
                  itemProvider.removeItem(item);
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
