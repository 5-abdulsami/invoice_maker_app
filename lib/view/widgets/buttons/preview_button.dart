import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';

class PreviewButton extends StatelessWidget {
  const PreviewButton({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 1;
    var height = MediaQuery.of(context).size.height * 1;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height * 0.065,
        width: width * 0.3,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: darkGreyColor),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, color: darkGreyColor),
          ),
        ),
      ),
    );
  }
}
