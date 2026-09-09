import 'package:intl/intl.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/item.dart';
import 'package:invoicemaker/services/pdf/templates/base_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Template 1 - the "Classic" invoice layout.
class Template1 extends BaseTemplate {
  const Template1();

  @override
  InvoiceTemplate get id => InvoiceTemplate.template1;

  @override
  Future<pw.Document> buildDocument(InvoiceDocumentData data) async {
    final invoice = data.invoice;
    final business = data.business;
    final client = data.client;
    final currency = invoice.currency;
    final pdf = pw.Document();


    final signatureImage = pw.MemoryImage(data.signature);
    // Page Theme
    const pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      margin: pw.EdgeInsets.all(20),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
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
                pw.Container(
                  width: 210,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('INVOICE #: ',
                                style: pw.TextStyle(
                                    letterSpacing: 0.8,
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('CREATION DATE: ',
                                style: pw.TextStyle(
                                    letterSpacing: 0.8,
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('DUE DATE: ',
                                style: pw.TextStyle(
                                    letterSpacing: 0.8,
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold)),
                          ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(invoice.invoiceNumber,
                                style:
                                    const pw.TextStyle(color: PdfColors.black)),
                            pw.Text(
                                DateFormat('yMMMd')
                                    .format(invoice.creationDate),
                                style:
                                    const pw.TextStyle(color: PdfColors.black)),
                            pw.Text(DateFormat('yMMMd').format(invoice.dueDate),
                                style:
                                    const pw.TextStyle(color: PdfColors.black)),
                          ]),
                    ],
                  ),
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
                    pw.Text(invoice.from),
                    pw.Text(business.phone),
                    pw.Text(business.emailAddress),
                    pw.Text(business.billingAddress),
                    pw.Text(business.website),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BILL TO',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text(invoice.to),
                    pw.Text(client.phone),
                    pw.Text(client.emailAddress),
                    pw.Text(client.billingAddress),
                  ],
                ),
                pw.SizedBox(width: 30),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 30, right: 30),
            child: buildTable(invoice.items, currency), // Pass the items here
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
                        color: PdfColors.red800,
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
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColors.red800),
        bottom: pw.BorderSide(color: PdfColors.red800),
      ),
      headerStyle: pw.TextStyle(
        fontSize: 12,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.red800,
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
