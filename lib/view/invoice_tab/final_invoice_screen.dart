import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/pdf_templates/abstract_base_class.dart';
import 'package:invoicemaker/pdf_templates/templates.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';
import 'package:invoicemaker/view/invoice_tab/invoice_tab.dart';
import 'package:invoicemaker/view/invoice_tab/new_invoice_screen.dart';
import 'package:invoicemaker/view/template_selection_screen/template_selection_screen.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/dialogs/delete_invoice_dialog.dart';
import 'package:invoicemaker/view/widgets/dialogs/invoice_status_dialog.dart';
import 'package:provider/provider.dart';

class FinalInvoiceScreen extends StatefulWidget {
  const FinalInvoiceScreen({super.key, required this.invoice});
  final Invoice invoice;

  @override
  _FinalInvoiceScreenState createState() => _FinalInvoiceScreenState();
}

class _FinalInvoiceScreenState extends State<FinalInvoiceScreen> {
  late BaseTemplate selectedTemplateWidget;
  late Invoice currentInvoice;

  @override
  void initState() {
    super.initState();
    //initialize the currentInvoice
    currentInvoice = widget.invoice;
    _updateTemplateWidget();
  }

  void _updateTemplateWidget() {
    final signatureProvider =
        Provider.of<SignatureProvider>(context, listen: false);
    final signature = signatureProvider.signature ?? transparentPixel;

    selectedTemplateWidget = getInvoiceTemplateWidget(
      template: currentInvoice.template,
      signature: signature,
      invoice: currentInvoice,
      action: 'preview',
    );

    print("TEMPLATE IN FINAL INVOICE SCREEN: $selectedTemplateWidget");
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    final signatureProvider =
        Provider.of<SignatureProvider>(context, listen: false);
    final signature = signatureProvider.signature ?? transparentPixel;

    //troublesome code
    currentInvoice = invoiceProvider.getInvoiceById(widget.invoice.id)!;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(currentInvoice.invoiceNumber),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewInvoiceScreen(
                              fromFinalInvoiceScreen: true,
                              invoiceId: currentInvoice.id,
                            )));
              },
              icon: const Icon(Icons.edit)),
          const SizedBox(width: 10),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InvoiceTab()));
              },
              icon: const Icon(Icons.home_outlined)),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.58,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: previewBgColor,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                child: Container(
                  decoration: const BoxDecoration(boxShadow: [
                    BoxShadow(
                        blurRadius: 6,
                        offset: Offset(0, 1),
                        color: darkGreyColor),
                  ]),
                  child: InkWell(
                    onTap: () async {
                      // Navigate to the TemplateSelectionScreen and await the result
                      final updatedInvoice = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateSelectionScreen(
                            invoice: currentInvoice,
                            signature: signature,
                            fromPreviewBtn: false,
                          ),
                        ),
                      );

                      // Check if an updated invoice was returned
                      if (updatedInvoice != null) {
                        // Update the invoice in the provider and in this screen
                        invoiceProvider.updateInvoice(updatedInvoice);
                        setState(() {
                          // set the currentInvoice template displayed to the updatedInvoice
                          currentInvoice = updatedInvoice;
                          _updateTemplateWidget(); // Update the template widget
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: selectedTemplateWidget,
                    ),
                  ),
                ),
              ),
            ),
            // Lower Container
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentInvoice.to.isEmpty
                            ? 'Unknown Client'
                            : currentInvoice.to,
                        style: const TextStyle(fontSize: 22),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          invoiceStatusDialog(context, currentInvoice);
                        },
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0),
                          backgroundColor: currentInvoice.status == "Unpaid"
                              ? const WidgetStatePropertyAll(
                                  buttonLightBlueColorr)
                              : currentInvoice.status == "Paid"
                                  ? const WidgetStatePropertyAll(
                                      buttonLightGreenColor)
                                  : const WidgetStatePropertyAll(
                                      buttonLightOrangeColor),
                          minimumSize:
                              const WidgetStatePropertyAll(Size(35, 32)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          currentInvoice.status,
                          style: TextStyle(
                              fontSize: 14,
                              color: currentInvoice.status == "Unpaid"
                                  ? lightBlueTextColor
                                  : currentInvoice.status == "Paid"
                                      ? lightGreenTextColor
                                      : lightOrangeTextColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs${currentInvoice.total.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Due on ${DateFormat('yMMMd').format(currentInvoice.dueDate)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 0.92,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3,
                          color: shadowColor,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            await selectedTemplateWidget.createPdf(
                                context, "share");
                          },
                          child: const Column(
                            children: [
                              Icon(
                                Icons.share_outlined,
                                color: darkBlueColor,
                                size: 35,
                              ),
                              Text(
                                'Share',
                                style: TextStyle(
                                    fontSize: 14, color: darkBlueColor),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await selectedTemplateWidget.createPdf(
                                context, "save");
                          },
                          child: const Column(
                            children: [
                              Icon(
                                Icons.save_alt_outlined,
                                color: darkBlueColor,
                                size: 35,
                              ),
                              Text(
                                'Save',
                                style: TextStyle(
                                    fontSize: 14, color: darkBlueColor),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await selectedTemplateWidget.createPdf(
                                context, "print");
                          },
                          child: const Column(
                            children: [
                              Icon(
                                Icons.print_outlined,
                                color: darkBlueColor,
                                size: 35,
                              ),
                              Text(
                                'Print',
                                style: TextStyle(
                                    fontSize: 14, color: darkBlueColor),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            deleteInvoiceDialog(context, currentInvoice,
                                fromInvoiceTab: false);
                          },
                          child: const Column(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: darkBlueColor,
                                size: 35,
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(
                                    fontSize: 14, color: darkBlueColor),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
