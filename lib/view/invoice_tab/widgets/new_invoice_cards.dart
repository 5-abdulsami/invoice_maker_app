import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/view/invoice_tab/add_item_screen.dart';
import 'package:invoicemaker/view/invoice_tab/edit_item_screen.dart';
import 'package:invoicemaker/view/invoice_tab/new_item_screen.dart';
import 'package:invoicemaker/view/widgets/dialogs/discount_dialog.dart';
import 'package:invoicemaker/view/widgets/dialogs/shipping_dialog.dart';
import 'package:invoicemaker/view/widgets/dialogs/tax_dialog.dart';
import 'package:provider/provider.dart';

Widget infoCard(BuildContext context, String invoiceNumber,
    DateTime creationDate, DateTime dueDate, VoidCallback onTap) {
  return Card(
    color: whiteColor,
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
              title: Text(
                invoiceNumber,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor),
              ),
              subtitle: Text(
                'Created on ${DateFormat('yMMMd').format(creationDate)}\nDue on ${DateFormat('yMMMd').format(dueDate)}',
                style: const TextStyle(color: greyColor),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_sharp,
                color: darkBlueColor,
              ),
              onTap: onTap),
        ],
      ),
    ),
  );
}

Widget langTempCard(BuildContext context) {
  return Card(
    color: whiteColor,
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(
              FontAwesomeIcons.globe,
              color: darkBlueColor,
            ),
            title: const Text(
              'Invoice Language',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(color: greyColor, fontSize: 14),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                )),
            onTap: () {
              //Dialog of language selection to be implemented
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.list_alt_outlined,
              color: darkBlueColor,
            ),
            title: const Text(
              'Templates',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: darkBlueColor,
            ),
            onTap: () {
              //Different template options to be provided
            },
          ),
        ],
      ),
    ),
  );
}

Widget fromToCard(BuildContext context, VoidCallback onBusinessTap,
    VoidCallback onClientTap) {
  //initialize invoice provider
  var invoiceProvider = Provider.of<InvoiceProvider>(context);

  return Card(
    color: whiteColor,
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(
              FontAwesomeIcons.user,
              color: darkBlueColor,
            ),
            title: const Text(
              'From',
              style:
                  TextStyle(color: darkBlueColor, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              invoiceProvider.invoice.from.isNotEmpty
                  ? invoiceProvider.invoice.from
                  : 'Add Business',
              style: const TextStyle(color: greyColor),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: darkBlueColor,
            ),
            onTap: onBusinessTap,
          ),
          ListTile(
              leading: const Icon(
                FontAwesomeIcons.arrowRight,
                color: darkBlueColor,
              ),
              title: const Text(
                'Bill To',
                style: TextStyle(
                    color: darkBlueColor, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                invoiceProvider.invoice.to.isNotEmpty
                    ? invoiceProvider.invoice.to
                    : 'Add Client',
                style: const TextStyle(color: greyColor),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: darkBlueColor,
              ),
              onTap: onClientTap),
        ],
      ),
    ),
  );
}

Widget itemsCard(BuildContext context, Function(double) onSave) {
  //initialize item provider
  final itemProvider = Provider.of<ItemProvider>(context);

  return Consumer<InvoiceProvider>(
    builder: (context, invoiceProvider, child) {
      double total = invoiceProvider.calculateTotal();
      onSave(total);

      return Card(
        color: whiteColor,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.add_shopping_cart,
                  color: darkBlueColor,
                ),
                title: invoiceProvider.invoice.items.isNotEmpty
                    ? Text(
                        'Items(${invoiceProvider.invoice.items.length})',
                        style: const TextStyle(
                            color: darkBlueColor, fontWeight: FontWeight.w500),
                      )
                    : const Text(
                        'Items',
                        style: TextStyle(
                            color: darkBlueColor, fontWeight: FontWeight.w500),
                      ),
              ),
              // items List
              invoiceProvider.invoice.items.isNotEmpty
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height *
                            0.6, // Max height
                      ),
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = invoiceProvider.invoice.items[index];

                          return Padding(
                            key: ValueKey(item.id),
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditItemScreen(
                                      item: item,
                                      fromAddItemScreen: false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.menu,
                                          color: darkBlueColor),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: darkBlueColor),
                                            ),
                                            Text(
                                              'Discount (${item.discount}%)',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: greyColor),
                                            ),
                                            Text(
                                              'Tax (${item.tax}%)',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: greyColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${item.quantity} x Rs${(item.price).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: darkBlueColor),
                                          ),
                                          Text(
                                            '-Rs${(item.quantity * item.price * (item.discount / 100)).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 10, color: greyColor),
                                          ),
                                          Text(
                                            'Rs${(item.quantity * item.price * (item.tax / 100)).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 10, color: greyColor),
                                          ),
                                          Text(
                                            'Rs${(item.subAmount).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: darkBlueColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: invoiceProvider.invoice.items.length,
                        onReorder: (int oldIndex, int newIndex) {
                          invoiceProvider.reorderItems(oldIndex, newIndex);
                        },
                      ),
                    )
                  : Container(),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: lightGreyColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  height: 55,
                  child: ListTile(
                    onTap: itemProvider.items.isEmpty
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewItemScreen(
                                          fromAddItemScreen: false,
                                        )));
                          }
                        : () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddItemScreen()));
                          },
                    leading: const Icon(
                      Icons.add_circle,
                      color: darkBlueColor,
                    ),
                    title: const Text(
                      'Add Item',
                      style: TextStyle(color: greyColor),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: lightGreyColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Subtotal',
                      style: TextStyle(
                          fontSize: 18,
                          color: darkBlueColor,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'Rs${invoiceProvider.invoice.subTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: darkBlueColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.percent,
                  color: darkBlueColor,
                ),
                title: const Text(
                  'Discount',
                  style: TextStyle(
                      color: darkBlueColor, fontWeight: FontWeight.w500),
                ),
                subtitle: invoiceProvider.invoice.discount != 0
                    ? Text(
                        "${(invoiceProvider.invoice.discount).toStringAsFixed(0)}%",
                        style: const TextStyle(color: greyColor),
                      )
                    : Container(),
                trailing: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        invoiceProvider.invoice.discount != 0
                            ? Text(
                                '-Rs${(invoiceProvider.invoice.subTotal * (invoiceProvider.invoice.discount / 100)).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: darkBlueColor, fontSize: 14),
                              )
                            : const Text(''),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: darkBlueColor,
                        ),
                      ],
                    )),
                onTap: () {
                  discountDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.buildingColumns,
                  color: darkBlueColor,
                ),
                title: const Text(
                  'Tax',
                  style: TextStyle(
                      color: darkBlueColor, fontWeight: FontWeight.w500),
                ),
                subtitle: invoiceProvider.invoice.tax != 0
                    ? Text(
                        "${invoiceProvider.invoice.taxName}(${(invoiceProvider.invoice.tax).toStringAsFixed(0)})%",
                        style: const TextStyle(color: greyColor),
                      )
                    : Container(),
                trailing: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        invoiceProvider.invoice.tax != 0
                            ? Text(
                                'Rs${(invoiceProvider.invoice.subTotal * (invoiceProvider.invoice.tax / 100)).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: darkBlueColor, fontSize: 14),
                              )
                            : const Text(''),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: darkBlueColor,
                        ),
                      ],
                    )),
                onTap: () {
                  taxDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.truckPickup,
                  color: darkBlueColor,
                ),
                title: const Text(
                  'Shipping',
                  style: TextStyle(
                      color: darkBlueColor, fontWeight: FontWeight.w500),
                ),
                trailing: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        invoiceProvider.invoice.shippingCharges != 0
                            ? Text(
                                'Rs${invoiceProvider.invoice.shippingCharges.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: darkBlueColor, fontSize: 14),
                              )
                            : const Text(''),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: darkBlueColor,
                        ),
                      ],
                    )),
                onTap: () {
                  shippingDialog(context);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: darkBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 55,
                child: ListTile(
                  title: const Text(
                    'Total',
                    style: TextStyle(
                        fontSize: 20,
                        color: whiteColor,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    'Rs${invoiceProvider.calculateTotal().toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 20,
                        color: whiteColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
