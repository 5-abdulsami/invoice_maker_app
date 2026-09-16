import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/app.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The system bars follow the app's own light and dark themes.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Storage is opened and read before the first frame, so no screen has to
  // handle a loading state for data that is already on the device.
  final repositories = await AppRepositories.initialize();

  runApp(InvoiceMakerApp(repositories: repositories));
}
