import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/presentation/common/dialogs/selection_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// Defaults applied to every new invoice.
class InvoiceSettingsCard extends StatelessWidget {
  const InvoiceSettingsCard({super.key});

  /// Due-term presets, in days. Zero means "due on receipt".
  static const List<int> _dueTermOptions = [0, 7, 14, 15, 30, 45, 60, 90];

  static String _dueTermLabel(int days) =>
      days == 0 ? 'Due on Receipt' : '$days days';

  Future<void> _pickDueTerms(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final days = await SelectionDialog.show<int>(
      context,
      title: AppStrings.dueTerms,
      options: _dueTermOptions,
      selected: settings.defaultDueTerms,
      labelBuilder: _dueTermLabel,
    );
    if (days == null) return;
    settings.setDefaultDueTerms(days);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return SectionCard(
      title: AppStrings.invoice,
      child: Column(
        children: [
          NavTile(
            title: AppStrings.dueTerms,
            subtitle: _dueTermLabel(settings.defaultDueTerms),
            onTap: () => _pickDueTerms(context),
          ),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            title: const Text(AppStrings.paidShowOnInvoice),
            trailing: Switch(
              activeThumbColor: AppColors.primary,
              value: settings.showPaidOnInvoice,
              onChanged: context.read<SettingsProvider>().setShowPaidOnInvoice,
            ),
          ),
        ],
      ),
    );
  }
}
