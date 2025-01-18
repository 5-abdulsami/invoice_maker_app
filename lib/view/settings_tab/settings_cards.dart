import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/buisness_info_screen/business_info_screen.dart';
import 'package:invoicemaker/view/payment_method_screen/payment_method_screen.dart';
import 'package:invoicemaker/view/widgets/dialogs/share_app_dialog.dart';
import 'package:invoicemaker/view_model/capture_signature.dart';
import 'package:provider/provider.dart';

Widget businessCard(BuildContext context) {
  //initialize signature Provider
  final signatureProvider = Provider.of<SignatureProvider>(context);
  Uint8List? signatureImage = signatureProvider.signature;
  return Card(
    color: whiteColor,
    elevation: 5,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Business',
              style: TextStyle(fontSize: 14, color: blueColor, height: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Business Info'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BusinessInfoScreen()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Change Business'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BusinessInfoScreen()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Payment Method'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentMethodScreen(
                              fromSettings: true,
                            )));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Signature'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (signatureImage != null)
                    Image.memory(
                      signatureImage,
                      width: 50,
                      height: 30,
                    ),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: darkBlueColor,
                  ),
                ],
              ),
              onTap: () async {
                Uint8List? signature = await captureSignature(context);
                signatureProvider.saveSignature(signature);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget invoiceCard(BuildContext context) {
  return Card(
    color: whiteColor,
    elevation: 5,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Invoice',
              style: TextStyle(fontSize: 14, color: blueColor, height: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Due Terms'),
              subtitle: const Text(
                '7 days',
                style: TextStyle(color: greyColor, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Paid show on Invoice'),
              trailing: Switch(
                  activeColor: blueColor,
                  value: true,
                  onChanged: (bool newValue) {}),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget generalCard(BuildContext context) {
  return Card(
    color: whiteColor,
    elevation: 5,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'General',
              style: TextStyle(fontSize: 14, color: blueColor, height: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Default Currency'),
              subtitle: const Text(
                'PKR Rs',
                style: TextStyle(color: greyColor, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Number Format'),
              subtitle: const Text(
                '1,000,000',
                style: TextStyle(color: greyColor, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Date Format'),
              subtitle: const Text(
                '31/12/2024',
                style: TextStyle(color: greyColor, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
        ],
      ),
    ),
  );
}

Widget aboutCard(BuildContext context) {
  return Card(
    color: whiteColor,
    elevation: 5,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'About',
              style: TextStyle(fontSize: 14, color: blueColor, height: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Help Us Translate'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Feedback'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Rate Us'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: const Text('Share App'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                shareAppDialog(context);
              },
            ),
          ),
        ],
      ),
    ),
  );
}
