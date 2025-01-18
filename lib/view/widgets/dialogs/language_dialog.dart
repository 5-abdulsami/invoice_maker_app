import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';

Future<void> languageDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => const AlertDialog(
      title: Text(
        'Invoice Language',
        textAlign: TextAlign.start,
        style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
      ),
      content: Column(
        children: [],
      ),
    ),
  );
}
