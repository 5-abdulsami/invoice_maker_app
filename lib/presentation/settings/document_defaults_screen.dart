import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/common/widgets/status_chip.dart';
import 'package:invoicemaker/presentation/editor/sheets/editor_sheets.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// What every new document starts with.
class DocumentDefaultsScreen extends StatelessWidget {
  const DocumentDefaultsScreen({super.key});

  /// Due-term presets, in days. Zero means due on receipt.
  static const List<int> _termOptions = [0, 7, 14, 21, 30, 45, 60, 90];

  static String _termLabel(int days) =>
      days == 0 ? 'Due on receipt' : '$days days';

  Future<void> _pickCurrency(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final currency = await AppSheet.choose<Currency>(
      context,
      title: AppStrings.defaultCurrency,
      options: Currency.values,
      selected: controller.settings.defaultCurrency,
      labelOf: (option) => option.pickerLabel,
      subtitleOf: (option) => option.symbol,
    );
    if (currency == null) return;
    await controller.setDefaultCurrency(currency);
  }

  Future<void> _pickTemplate(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final template = await AppSheet.choose<InvoiceTemplate>(
      context,
      title: AppStrings.template,
      subtitle: 'Used for new documents. You can change it per document.',
      options: InvoiceTemplate.values,
      selected: controller.settings.defaultTemplate,
      labelOf: (option) => option.label,
      subtitleOf: (option) => option.description,
      trailingOf: (option) => option.isPro ? const ProBadge() : null,
    );
    if (template == null) return;
    await controller.setDefaultTemplate(template);
  }

  Future<void> _pickTerms(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final days = await AppSheet.choose<int>(
      context,
      title: 'Payment due',
      options: _termOptions,
      selected: controller.settings.defaultTermDays,
      labelOf: _termLabel,
    );
    if (days == null) return;
    await controller.setDefaultTermDays(days);
  }

  Future<void> _editTax(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final tax = await TaxSheet.show(
      context,
      currentLabel: controller.settings.defaultTaxLabel,
      currentPercent: controller.settings.defaultTaxPercent,
    );
    if (tax == null) return;
    await controller.setDefaultTax(label: tax.label, percent: tax.percent);
  }

  Future<void> _editText(
    BuildContext context, {
    required String title,
    required String current,
    required Future<void> Function(String value) onSaved,
    String? hint,
  }) async {
    final value = await TextBlockSheet.show(
      context,
      title: title,
      fieldLabel: title,
      current: current,
      hint: hint,
    );
    if (value == null) return;
    await onSaved(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final values = controller.settings;
    final money = controller.moneyFormat;

    return AppScaffold(
      title: AppStrings.documentDefaults,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          Insets.lg,
          Insets.gutter,
          Insets.xl,
        ),
        children: [
          Text(
            'These are applied when you create a document. Changing them '
            'never alters a document you have already saved.',
            style: context.text.bodyMedium,
          ),
          Gap.h20,
          const SectionHeader(title: 'Money'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: AppStrings.defaultCurrency,
                  value: values.defaultCurrency.shortLabel,
                  onTap: () => _pickCurrency(context),
                ),
                AppTile(
                  title: AppStrings.defaultTaxRate,
                  subtitle: values.defaultTaxPercent > 0
                      ? '${values.defaultTaxLabel.isEmpty ? AppStrings.tax : values.defaultTaxLabel} '
                          '${money.percent(values.defaultTaxPercent)}'
                      : 'No tax',
                  onTap: () => _editTax(context),
                ),
                AppTile(
                  title: 'Payment due',
                  value: _termLabel(values.defaultTermDays),
                  onTap: () => _pickTerms(context),
                ),
              ],
            ),
          ),
          Gap.h20,
          const SectionHeader(title: 'Appearance'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTile(
              title: AppStrings.template,
              subtitle: values.defaultTemplate.description,
              value: values.defaultTemplate.label,
              onTap: () => _pickTemplate(context),
            ),
          ),
          Gap.h20,
          const SectionHeader(title: 'Printed text'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: AppStrings.defaultPaymentTerms,
                  subtitle: values.defaultPaymentTerms.isEmpty
                      ? 'Not set'
                      : values.defaultPaymentTerms,
                  onTap: () => _editText(
                    context,
                    title: AppStrings.paymentTerms,
                    current: values.defaultPaymentTerms,
                    hint: 'Payment due within 14 days',
                    onSaved: controller.setDefaultPaymentTerms,
                  ),
                ),
                AppTile(
                  title: AppStrings.paymentDetails,
                  subtitle: values.defaultPaymentDetails.isEmpty
                      ? 'Not set'
                      : values.defaultPaymentDetails,
                  onTap: () => _editText(
                    context,
                    title: AppStrings.paymentDetails,
                    current: values.defaultPaymentDetails,
                    hint: 'Bank name, account number, reference',
                    onSaved: controller.setDefaultPaymentDetails,
                  ),
                ),
                AppTile(
                  title: AppStrings.notes,
                  subtitle: values.defaultNotes.isEmpty
                      ? 'Not set'
                      : values.defaultNotes,
                  onTap: () => _editText(
                    context,
                    title: AppStrings.notes,
                    current: values.defaultNotes,
                    hint: 'Thanks for your business',
                    onSaved: controller.setDefaultNotes,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
