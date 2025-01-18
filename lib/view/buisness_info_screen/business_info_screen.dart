import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final picker = ImagePicker();
  File? image;

  late TextEditingController nameController;
  late TextEditingController mailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController websiteController;

  @override
  void initState() {
    super.initState();

    var businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);

    // Initialize controllers with the saved data if available
    nameController =
        TextEditingController(text: businessProvider.business.businessName);
    mailController =
        TextEditingController(text: businessProvider.business.emailAddress);
    phoneController =
        TextEditingController(text: businessProvider.business.phone);
    addressController =
        TextEditingController(text: businessProvider.business.billingAddress);
    websiteController =
        TextEditingController(text: businessProvider.business.website);

    image = businessProvider.business.businessLogo;
  }

  @override
  void dispose() {
    nameController.dispose();
    mailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //initialize business provider
    var businessProvider = Provider.of<BusinessProvider>(context);

    //initialize invoice provider
    var invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Info'),
        actions: [
          IconButton(
              onPressed: () {
                businessProvider.setBusinessName(nameController.text);
                businessProvider.setEmailAddress(mailController.text);
                businessProvider.setPhone(phoneController.text);
                businessProvider.setBillingAddress(addressController.text);
                businessProvider.setWebsite(websiteController.text);
                businessProvider.setBusinessLogo(image);
                //set "from" of invoice provider
                invoiceProvider.setFrom(nameController.text);
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.check,
                color: whiteColor,
              )),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              color: whiteColor,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          businessProvider.business.businessLogo != null
                              ? GestureDetector(
                                  onTap: () {
                                    imagePickerDialog(context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.file(
                                      businessProvider.business.businessLogo!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    imagePickerDialog(context);
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: lightGreyColor,
                                      border: Border.all(
                                          color: darkGreyColor, width: 1.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 40,
                                      color: darkGreyColor,
                                    ),
                                  ),
                                ),
                          const Text(
                            'Business Logo',
                            style: TextStyle(
                                fontSize: 12,
                                color: darkGreyColor,
                                height: 2.5),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Business Name',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 14, color: darkGreyColor, height: 2.1),
                    ),
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Enter business name',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Email Address',
                      style: TextStyle(
                          fontSize: 14, color: darkGreyColor, height: 2.1),
                    ),
                    CustomTextField(
                      controller: mailController,
                      hintText: 'Enter business email address',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Phone',
                      style: TextStyle(
                          fontSize: 14, color: darkGreyColor, height: 2.1),
                    ),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Enter business phone number',
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Billing Address',
                      style: TextStyle(
                          fontSize: 14, color: darkGreyColor, height: 2.1),
                    ),
                    CustomTextField(
                        controller: addressController,
                        hintText: 'Enter address'),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Business Website',
                      style: TextStyle(
                          fontSize: 14, color: darkGreyColor, height: 2.1),
                    ),
                    CustomTextField(
                        controller: websiteController,
                        hintText: 'Enter business website'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Future<void> imagePickerDialog(BuildContext context) async {
    var width = MediaQuery.of(context).size.width * 1;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: whiteColor,
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
                        pickGalleryImage(context);
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
                        pickCameraImage(context);
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

  Future pickGalleryImage(BuildContext context) async {
    //initialize business provider
    final businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      businessProvider.setBusinessLogo(image);
    }
  }

  Future pickCameraImage(BuildContext context) async {
    //initialize business provider
    final businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      businessProvider.setBusinessLogo(image);
    }
  }
}
