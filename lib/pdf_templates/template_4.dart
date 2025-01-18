import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/pdf_templates/abstract_base_class.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as px;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:printing/printing.dart';

class Template4 extends BaseTemplate {
  Template4({
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
    final asset = pw.MemoryImage(transparentPixel);
    final signatureImage = pw.MemoryImage(signature);

    // Convert business logo file to Uint8List Bytes
    Uint8List? businessLogoBytes;
    if (businessProvider.business.businessLogo != null) {
      businessLogoBytes =
          await businessProvider.business.businessLogo!.readAsBytes();
    }

    final businessLogo =
        businessLogoBytes != null ? pw.MemoryImage(businessLogoBytes) : asset;

    // Build Header
    pw.Widget buildHeader(pw.Context context) {
      return pw.Container(
        color: PdfColors.black,
        padding: const pw.EdgeInsets.all(40),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                businessLogo == asset
                    ? pw.Container()
                    : pw.Image(businessLogo, width: 50, height: 50),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 10),
                    pw.Text(invoice.from,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(businessProvider.business.phone,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(businessProvider.business.emailAddress,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(businessProvider.business.billingAddress,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(businessProvider.business.website,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                  ],
                ),
              ],
            ),
            pw.Text('INVOICE',
                style: pw.TextStyle(
                    fontSize: 43,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white)),
          ],
        ),
      );
    }

    // Build Footer
    pw.Widget buildFooter(pw.Context context) {
      return pw.Container(
        color: PdfColors.black,
        padding: const pw.EdgeInsets.all(10),
        child: pw.Center(
          child: pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          ),
        ),
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
          pw.Padding(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Bill To:',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                    pw.Text(invoice.to,
                        style: const pw.TextStyle(color: PdfColors.black)),
                    pw.Text(clientProvider.client.phone,
                        style: const pw.TextStyle(color: PdfColors.black)),
                    pw.Text(clientProvider.client.emailAddress,
                        style: const pw.TextStyle(color: PdfColors.black)),
                    pw.Text(clientProvider.client.billingAddress,
                        style: const pw.TextStyle(color: PdfColors.black)),
                  ],
                ),
                pw.Container(
                  child: pw.Row(
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Invoice Number: ',
                                style: pw.TextStyle(
                                    letterSpacing: 0.8,
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 15)),
                            pw.Text('Creation Date: ',
                                style: pw.TextStyle(
                                    letterSpacing: 0.8,
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 15)),
                            pw.Text('Due Date: ',
                                style: pw.TextStyle(
                                    letterSpacing: 0.8,
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 15)),
                          ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(invoice.invoiceNumber,
                                style: const pw.TextStyle(
                                    color: PdfColors.black, fontSize: 15)),
                            pw.Text(
                                DateFormat('yMMMd')
                                    .format(invoice.creationDate),
                                style: const pw.TextStyle(
                                    color: PdfColors.black, fontSize: 15)),
                            pw.Text(DateFormat('yMMMd').format(invoice.dueDate),
                                style: const pw.TextStyle(
                                    color: PdfColors.black, fontSize: 15)),
                          ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: buildTable(invoice.items), // Pass the items here
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Payment Method:',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                    pw.Text(invoice.paymentMethod,
                        style: const pw.TextStyle(color: PdfColors.black)),
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
                        color: PdfColors.black,
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
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Terms & Conditions',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                    pw.Text(invoice.terms,
                        style: const pw.TextStyle(color: PdfColors.black)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(signatureImage, width: 45, height: 40),
                    pw.Container(
                        width: 100, child: pw.Divider(color: PdfColors.black)),
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
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      border: const pw.TableBorder(),
      headerStyle: pw.TextStyle(
        fontSize: 14,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.black,
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
