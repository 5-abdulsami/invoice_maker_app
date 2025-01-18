import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/invoice_tab/final_invoice_screen.dart';
import 'package:invoicemaker/view/invoice_tab/new_invoice_screen.dart';
import 'package:invoicemaker/view/widgets/dialogs/invoice_options_dialog.dart';
import 'package:invoicemaker/view/report_screen/report_screen.dart';
import 'package:invoicemaker/view/widgets/drawer.dart';
import 'package:invoicemaker/view/widgets/dialogs/invoice_status_dialog.dart';
import 'package:provider/provider.dart';

class InvoiceTab extends StatefulWidget {
  const InvoiceTab({super.key});

  @override
  State<InvoiceTab> createState() => _InvoiceTabState();
}

class _InvoiceTabState extends State<InvoiceTab> {
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    // Initialize providers
    final tabControllerProvider = Provider.of<TabControllerProvider>(context);
    final controller = tabControllerProvider.controller;
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    List<String> filters = [
      "All",
      "Unpaid",
      "Partially Paid",
      "Overdue",
      "Paid"
    ];

    List<Invoice> filteredInvoices;
    switch (filter) {
      case "Unpaid":
        filteredInvoices = invoiceProvider.invoices
            .where((invoice) => invoice.status == "Unpaid")
            .toList();
        break;
      case "Partially Paid":
        filteredInvoices = invoiceProvider.invoices
            .where((invoice) => invoice.status == "Partially Paid")
            .toList();
        break;
      case "Overdue":
        filteredInvoices = invoiceProvider.invoices
            .where((invoice) => invoice.dueDate.isBefore(DateTime.now()))
            .toList();
        break;
      case "Paid":
        filteredInvoices = invoiceProvider.invoices
            .where((invoice) => invoice.status == "Paid")
            .toList();
        break;
      default:
        filteredInvoices = invoiceProvider.invoices;
    }

    // Calculate total unpaid and overdue amounts
    double totalUnpaid = filteredInvoices
        .where((invoice) => invoice.status == "Unpaid")
        .fold(0.0, (sum, invoice) => sum + invoice.total);
    double totalOverdue = filteredInvoices
        .where((invoice) => invoice.dueDate.isBefore(DateTime.now()))
        .fold(0.0, (sum, invoice) => sum + invoice.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
            },
            icon: const Icon(
              Icons.insert_chart_outlined_outlined,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: drawerWidget(context, controller),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  color: whiteColor,
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  child: SizedBox(
                    width: width * 0.45,
                    height: height * 0.15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Unpaid',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Rs${totalUnpaid.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: whiteColor,
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  child: SizedBox(
                    width: width * 0.45,
                    height: height * 0.15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Overdue',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Rs${totalOverdue.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: redColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filters Row
                SizedBox(
                  width: width * 0.82,
                  height: height * 0.056,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            filter = filters[index];
                          });
                        },
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          color: whiteColor,
                          elevation: 2,
                          child: Container(
                            color: filter == filters[index]
                                ? blueColor
                                : whiteColor,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                child: Text(
                                  filters[index],
                                  style: TextStyle(
                                      color: filter == filters[index]
                                          ? filterTextColor
                                          : blackColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.filter_alt_outlined,
                  size: 30,
                ),
                const SizedBox(width: 10),
              ],
            ),
            SizedBox(height: height * 0.018),
            filteredInvoices.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: SizedBox(
                      child: Image(
                        image: AssetImage('assets/images/empty_box.png'),
                        width: 200,
                        height: 200,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredInvoices.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        var invoice = filteredInvoices[index];
                        return GestureDetector(
                            onLongPress: () {
                              invoiceOptionsDialog(context, invoice);
                            },
                            child: InvoiceCard(invoice: invoice));
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: blueColor,
        onPressed: () {
          invoiceProvider.resetInvoice();
          print("invoices : ${invoiceProvider.invoice.items}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewInvoiceScreen(
                fromFinalInvoiceScreen: false,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
  });

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          print("current invoice :    ${invoice.items}");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FinalInvoiceScreen(
                        invoice: invoice,
                      )));
        },
        child: Card(
          elevation: 3,
          color: whiteColor,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(invoice.to),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yMMMd').format(invoice.creationDate),
                      ),
                      Text(
                        "Rs${invoice.total.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Due in ${invoice.dueTerms} days'),
                      ElevatedButton(
                        onPressed: () {
                          invoiceStatusDialog(context, invoice);
                        },
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0),
                          backgroundColor: invoice.status == "Unpaid"
                              ? const WidgetStatePropertyAll(
                                  buttonLightBlueColorr)
                              : invoice.status == "Paid"
                                  ? const WidgetStatePropertyAll(
                                      buttonLightGreenColor)
                                  : const WidgetStatePropertyAll(
                                      buttonLightOrangeColor),
                          minimumSize:
                              const WidgetStatePropertyAll(Size(35, 32)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          invoice.status,
                          style: TextStyle(
                              fontSize: 14,
                              color: invoice.status == "Unpaid"
                                  ? lightBlueTextColor
                                  : invoice.status == "Paid"
                                      ? lightGreenTextColor
                                      : lightOrangeTextColor),
                        ),
                      ),
                    ],
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
