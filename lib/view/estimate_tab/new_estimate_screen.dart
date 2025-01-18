import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/estimate_provider.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/buisness_info_screen/business_info_screen.dart';
import 'package:invoicemaker/view/client_tab/new_client_screen.dart';
import 'package:invoicemaker/view/estimate_tab/estimate_info_screen.dart';
import 'package:invoicemaker/view/invoice_tab/widgets/new_invoice_cards.dart';
import 'package:invoicemaker/view/widgets/buttons/preview_button.dart';
import 'package:invoicemaker/view/widgets/buttons/save_button.dart';
import 'package:invoicemaker/view_model/capture_signature.dart';
import 'package:provider/provider.dart';

class NewEstimateScreen extends StatefulWidget {
  const NewEstimateScreen({super.key});

  @override
  State<NewEstimateScreen> createState() => _NewEstimateScreenState();
}

class _NewEstimateScreenState extends State<NewEstimateScreen> {
  File? _image;
  final picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    //Initialize Providers

    //Signature Provider
    final signatureProvider = Provider.of<SignatureProvider>(context);
    Uint8List? signatureImage = signatureProvider.signature;

    //Invoice Provider
    final estimateProvider = Provider.of<EstimateProvider>(context);
    final estimate = estimateProvider.estimate;

    //Business Provider
    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.business;

    //Client Provider
    final clientProvider = Provider.of<ClientProvider>(context);
    final client = clientProvider.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Estimate'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  infoCard(context, business.businessName,
                      estimate.creationDate, estimate.dueDate, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EstimateInfoScreen()));
                  }),
                  // langTempCard(context, invoice),
                  fromToCard(context, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BusinessInfoScreen()));
                  }, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewClientScreen(
                                  fromAddClientScreen: false,
                                )));
                  }),
                  // itemsCard(context),

                  //Currency, Signature, Terms and Conditions, Payment Method Card
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
                            leading: const Icon(
                              Icons.money,
                              color: darkBlueColor,
                            ),
                            title: const Text(
                              'Currency',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: const SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'PKR Rs',
                                      style: TextStyle(
                                          color: darkBlueColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.arrow_forward_ios),
                                  ],
                                )),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(
                              FontAwesomeIcons.pen,
                              color: darkBlueColor,
                            ),
                            title: const Text(
                              'Signature',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: const Text(
                              'Add Signature',
                              style: TextStyle(color: greyColor),
                            ),
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
                              Uint8List? signature =
                                  await captureSignature(context);
                              signatureProvider.saveSignature(signature);
                            },
                          ),
                          const ListTile(
                            leading: Icon(
                              FontAwesomeIcons.clipboard,
                              color: darkBlueColor,
                            ),
                            title: Text(
                              'Terms & Conditions',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: darkBlueColor,
                            ),
                          ),
                          const ListTile(
                            leading: Icon(
                              FontAwesomeIcons.creditCard,
                              color: darkBlueColor,
                            ),
                            title: Text(
                              'Payment Method',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: darkBlueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Attachments Card
                  Card(
                    color: whiteColor,
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ListTile(
                            leading: Icon(
                              Icons.attach_email,
                              color: darkBlueColor,
                            ),
                            title: Text(
                              'Attachments',
                              style: TextStyle(
                                  color: darkBlueColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: lightGreyColor,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              height: 55,
                              child: ListTile(
                                onTap: () {
                                  imagePickerDialog(context);
                                },
                                leading: const Icon(
                                  Icons.add_circle,
                                  color: darkBlueColor,
                                ),
                                title: const Text(
                                  'Add Attachments',
                                  style: TextStyle(color: greyColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
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
                    color: greyColor,
                    blurRadius: 1,
                    offset: Offset(0, -0.75),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PreviewButton(title: 'Preview', onTap: () {}),
                  SaveButton(title: 'SAVE', onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> imagePickerDialog(BuildContext context) async {
    var width = MediaQuery.of(context).size.width * 1;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Attachments',
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
            ),
            content: SizedBox(
                width: width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.image,
                        color: darkBlueColor,
                      ),
                      title: const Text('Choose from Gallery'),
                      onTap: () {
                        pickGalleryImage();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.camera_alt_outlined,
                        color: darkBlueColor,
                      ),
                      title: const Text('Take Photo'),
                      onTap: () {
                        pickCameraImage();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: greyColor),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'SAVE',
                    style: TextStyle(color: blueColor),
                  )),
            ],
          );
        });
  }

  Future pickGalleryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future pickCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
}
