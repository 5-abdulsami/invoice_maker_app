import 'package:flutter/material.dart';
import 'package:invoicemaker/model/client_model.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class NewClientScreen extends StatefulWidget {
  final bool fromAddClientScreen;
  const NewClientScreen({super.key, required this.fromAddClientScreen});

  @override
  _NewClientScreenState createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  late TextEditingController nameController;
  late TextEditingController mailController;
  late TextEditingController phoneController;
  late TextEditingController billingController;
  late TextEditingController shippingController;
  late TextEditingController detailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    mailController = TextEditingController();
    phoneController = TextEditingController();
    billingController = TextEditingController();
    shippingController = TextEditingController();
    detailController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    mailController.dispose();
    phoneController.dispose();
    billingController.dispose();
    shippingController.dispose();
    detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Client'),
        actions: [
          IconButton(
            onPressed: () {
              final String newClientId = DateTime.now().toIso8601String();
              final newClient = Client(
                id: newClientId,
                name: nameController.text,
                emailAddress: mailController.text,
                phone: phoneController.text,
                billingAddress: billingController.text,
                shippingAddress: shippingController.text,
                detail: detailController.text,
              );

              // Add the new client to the ClientProvider
              clientProvider.setClient(newClient);
              clientProvider.addClient(newClient);

              // Set "To" of invoice provider
              if (!widget.fromAddClientScreen) {
                invoiceProvider.setTo(nameController.text);
              }

              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                  color: whiteColor,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Client Name',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreyColor,
                            height: 2.1,
                          ),
                        ),
                        CustomTextField(
                          controller: nameController,
                          hintText: 'Enter client name',
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreyColor,
                            height: 2.1,
                          ),
                        ),
                        CustomTextField(
                          controller: mailController,
                          hintText: 'Enter client email address',
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Phone',
                          style: TextStyle(
                              fontSize: 14, color: darkGreyColor, height: 2.1),
                        ),
                        CustomTextField(
                          controller: phoneController,
                          hintText: 'Enter client phone number',
                          keyboardType: TextInputType.number,
                          maxLength: 15,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Billing Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreyColor,
                            height: 2.1,
                          ),
                        ),
                        CustomTextField(
                          controller: billingController,
                          hintText: 'Enter billing address',
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreyColor,
                            height: 2.1,
                          ),
                        ),
                        CustomTextField(
                          controller: shippingController,
                          hintText: 'Enter shipping address',
                        ),
                      ],
                    ),
                  ),
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
                        const Text(
                          'Client Detail (Not shown on invoice)',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkBlueColor,
                            height: 2.1,
                          ),
                        ),
                        TextField(
                          controller: detailController,
                          decoration: InputDecoration(
                            hintText: 'Enter client detail',
                            hintStyle: const TextStyle(color: hintTextColor),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: lightGreyColor,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          minLines: 4,
                          maxLines: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
