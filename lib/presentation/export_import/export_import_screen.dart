import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/presentation/common/widgets/coming_soon_view.dart';

/// Placeholder for data export and import, which is not implemented yet.
class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exportImport)),
      body: const ComingSoonView(
        icon: Icons.import_export_outlined,
        title: '${AppStrings.exportImport} - ${AppStrings.comingSoon}',
        description:
            'Exporting your invoices, clients and items to a file - and '
            'reading them back in - is on the way.',
      ),
    );
  }
}
