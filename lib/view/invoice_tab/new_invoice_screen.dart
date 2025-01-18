import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/model/item_model.dart';
import 'package:invoicemaker/pdf_templates/templates.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';
import 'package:invoicemaker/view/buisness_info_screen/business_info_screen.dart';
import 'package:invoicemaker/view/client_tab/new_client_screen.dart';
import 'package:invoicemaker/view/invoice_tab/add_client_screen.dart';
import 'package:invoicemaker/view/invoice_tab/final_invoice_screen.dart';
import 'package:invoicemaker/view/invoice_tab/invoice_info_screen.dart';
import 'package:invoicemaker/view/invoice_tab/widgets/new_invoice_cards.dart';
import 'package:invoicemaker/view/template_selection_screen/template_selection_screen.dart';
import 'package:invoicemaker/view/widgets/dialogs/terms_dialog.dart';
import 'package:invoicemaker/view/payment_method_screen/payment_method_screen.dart';
import 'package:invoicemaker/view/widgets/buttons/preview_button.dart';
import 'package:invoicemaker/view/widgets/buttons/save_button.dart';
import 'package:invoicemaker/view_model/capture_signature.dart';
import 'package:provider/provider.dart';

class NewInvoiceScreen extends StatefulWidget {
  final bool fromFinalInvoiceScreen; // Determines if creating or editing
  final String? invoiceId; // Optional, for editing purposes

  const NewInvoiceScreen({
    super.key,
    required this.fromFinalInvoiceScreen,
    this.invoiceId, // Will be passed if editing
  });

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  String? selectedPaymentMethodDetails;
  List<Item> items = []; // Items list for the invoice
  double? total;
  InvoiceTemplate? selectedTemplate;

  @override
  Widget build(BuildContext context) {
    // Initialize providers
    final signatureProvider = Provider.of<SignatureProvider>(context);
    Uint8List? signatureImage = signatureProvider.signature;

    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    Invoice invoice = invoiceProvider.invoice;

    // If editing, fetch the invoice based on the provided ID
    if (widget.fromFinalInvoiceScreen && widget.invoiceId != null) {
      invoice = invoiceProvider.getInvoiceById(widget.invoiceId!) ?? invoice;
    }

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.fromFinalInvoiceScreen ? 'Edit Invoice' : 'New Invoice'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  infoCard(
                    context,
                    invoice.invoiceNumber,
                    invoice.creationDate,
                    invoice.dueDate,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InvoiceInfoScreen(invoice: invoice),
                        ),
                      );
                    },
                  ),
                  langTempCard(context),
                  fromToCard(
                    context,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusinessInfoScreen(),
                        ),
                      );
                    },
                    clientProvider.clients.isEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewClientScreen(
                                  fromAddClientScreen: false,
                                ),
                              ),
                            );
                          }
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddClientScreen(),
                              ),
                            );
                          },
                  ),
                  itemsCard(
                    context,
                    (double calculatedTotal) {
                      total = calculatedTotal;
                    },
                  ),
                  Card(
                    color: whiteColor,
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.money, color: darkBlueColor),
                            title: const Text('Currency',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            trailing: const SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('PKR Rs',
                                      style: TextStyle(
                                          color: darkBlueColor, fontSize: 16)),
                                  SizedBox(width: 20),
                                  Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(FontAwesomeIcons.pen,
                                color: darkBlueColor),
                            title: const Text('Signature',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: const Text('Add Signature',
                                style: TextStyle(color: greyColor)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (signatureImage != null)
                                  Image.memory(signatureImage,
                                      width: 50, height: 30),
                                const Icon(Icons.arrow_forward_ios_outlined,
                                    color: darkBlueColor),
                              ],
                            ),
                            onTap: () async {
                              Uint8List? signature =
                                  await captureSignature(context);
                              signatureProvider.saveSignature(signature);
                            },
                          ),
                          ListTile(
                            leading: const Icon(FontAwesomeIcons.clipboard,
                                color: darkBlueColor),
                            title: const Text('Terms & Conditions',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: invoice.terms.isNotEmpty
                                ? Text(
                                    invoice.terms,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: greyColor),
                                    maxLines: 1,
                                  )
                                : Container(),
                            trailing: const Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: darkBlueColor),
                            onTap: () {
                              termsDialog(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(FontAwesomeIcons.creditCard,
                                color: darkBlueColor),
                            title: const Text('Payment Method',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            trailing: const Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: darkBlueColor),
                            subtitle: selectedPaymentMethodDetails != null
                                ? Text(
                                    selectedPaymentMethodDetails!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: greyColor),
                                  )
                                : Container(),
                            onTap: () async {
                              final selectedPaymentMethod =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentMethodScreen()),
                              );
                              if (selectedPaymentMethod != null) {
                                setState(() {
                                  selectedPaymentMethodDetails =
                                      selectedPaymentMethod.details;
                                  invoiceProvider.setPaymentMethod(
                                      selectedPaymentMethod.details);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 80), // Padding for bottom sticky container
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: greyColor)),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 1,
                    offset: Offset(0, -0.75),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PreviewButton(
                      title: 'Preview',
                      onTap: () async {
                        // Navigate to the TemplateSelectionScreen and await the result
                        selectedTemplate = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateSelectionScreen(
                              invoice: invoice,
                              signature: signatureProvider.signature ??
                                  transparentPixel,
                              fromPreviewBtn: true,
                            ),
                          ),
                        );
                      }),
                  SaveButton(
                    title: 'SAVE',
                    onTap: () {
                      if (total != null) {
                        final updatedInvoice = invoice.copyWith(
                            id: invoice.id ??
                                DateTime.now()
                                    .toIso8601String(), // Use existing ID if available
                            total: total!,
                            template: selectedTemplate);

                        // Check if the invoice already exists
                        final existingInvoiceIndex = invoiceProvider.invoices
                            .indexWhere((inv) => inv.id == updatedInvoice.id);

                        if (existingInvoiceIndex != -1) {
                          // Update existing invoice
                          invoiceProvider.updateInvoice(updatedInvoice);
                        } else {
                          // Add new invoice
                          invoiceProvider.addInvoice(updatedInvoice);
                          print("NEW INVOICE ID: ${updatedInvoice.id}");
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FinalInvoiceScreen(invoice: updatedInvoice),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
