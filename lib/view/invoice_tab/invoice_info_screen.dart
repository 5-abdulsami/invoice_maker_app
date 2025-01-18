import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class InvoiceInfoScreen extends StatefulWidget {
  const InvoiceInfoScreen({super.key, required this.invoice});
  final Invoice invoice;

  @override
  _InvoiceInfoScreenState createState() => _InvoiceInfoScreenState();
}

class _InvoiceInfoScreenState extends State<InvoiceInfoScreen> {
  late TextEditingController numberController;
  late TextEditingController poController;
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    numberController =
        TextEditingController(text: widget.invoice.invoiceNumber);
    poController = TextEditingController(text: widget.invoice.poNumber);
    titleController = TextEditingController(text: widget.invoice.invoiceTitle);
  }

  @override
  void dispose() {
    numberController.dispose();
    poController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //initialize Invoice Provider
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Info'),
        actions: [
          IconButton(
            onPressed: () {
              String enteredInvoiceNumber = numberController.text;

              // Check if the entered invoice number is unique
              bool isUnique = invoiceProvider.invoices
                  .where((invoice) =>
                      invoice.id !=
                      widget.invoice.id) // Exclude the current invoice
                  .every((invoice) =>
                      invoice.invoiceNumber != enteredInvoiceNumber);

              if (isUnique) {
                // If unique, update the invoice and pop the screen
                Invoice updatedInvoice = widget.invoice.copyWith(
                  invoiceNumber: enteredInvoiceNumber,
                  creationDate: invoiceProvider.invoice.creationDate,
                  dueTerms: invoiceProvider.invoice.dueTerms,
                  dueDate: invoiceProvider.invoice.dueDate,
                  invoiceTitle: titleController.text,
                  poNumber: poController.text,
                );

                invoiceProvider.setInvoice(updatedInvoice);
                Navigator.pop(context, updatedInvoice);
              } else {
                // If not unique, show a dialog or snackbar to the user
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Invoice number must be unique. Please enter a different invoice number.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.check,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 70),
          child: Card(
            color: whiteColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice Number',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  CustomTextField(
                    controller: numberController,
                    hintText: 'Enter invoice number',
                    maxLength: 15,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Creation Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: lightGreyColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 55,
                    child: ListTile(
                      leading: Text(
                        DateFormat('yMMMd')
                            .format(invoiceProvider.invoice.creationDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        DateTime? pickedCreationDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          initialDate: invoiceProvider.invoice.creationDate,
                        );

                        if (pickedCreationDate != null) {
                          // Check if the picked creation date is after the current due date
                          if (pickedCreationDate
                              .isAfter(invoiceProvider.invoice.dueDate)) {
                            // Set both creation date and due date to the picked creation date
                            invoiceProvider.setCreationDate(pickedCreationDate);
                            invoiceProvider.setDueDate(pickedCreationDate);
                          } else {
                            // Set the creation date only if it's valid (before the due date)
                            invoiceProvider.setCreationDate(pickedCreationDate);
                          }
                          // Update due terms regardless of the date changes
                          invoiceProvider.updateDueTerms();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Due Terms',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: lightGreyColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 55,
                    child: ListTile(
                      leading: Text(
                        invoiceProvider.invoice.creationDate ==
                                invoiceProvider.invoice.dueDate
                            ? "Due on Receipt"
                            : '${invoiceProvider.invoice.dueTerms} day(s)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  Consumer<InvoiceProvider>(
                    builder: (context, datesProvider, child) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: lightGreyColor,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        height: 55,
                        child: ListTile(
                          leading: Text(
                            DateFormat('yMMMd')
                                .format(invoiceProvider.invoice.dueDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.calendar_month),
                          onTap: () async {
                            DateTime? pickedDueDate = await showDatePicker(
                              context: context,
                              //set the first date of the picker to the invoice creation date
                              //so that the user cant select a due date before invoice's creation date
                              firstDate: invoiceProvider.invoice.creationDate,
                              lastDate: DateTime(2100),
                              initialDate: invoiceProvider.invoice.dueDate,
                            );
                            if (pickedDueDate != null) {
                              invoiceProvider.setDueDate(pickedDueDate);
                              invoiceProvider.updateDueTerms();
                            }
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'P.O.#',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  CustomTextField(controller: poController, hintText: ''),
                  const SizedBox(height: 15),
                  const Text(
                    'Invoice Title Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  CustomTextField(
                    controller: titleController,
                    hintText: 'INVOICE',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
