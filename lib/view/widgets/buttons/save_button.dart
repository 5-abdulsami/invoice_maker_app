import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.title, required this.onTap});

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
        width: width * 0.6,
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: whiteColor),
          ),
        ),
      ),
    );
  }
}
