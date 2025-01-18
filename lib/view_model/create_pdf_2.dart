import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/payment_method_provider.dart';
import 'package:invoicemaker/utils/pdf_assets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as px;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:printing/printing.dart';

Future<Uint8List?> createPdf2(
    Uint8List signature, BuildContext context, Invoice invoice,
    {String action = "preview"}) async {
  // Initialize providers
  final clientProvider = Provider.of<ClientProvider>(context, listen: false);
  final businessProvider =
      Provider.of<BusinessProvider>(context, listen: false);
  final pdf = pw.Document();

  // Load images for the header, footer, and other sections
  final asset = pw.MemoryImage(assetImage!);

  final signatureImage = pw.MemoryImage(signature);

  //convert business logo file to Uint8List Bytes
  Uint8List? businessLogoBytes;
  if (businessProvider.business.businessLogo != null) {
    businessLogoBytes =
        await businessProvider.business.businessLogo!.readAsBytes();
  }

  final businessLogo =
      businessLogoBytes != null ? pw.MemoryImage(businessLogoBytes) : asset;

  // Header
  // pw.Widget buildHeader(pw.Context context) {
  //   return pw.Column(
  //     children: [
  //       pw.Container(
  //         width: context.page.pageFormat.width,
  //         child: pw.Image(
  //           topImageProvider,
  //           width: context.page.pageFormat.width,
  //           height: context.page.pageFormat.height * 0.2,
  //           fit: pw.BoxFit.contain,
  //         ),
  //       ),
  //       pw.SizedBox(height: 30),
  //     ],
  //   );
  // }

  // // Footer
  // pw.Widget buildFooter(pw.Context context) {
  //   return pw.Column(
  //     children: [
  //       pw.SizedBox(height: 20),
  //       pw.Container(
  //         width: context.page.pageFormat.width,
  //         child: pw.Image(
  //           bottomImageProvider,
  //           width: context.page.pageFormat.width,
  //           height: context.page.pageFormat.height * 0.2,
  //           fit: pw.BoxFit.contain,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Page Theme
  const pageTheme = pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    orientation: pw.PageOrientation.portrait,
    margin: pw.EdgeInsets.all(20),
  );

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      // header: (context) => buildHeader(context),
      // footer: (context) => buildFooter(context),
      build: (context) => [
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 30, right: 30),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 20),
                child: pw.Text('INVOICE',
                    style: pw.TextStyle(
                        fontSize: 45, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: 'INVOICE #                 ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: invoice.invoiceNumber),
                    ],
                  )),
                  pw.RichText(
                      text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: 'CREATION DATE:            ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(
                          text:
                              DateFormat('yMMMd').format(invoice.creationDate)),
                    ],
                  )),
                  pw.RichText(
                      text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                          text: 'DUE DATE:            ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(
                          text: DateFormat('yMMMd').format(invoice.dueDate)),
                    ],
                  )),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 40),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 30, right: 30),
          child: pw.Divider(),
        ),

        pw.SizedBox(height: 10),

        // From To Section
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 30, right: 30),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FROM',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text(
                    invoice.from,
                  ),
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
                  pw.Text(
                    invoice.to,
                  ),
                  pw.Text(clientProvider.client.phone),
                  pw.Text(clientProvider.client.emailAddress),
                  pw.Text(clientProvider.client.billingAddress),
                  pw.Text(clientProvider.client.emailAddress),
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
                  _buildTotalRow('Sub-total      :       ',
                      'Rs${invoice.subTotal.toStringAsFixed(0)}   '),
                  pw.SizedBox(height: 10),
                  _buildTotalRow('Discount       :         ',
                      'Rs${(invoice.subTotal * (invoice.discount / 100)).toStringAsFixed(0)}   '),
                  pw.SizedBox(height: 10),
                  _buildTotalRow('Tax           :       ',
                      'Rs${(invoice.subTotal * (invoice.tax / 100)).toStringAsFixed(0)}   '),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(5),
                      color: PdfColors.red800,
                    ),
                    child: _buildTotalRow('Total            :       ',
                        'Rs${invoice.total.toStringAsFixed(0)}',
                        isBold: true, color: PdfColors.white),
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
  } else if (action == "print") {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    return null;
  } else {
    return null;
  }
  return null;
}

pw.Widget buildTable(List<Item> items) {
  final List<List<String>> tableData = items.map((item) {
    final name = item.name; // Replace with the correct property name
    final price =
        'Rs${item.price.toStringAsFixed(0)}'; // Format price as needed
    final quantity =
        item.quantity.toString(); // Replace with the correct property name
    final amount =
        'Rs${(item.subAmount).toStringAsFixed(0)}'; // Calculate subtotal
    return [name, price, quantity, amount];
  }).toList();

  return pw.TableHelper.fromTextArray(
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: PdfColors.red800),
      // verticalInside: pw.BorderSide(color: PdfColors.red800),
      // left: pw.BorderSide(color: PdfColors.red800),
      // right: pw.BorderSide(color: PdfColors.red800),
      bottom: pw.BorderSide(color: PdfColors.red800),
    ),
    headerStyle: pw.TextStyle(
      fontSize: 14,
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
    headerDecoration: const pw.BoxDecoration(
      color: PdfColors.red800,
    ),
    headers: ['ITEM', 'PRICE', 'QTY', 'AMOUNT'],
    data: tableData,
    headerAlignments: {
      0: pw.Alignment.center,
      1: pw.Alignment.center,
      2: pw.Alignment.center,
      3: pw.Alignment.center,
    },
    cellAlignments: {
      0: pw.Alignment.center,
      1: pw.Alignment.center,
      2: pw.Alignment.center,
      3: pw.Alignment.center,
    },
    cellPadding: const pw.EdgeInsets.all(12),
    columnWidths: {
      0: const pw.FlexColumnWidth(4),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(2),
      3: const pw.FlexColumnWidth(3),
    },
  );
}

pw.Widget _buildTotalRow(String label, String value,
    {bool isBold = false, PdfColor? color}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    ],
  );
}
