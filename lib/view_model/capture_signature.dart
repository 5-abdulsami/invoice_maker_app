import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';
import 'package:invoicemaker/view/signature_screen/signature_capture_screen.dart';

Future<Uint8List> captureSignature(BuildContext context) async {
  final sign = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignatureCaptureScreen()),
  );

  //created a new variable for signature and didnot directly
  //used sign because when popping context through phone's
  //back button, it returned null, so we initialized it to transparent
  //pixel, when null
  final signature = sign ?? transparentPixel;

  if (signature != transparentPixel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        content: Image.memory(signature),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  return signature ?? transparentPixel;
}
