import 'package:flutter/material.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/business/business_info_screen.dart';
import 'package:invoicemaker/presentation/client/add_client_screen.dart';
import 'package:invoicemaker/presentation/client/create_edit_client_screen.dart';
import 'package:invoicemaker/presentation/dashboard/dashboard_screen.dart';
import 'package:invoicemaker/presentation/estimate/create_edit_estimate_screen.dart';
import 'package:invoicemaker/presentation/estimate/estimate_detail_screen.dart';
import 'package:invoicemaker/presentation/estimate/estimate_info_screen.dart';
import 'package:invoicemaker/presentation/export_import/export_import_screen.dart';
import 'package:invoicemaker/presentation/invoice/create_edit_invoice_screen.dart';
import 'package:invoicemaker/presentation/invoice/invoice_detail_screen.dart';
import 'package:invoicemaker/presentation/invoice/invoice_info_screen.dart';
import 'package:invoicemaker/presentation/item/add_item_screen.dart';
import 'package:invoicemaker/presentation/item/create_edit_item_screen.dart';
import 'package:invoicemaker/presentation/payment_method/payment_method_screen.dart';
import 'package:invoicemaker/presentation/report/report_screen.dart';
import 'package:invoicemaker/presentation/settings/settings_screen.dart';
import 'package:invoicemaker/presentation/signature/signature_capture_screen.dart';
import 'package:invoicemaker/presentation/splash/splash_screen.dart';
import 'package:invoicemaker/presentation/sync/sync_screen.dart';
import 'package:invoicemaker/presentation/template_selection/template_selection_screen.dart';

/// Builds every route in the app from its name and typed arguments.
sealed class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final builder = _builderFor(settings);
    return MaterialPageRoute<dynamic>(builder: builder, settings: settings);
  }

  static WidgetBuilder _builderFor(RouteSettings settings) {
    final arguments = settings.arguments;

    return switch (settings.name) {
      RouteNames.splash => (_) => const SplashScreen(),
      RouteNames.dashboard => (_) => const DashboardScreen(),
      RouteNames.settings => (_) => const SettingsScreen(),
      RouteNames.report => (_) => const ReportScreen(),
      RouteNames.sync => (_) => const SyncScreen(),
      RouteNames.exportImport => (_) => const ExportImportScreen(),
      RouteNames.businessInfo => (_) => const BusinessInfoScreen(),
      RouteNames.signature => (_) => const SignatureCaptureScreen(),
      RouteNames.estimateInfo => (_) => const EstimateInfoScreen(),
      RouteNames.addClient => (_) => const AddClientScreen(),
      RouteNames.paymentMethod => (_) => PaymentMethodScreen(
            args: _argsOr(arguments, const PaymentMethodArgs()),
          ),
      RouteNames.addItem => (_) => AddItemScreen(
            args: _argsOr(arguments, const AddItemArgs()),
          ),
      RouteNames.createEditInvoice => (_) => CreateEditInvoiceScreen(
            args: _argsOr(arguments, const CreateEditInvoiceArgs()),
          ),
      RouteNames.createEditEstimate => (_) => CreateEditEstimateScreen(
            args: _argsOr(arguments, const CreateEditEstimateArgs()),
          ),
      RouteNames.createEditClient => (_) => CreateEditClientScreen(
            args: _argsOr(arguments, const CreateEditClientArgs()),
          ),
      RouteNames.createEditItem => (_) => CreateEditItemScreen(
            args: _argsOr(arguments, const CreateEditItemArgs()),
          ),
      // These carry a required record, so a missing argument is an error page.
      RouteNames.invoiceDetail => _required<InvoiceDetailArgs>(
          arguments,
          (args) => InvoiceDetailScreen(args: args),
        ),
      RouteNames.invoiceInfo => _required<InvoiceInfoArgs>(
          arguments,
          (args) => InvoiceInfoScreen(args: args),
        ),
      RouteNames.estimateDetail => _required<EstimateDetailArgs>(
          arguments,
          (args) => EstimateDetailScreen(args: args),
        ),
      RouteNames.templateSelection => _required<TemplateSelectionArgs>(
          arguments,
          (args) => TemplateSelectionScreen(args: args),
        ),
      _ => (_) => _RouteErrorScreen(routeName: settings.name),
    };
  }

  /// Uses [arguments] when it is the expected type, else [fallback].
  static T _argsOr<T>(Object? arguments, T fallback) =>
      arguments is T ? arguments : fallback;

  /// Builds [screen] when [arguments] is a [T], else an error page.
  static WidgetBuilder _required<T>(
    Object? arguments,
    Widget Function(T args) screen,
  ) {
    if (arguments is T) return (_) => screen(arguments);
    return (_) => _RouteErrorScreen(
          routeName: 'Missing ${T.toString()}',
        );
  }
}

/// Shown when a route name or its arguments are not recognised.
class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No route defined for ${routeName ?? 'this screen'}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
