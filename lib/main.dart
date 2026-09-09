import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/app.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set once at startup rather than on every build.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: AppColors.primary),
  );

  runApp(const InvoiceMakerApp());
}
