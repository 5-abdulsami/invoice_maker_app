import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/pdf_templates/abstract_base_class.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as px;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:printing/printing.dart';

class Template2 extends BaseTemplate {
  Template2({
    super.key,
    required super.signature,
    required super.invoice,
    super.action,
  });

  @override
  Future<Uint8List?> createPdf(BuildContext context, String action) async {
    // Initialize providers
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);
    final pdf = pw.Document();

    // Load images for the header, footer, and other sections
    final signatureImage = pw.MemoryImage(signature);

    pw.Widget buildHeader(pw.Context context) {
      return pw.Container(
        color: PdfColors.blue700,
        width: context.page.pageFormat.width,
        height: context.page.pageFormat.height * 0.2,
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 30, right: 30),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('INVOICE',
                  style: pw.TextStyle(
                      fontSize: 49,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white)),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: 'INVOICE #                 ',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                      pw.TextSpan(
                          text: invoice.invoiceNumber,
                          style: const pw.TextStyle(color: PdfColors.white)),
                    ],
                  )),
                  pw.RichText(
                      text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: 'CREATION DATE:            ',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                      pw.TextSpan(
                          text:
                              DateFormat('yMMMd').format(invoice.creationDate),
                          style: const pw.TextStyle(color: PdfColors.white)),
                    ],
                  )),
                  pw.RichText(
                      text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: 'DUE DATE:            ',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                      pw.TextSpan(
                          text: DateFormat('yMMMd').format(invoice.dueDate),
                          style: const pw.TextStyle(color: PdfColors.white)),
                    ],
                  )),
                ],
              ),
            ],
          ),
        ),
      );
    }

    pw.Widget buildFooter(pw.Context context) {
      return pw.Column(
        children: [
          pw.SizedBox(height: 20),
          pw.Container(
            width: context.page.pageFormat.width,
            child: pw.Container(
              color: PdfColors.blue700,
              width: context.page.pageFormat.width,
              height: context.page.pageFormat.height * 0.05,
            ),
          ),
        ],
      );
    }

    // Page Theme
    const pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      margin: pw.EdgeInsets.all(0),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (context) => buildHeader(context),
        footer: (context) => buildFooter(context),
        build: (context) => [
          // From To Section
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20, left: 30, right: 30),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('FROM',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text(invoice.from),
                    pw.Text(businessProvider.business.phone),
                    pw.Text(businessProvider.business.emailAddress),
                    pw.Text(businessProvider.business.billingAddress),
                    pw.Text(businessProvider.business.website),
                  ],
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BILL TO',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text(invoice.to),
                    pw.Text(clientProvider.client.phone),
                    pw.Text(clientProvider.client.emailAddress),
                    pw.Text(clientProvider.client.billingAddress),
                    pw.Text(clientProvider.client.shippingAddress),
                  ],
                ),
                pw.SizedBox(width: 30),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 30, right: 30),
            child: buildTable(invoice.items), // Pass the items here
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 30, right: 30),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text('PAYMENT METHOD',
                        textAlign: pw.TextAlign.start,
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text(invoice.paymentMethod),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Sub-total :',
                          'Rs${invoice.subTotal.toStringAsFixed(0)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Discount :',
                          'Rs${(invoice.subTotal * (invoice.discount / 100)).toStringAsFixed(0)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Tax :',
                          'Rs${(invoice.subTotal * (invoice.tax / 100)).toStringAsFixed(0)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Shipping :',
                          'Rs${(invoice.shippingCharges).toStringAsFixed(0)}'),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(5),
                        color: PdfColors.blue700,
                      ),
                      child: _buildTotalRow(
                          'Total :', 'Rs${invoice.total.toStringAsFixed(0)}',
                          isBold: true, color: PdfColors.white, fontSize: 19),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 30, right: 30),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TERMS & CONDITIONS',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(invoice.terms),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(signatureImage, width: 45, height: 40),
                    pw.Container(
                      width: 100,
                      child: pw.Divider(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${invoice.invoiceNumber}.pdf");
    await file.writeAsBytes(await pdf.save());

    if (action == "preview") {
      final document = await px.PdfDocument.openFile(file.path);
      final page = await document.getPage(1);
      final screenshot = await page.render(
        width: page.width,
        height: page.height,
        format: px.PdfPageImageFormat.jpeg,
      );
      return screenshot?.bytes;
    } else if (action == "save") {
      await OpenFile.open(file.path);
      return null;
    } else if (action == "share") {
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice');
      return null;
    } else if (action == "email") {
      final email = Email(
        body: 'Here is your Invoice',
        subject: 'Invoice',
        attachmentPaths: [file.path],
        isHTML: false,
      );

      // Launch the email client with the email URI
      await FlutterEmailSender.send(email);
      return null;
    } else if (action == "print") {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      return null;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: createPdf(context, "preview"),
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

  pw.Widget buildTable(List<Item> items) {
    final List<List<String>> tableData = items.map((item) {
      // item name
      final name = item.name;
      // item price
      final price = 'Rs${item.price.toStringAsFixed(0)}';
      // item quantity
      final quantity = item.quantity.toString();
      // item discount
      final discount = "${item.discount.toStringAsFixed(0)}%";
      // item tax
      final tax = "${item.tax.toStringAsFixed(0)}%";
      final amount =
          'Rs${(item.subAmount).toStringAsFixed(0)}'; // Calculate subtotal
      return [name, price, quantity, discount, tax, amount];
    }).toList();

    return pw.TableHelper.fromTextArray(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: PdfColors.blue700,
        ),
        bottom: pw.BorderSide(
          color: PdfColors.blue700,
        ),
      ),
      headerStyle: pw.TextStyle(
        fontSize: 14,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blue700,
      ),
      headers: ['ITEM', 'PRICE', 'QTY', 'DISCOUNT', 'TAX', 'AMOUNT'],
      data: tableData,
      headerAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.all(12),
      columnWidths: {
        0: const pw.FlexColumnWidth(3.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(3),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(3),
      },
    );
  }

  pw.Widget _buildTotalRow(String label, String value,
      {bool isBold = false, PdfColor? color, double fontSize = 14}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
              fontSize: fontSize),
        ),
        pw.SizedBox(width: 30),
        pw.Text(
          value,
          style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
              fontSize: fontSize),
        ),
      ],
    );
  }
}
