import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/provider/client_provider.dart';
import 'package:invoicemaker/provider/estimate_provider.dart';
import 'package:invoicemaker/provider/invoice_provider.dart';
import 'package:invoicemaker/provider/item_provider.dart';
import 'package:invoicemaker/provider/payment_method_provider.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/routes/Routes.dart';
import 'package:invoicemaker/routes/route_names.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabControllerProvider()),
        ChangeNotifierProvider(create: (_) => SignatureProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => EstimateProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: blueColor,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invoice Maker',
      theme: ThemeData(
        scaffoldBackgroundColor: scaffoldColor,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: whiteColor),
          color: blueColor,
          titleTextStyle: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: whiteColor),
        ),
      ),
      initialRoute: RouteNames.splash,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
