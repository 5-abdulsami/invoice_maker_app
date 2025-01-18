import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/buttons/share_button.dart';

Future<void> shareAppDialog(BuildContext context) async {
  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            width: width * 0.8,
            height: height * 0.47,
            child: Center(
              child: Column(
                children: [
                  Container(
                    height: height * 0.206,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      color: blueColor,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 5,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: whiteColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  const Text(
                    'Share with friends',
                    style: TextStyle(
                        fontSize: 18,
                        color: blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  const Text(
                    'Enjoy using Invoice Maker? Share with your\nbusiness friends',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: height * 0.040,
                  ),
                  const ShareButton(),
                  SizedBox(
                    height: height * 0.025,
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
