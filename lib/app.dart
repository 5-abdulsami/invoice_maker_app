import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/app_scroll_behavior.dart';
import 'package:invoicemaker/core/design/app_theme.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';
import 'package:invoicemaker/domain/entitlements.dart';
import 'package:invoicemaker/presentation/shell/app_shell.dart';
import 'package:invoicemaker/services/backup_service.dart';
import 'package:invoicemaker/services/pdf/document_pdf_service.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:invoicemaker/state/catalog_controller.dart';
import 'package:invoicemaker/state/customer_controller.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// The app shell: dependency wiring, theme and the first screen.
class InvoiceMakerApp extends StatelessWidget {
  const InvoiceMakerApp({super.key, required this.repositories});

  /// Storage, already opened and loaded before the first frame.
  final AppRepositories repositories;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppRepositories>.value(value: repositories),
        Provider<Entitlements>(
          create: (_) => const EarlyAccessEntitlements(),
        ),
        Provider<BackupService>(
          create: (_) => BackupService(repositories),
        ),
        Provider<DocumentPdfService>(
          create: (_) => DocumentPdfService(vault: repositories.vault),
        ),
        ChangeNotifierProvider<SettingsController>(
          create: (_) => SettingsController(repositories.settings),
        ),
        ChangeNotifierProvider<BusinessController>(
          create: (_) {
            final controller = BusinessController(repositories.business);
            // The profile itself is already loaded; its images are read in
            // the background so the first frame is not held up by disk.
            unawaited(controller.loadImages());
            return controller;
          },
        ),
        ChangeNotifierProvider<CustomerController>(
          create: (_) => CustomerController(repositories.customers),
        ),
        ChangeNotifierProvider<CatalogController>(
          create: (_) => CatalogController(repositories.catalog),
        ),
        // Depends on the settings controller for numbering, so it is created
        // after it and reads it rather than the repository directly.
        ChangeNotifierProxyProvider<SettingsController, DocumentController>(
          create: (context) => DocumentController(
            documents: repositories.documents,
            business: repositories.business,
            settings: context.read<SettingsController>(),
          ),
          update: (_, __, controller) => controller!,
        ),
      ],
      // Only the theme mode is read here, so changing any other setting does
      // not rebuild the whole app.
      child: Selector<SettingsController, ThemeMode>(
        selector: (_, settings) => settings.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            scrollBehavior: const AppScrollBehavior(),
            home: const AppShell(),
            builder: (context, child) {
              // Very large system text sizes would clip fixed-height rows, so
              // the scale is capped while still honouring the user's choice.
              final scaler = MediaQuery.textScalerOf(context).clamp(
                maxScaleFactor: Layout.maxTextScale,
              );

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                // Status and navigation bar icons contrast with the theme
                // canvas; app bars refine the status bar on their own.
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: _systemBarsFor(Theme.of(context).brightness),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static SystemUiOverlayStyle _systemBarsFor(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return base.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
