
import 'package:flutter/services.dart';

Uint8List? topImage;
Uint8List? bottomImage;
Uint8List? assetImage;
Uint8List? phoneImage;
Uint8List? mailImage;
Uint8List? webImage;
Uint8List? signatureImage;

Future<void> loadAssetImages() async {
  final ByteData topData = await rootBundle.load('assets/images/top_image.png');
  topImage = topData.buffer.asUint8List();

  final ByteData bottomData =
      await rootBundle.load('assets/images/bottom_image.png');
  bottomImage = bottomData.buffer.asUint8List();

  final ByteData data = await rootBundle.load('assets/images/logo.png');
  assetImage = data.buffer.asUint8List();

  final ByteData phoneData = await rootBundle.load('assets/images/phone.png');
  phoneImage = phoneData.buffer.asUint8List();

  final ByteData mailData = await rootBundle.load('assets/images/mail.jpg');
  mailImage = mailData.buffer.asUint8List();

  final ByteData webData = await rootBundle.load('assets/images/web.png');
  webImage = webData.buffer.asUint8List();
}
