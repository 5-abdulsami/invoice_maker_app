import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';

class SignatureProvider extends ChangeNotifier {
  Uint8List? _signature = transparentPixel;

  Uint8List? get signature => _signature;

  void saveSignature(Uint8List signature) {
    _signature = signature;
    notifyListeners();
  }

  void clearSignature() {
    _signature = null;
    notifyListeners();
  }
}
