import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/presentation/common/widgets/app_drawer.dart';
import 'package:invoicemaker/presentation/settings/widgets/about_settings_card.dart';
import 'package:invoicemaker/presentation/settings/widgets/business_settings_card.dart';
import 'package:invoicemaker/presentation/settings/widgets/general_settings_card.dart';
import 'package:invoicemaker/presentation/settings/widgets/invoice_settings_card.dart';

/// The settings tab.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      drawer: const AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              BusinessSettingsCard(),
              InvoiceSettingsCard(),
              GeneralSettingsCard(),
              AboutSettingsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
