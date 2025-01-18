import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/pdf_templates/templates.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:provider/provider.dart';

class TemplateSelectionScreen extends StatefulWidget {
  final Invoice invoice;
  final Uint8List signature;
  final bool fromPreviewBtn;

  const TemplateSelectionScreen(
      {super.key,
      required this.invoice,
      required this.signature,
      required this.fromPreviewBtn});

  @override
  // ignore: library_private_types_in_public_api
  _TemplateSelectionScreenState createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  int _currentTemplateIndex = 0;
  final templates = InvoiceTemplate.values;

  @override
  Widget build(BuildContext context) {
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Create an updated invoice with the selected template
              final updatedInvoice = widget.invoice.copyWith(
                template: templates[_currentTemplateIndex],
              );

              // Update the InvoiceProvider with the updated invoice
              invoiceProvider.updateInvoice(updatedInvoice);

              // Close the TemplateSelectionScreen and return the updated invoice
              if (widget.fromPreviewBtn) {
                Navigator.pop(context, templates[_currentTemplateIndex]);
                print(_currentTemplateIndex);
              } else {
                Navigator.pop(context, updatedInvoice);
              }
            },
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: Container(
        color: greyColor,
        child: CarouselSlider.builder(
          itemCount: templates.length,
          itemBuilder: (context, index, realIdx) {
            return getInvoiceTemplateWidget(
              template: templates[index],
              signature: widget.signature,
              invoice: widget.invoice,
              action: 'preview',
            );
          },
          options: CarouselOptions(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            enableInfiniteScroll: false,
            animateToClosest: true,
            viewportFraction: 0.9,
            enlargeFactor: 0.22,
            height: MediaQuery.of(context).size.height * 1,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              _currentTemplateIndex = index;
            },
          ),
        ),
      ),
    );
  }
}
