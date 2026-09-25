import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/app_bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // The system bars follow the app's own light and dark themes.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Storage opens behind the splash; by the time the app itself is built,
  // everything is already in memory, so no screen has a loading state for
  // data that is on the device.
  runApp(const AppBootstrap());
}
