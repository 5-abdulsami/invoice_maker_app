import 'package:flutter/material.dart';
import 'package:invoicemaker/routes/route_names.dart';
import 'package:invoicemaker/view/buisness_info_screen/business_info_screen.dart';
import 'package:invoicemaker/view/dashboard_screen/dashboard_screen.dart';
import 'package:invoicemaker/view/export_import_screen/export_import_screen.dart';
import 'package:invoicemaker/view/report_screen/report_screen.dart';
import 'package:invoicemaker/view/settings_tab/settings_screen.dart';
import 'package:invoicemaker/view/signature_screen/signature_capture_screen.dart';
import 'package:invoicemaker/view/splash_screen/splash_screen.dart';
import 'package:invoicemaker/view/sync_screen/sync_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
            builder: (_) => const SplashScreen(), settings: settings);

      case RouteNames.signature:
        return MaterialPageRoute(
            builder: (_) => const SignatureCaptureScreen(), settings: settings);

      case RouteNames.dashboard:
        return MaterialPageRoute(
            builder: (_) => const DashboardScreen(), settings: settings);

      case RouteNames.settings:
        return MaterialPageRoute(
            builder: (_) => const SettingsTab(), settings: settings);

      case RouteNames.export:
        return MaterialPageRoute(
            builder: (context) => const ExportImportScreen(),
            settings: settings);

      case RouteNames.sync:
        return MaterialPageRoute(
            builder: (_) => const SyncScreen(), settings: settings);

      case RouteNames.report:
        return MaterialPageRoute(
            builder: (_) => const ReportScreen(), settings: settings);

      case RouteNames.businessInfo:
        return MaterialPageRoute(
            builder: (_) => const BusinessInfoScreen(), settings: settings);

      default:
        return MaterialPageRoute(
            builder: (context) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'No Route Defined',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              );
            },
            settings: settings);
    }
  }
}
