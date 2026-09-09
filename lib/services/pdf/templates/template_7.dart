import 'package:intl/intl.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/utils/pdf_asset_loader.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/services/pdf/templates/base_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Template 7 - the "Elegant" invoice layout.
class Template7 extends BaseTemplate {
  const Template7();

  @override
  InvoiceTemplate get id => InvoiceTemplate.template7;

  @override
  Future<pw.Document> buildDocument(InvoiceDocumentData data) async {
    final invoice = data.invoice;
    final business = data.business;
    final client = data.client;
    final currency = invoice.currency;
    final pdf = pw.Document();


    // Load images for the header, footer, and other sections
    final asset = pw.MemoryImage(PdfAssetLoader.transparentPixel);
    final signatureImage = pw.MemoryImage(data.signature);
    final businessLogo = data.businessLogo != null
        ? pw.MemoryImage(data.businessLogo!)
        : asset;

    // Build Header
    pw.Widget buildHeader(pw.Context context) {
      return pw.Container(
        decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [PdfColors.green900, PdfColors.green300],
        )),
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
                    pw.Text(business.phone,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(business.emailAddress,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(business.billingAddress,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 13)),
                    pw.Text(business.website,
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
        decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [PdfColors.green300, PdfColors.green900],
        )),
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
                    pw.Text(client.phone,
                        style: const pw.TextStyle(color: PdfColors.black)),
                    pw.Text(client.emailAddress,
                        style: const pw.TextStyle(color: PdfColors.black)),
                    pw.Text(client.billingAddress,
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
            child: buildTable(invoice.items, currency), // Pass the items here
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
                          '${currency.pdfSymbol}${invoice.subTotal.toStringAsFixed(0)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Discount :',
                          '${currency.pdfSymbol}${(invoice.subTotal * (invoice.discount / 100)).toStringAsFixed(0)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Tax :',
                          '${currency.pdfSymbol}${(invoice.subTotal * (invoice.tax / 100)).toStringAsFixed(0)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 10, left: 6, right: 6),
                      child: _buildTotalRow('Shipping :',
                          '${currency.pdfSymbol}${(invoice.shippingCharges).toStringAsFixed(0)}'),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(5),
                        color: PdfColors.green700,
                      ),
                      child: _buildTotalRow(
                          'Total :', '${currency.pdfSymbol}${invoice.total.toStringAsFixed(0)}',
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

    return pdf;
  }

  pw.Widget buildTable(List<Item> items, Currency currency) {
    final List<List<String>> tableData = items.map((item) {
      // item name
      final name = item.name;
      // item price
      final price = '${currency.pdfSymbol}${item.price.toStringAsFixed(0)}';
      // item quantity
      final quantity = item.quantity.toString();
      // item discount
      final discount = "${item.discount.toStringAsFixed(0)}%";
      // item tax
      final tax = "${item.tax.toStringAsFixed(0)}%";
      final amount =
          '${currency.pdfSymbol}${(item.subAmount).toStringAsFixed(0)}'; // Calculate subtotal
      return [name, price, quantity, discount, tax, amount];
    }).toList();

    return pw.TableHelper.fromTextArray(
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
      border: const pw.TableBorder(
          // horizontalInside: pw.BorderSide(
          //   color: PdfColors.blue900,
          // ),
          // bottom: pw.BorderSide(
          //   color: PdfColors.blue900,
          // ),
          ),
      headerStyle: pw.TextStyle(
        fontSize: 14,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.green700,
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
