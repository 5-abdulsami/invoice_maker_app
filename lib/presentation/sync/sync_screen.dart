import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/presentation/common/widgets/coming_soon_view.dart';

/// Placeholder for cloud sync, which is not implemented yet.
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sync)),
      body: const ComingSoonView(
        icon: Icons.cloud_upload_outlined,
        title: '${AppStrings.sync} - ${AppStrings.comingSoon}',
        description:
            'Backing your invoices up to the cloud and restoring them on '
            'another device is on the way.',
      ),
    );
  }
}
