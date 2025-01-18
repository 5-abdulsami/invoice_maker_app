import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoicemaker/model/invoice_model.dart';

abstract class BaseTemplate extends StatelessWidget {
  final Uint8List signature;
  final Invoice invoice;
  final String action;

  BaseTemplate({
    Key? key,
    required this.signature,
    required this.invoice,
    this.action = "preview",
  }) : super(key: key);

  // Abstract method for generating the PDF
  Future<Uint8List?> createPdf(BuildContext context, String action);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: createPdf(context, action),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else {
            return const Center(child: Text('No preview available'));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
