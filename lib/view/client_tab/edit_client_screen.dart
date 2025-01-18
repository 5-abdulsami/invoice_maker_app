import 'package:flutter/material.dart';
import 'package:invoicemaker/model/client_model.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/dialogs/delete_client_dialog.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditClientScreen extends StatefulWidget {
  const EditClientScreen({super.key, required this.client});
  final Client client;

  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController nameController;
  late TextEditingController mailController;
  late TextEditingController phoneController;
  late TextEditingController billingController;
  late TextEditingController shippingController;
  late TextEditingController detailController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current client data
    nameController = TextEditingController(text: widget.client.name);
    mailController = TextEditingController(text: widget.client.emailAddress);
    phoneController = TextEditingController(text: widget.client.phone);
    billingController =
        TextEditingController(text: widget.client.billingAddress);
    shippingController =
        TextEditingController(text: widget.client.shippingAddress);
    detailController = TextEditingController(text: widget.client.detail);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
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
        title: const Text('Client Info'),
        actions: [
          IconButton(
            onPressed: () {
              deleteClientDialog(context, widget.client);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outlined),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: () {
              final updatedClient = widget.client.copyWith(
                name: nameController.text,
                emailAddress: mailController.text,
                phone: phoneController.text,
                billingAddress: billingController.text,
                shippingAddress: shippingController.text,
                detail: detailController.text,
              );

              // Update the client in the ClientProvider
              clientProvider.removeClient(widget.client);
              clientProvider.addClient(updatedClient);

              // Set the 'to' property of the invoice provider
              invoiceProvider.setTo(nameController.text);

              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
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
                            fontSize: 14, color: darkGreyColor, height: 2.1),
                      ),
                      CustomTextField(
                        controller: nameController,
                        hintText: 'Enter client name',
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Email Address',
                        style: TextStyle(
                            fontSize: 14, color: darkGreyColor, height: 2.1),
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
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Billing Address',
                        style: TextStyle(
                            fontSize: 14, color: darkGreyColor, height: 2.1),
                      ),
                      CustomTextField(
                          controller: billingController,
                          hintText: 'Enter billing address'),
                      const SizedBox(height: 15),
                      const Text(
                        'Shipping Address',
                        style: TextStyle(
                            fontSize: 14, color: darkGreyColor, height: 2.1),
                      ),
                      CustomTextField(
                          controller: shippingController,
                          hintText: 'Enter shipping address'),
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
                            fontSize: 14, color: darkBlueColor, height: 2.1),
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
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10))),
                        minLines: 4,
                        maxLines: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
