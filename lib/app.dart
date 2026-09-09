import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/theme/app_theme.dart';
import 'package:invoicemaker/navigation/app_router.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/providers/item_provider.dart';
import 'package:invoicemaker/providers/navigation_provider.dart';
import 'package:invoicemaker/providers/payment_method_provider.dart';
import 'package:invoicemaker/providers/settings_provider.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:provider/provider.dart';

/// The app shell: state wiring, theme and routing.
class InvoiceMakerApp extends StatelessWidget {
  const InvoiceMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SignatureProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => EstimateProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
