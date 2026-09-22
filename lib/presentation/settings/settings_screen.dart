import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_info.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// The settings index.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTheme(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final option = await AppSheet.choose<AppThemeOption>(
      context,
      title: AppStrings.theme,
      options: AppThemeOption.values,
      selected: controller.settings.themeOption,
      labelOf: (value) => value.label,
    );
    if (option == null) return;
    await controller.setTheme(option);
  }

  Future<void> _pickDateFormat(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final option = await AppSheet.choose<DateFormatOption>(
      context,
      title: AppStrings.dateFormat,
      options: DateFormatOption.values,
      selected: controller.dateFormat,
      labelOf: (value) => value.example,
    );
    if (option == null) return;
    await controller.setDateFormat(option);
  }

  Future<void> _pickNumberFormat(BuildContext context) async {
    final controller = context.read<SettingsController>();
    final option = await AppSheet.choose<NumberGroupingOption>(
      context,
      title: AppStrings.numberFormat,
      options: NumberGroupingOption.values,
      selected: controller.settings.numberGrouping,
      labelOf: (value) => value.label,
      subtitleOf: (value) => value == NumberGroupingOption.automatic
          ? r'Rs 3,000 · ₹1,00,000.00 · $3,000.00 · €3.000,00'
          : null,
    );
    if (option == null) return;
    await controller.setNumberGrouping(option);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final business = context.watch<BusinessController>();
    final values = settings.settings;

    return AppScaffold(
      title: AppStrings.settings,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          Insets.lg,
          Insets.gutter,
          Insets.xl,
        ),
        children: [
          const SectionHeader(title: 'Your business'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: AppStrings.businessProfile,
                  subtitle: business.isConfigured
                      ? business.profile.name
                      : 'Not set up yet',
                  icon: Icons.storefront_outlined,
                  onTap: () => AppNavigator.openBusinessProfile(context),
                ),
                AppTile(
                  title: AppStrings.signature,
                  subtitle: business.profile.hasSignature
                      ? 'Saved'
                      : 'Not added',
                  icon: Icons.draw_outlined,
                  onTap: () => AppNavigator.openSignatureCapture(context),
                ),
              ],
            ),
          ),
          Gap.h20,
          const SectionHeader(title: AppStrings.documentDefaults),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: 'Defaults for new documents',
                  subtitle: '${values.defaultCurrency.code} · '
                      '${values.defaultTemplate.label} · '
                      '${values.defaultTermDays} day terms',
                  icon: Icons.tune,
                  onTap: () => AppNavigator.openDocumentDefaults(context),
                ),
                AppTile(
                  title: AppStrings.numbering,
                  subtitle: 'Next: ${values.formatNumber(
                    DocumentKind.invoice,
                    values.nextInvoiceSequence,
                  )}',
                  icon: Icons.tag,
                  onTap: () => AppNavigator.openNumbering(context),
                ),
              ],
            ),
          ),
          Gap.h20,
          const SectionHeader(title: AppStrings.appearance),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: AppStrings.theme,
                  value: values.themeOption.label,
                  icon: Icons.contrast,
                  onTap: () => _pickTheme(context),
                ),
                AppTile(
                  title: AppStrings.dateFormat,
                  value: values.dateFormat.example,
                  icon: Icons.event_outlined,
                  onTap: () => _pickDateFormat(context),
                ),
                AppTile(
                  title: AppStrings.numberFormat,
                  value: values.numberGrouping.label,
                  icon: Icons.numbers,
                  onTap: () => _pickNumberFormat(context),
                ),
              ],
            ),
          ),
          Gap.h20,
          const SectionHeader(title: AppStrings.dataAndBackup),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: 'Backup and restore',
                  subtitle: 'Everything is stored on this device only',
                  icon: Icons.save_outlined,
                  onTap: () => AppNavigator.openBackup(context),
                ),
              ],
            ),
          ),
          Gap.h20,
          const SectionHeader(title: AppStrings.about),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: 'About ${AppStrings.appName}',
                  value: AppInfo.versionName,
                  icon: Icons.info_outline,
                  onTap: () => AppNavigator.openAbout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
