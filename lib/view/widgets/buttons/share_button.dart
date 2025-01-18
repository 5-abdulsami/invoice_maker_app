import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Center(
        child: Text(
          'SHARE NOW',
          style: TextStyle(color: whiteColor),
        ),
      ),
    );
  }
}
