import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/app_date_format.dart';
import 'package:invoicemaker/core/enums/app_language.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/presentation/common/dialogs/selection_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// Currency, language and formatting preferences.
class GeneralSettingsCard extends StatelessWidget {
  const GeneralSettingsCard({super.key});

  Future<void> _pickCurrency(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final currency = await SelectionDialog.show<Currency>(
      context,
      title: AppStrings.defaultCurrency,
      options: Currency.values,
      selected: settings.defaultCurrency,
      labelBuilder: (value) => value.label,
      subtitleBuilder: (value) => value.name,
    );
    if (currency == null) return;
    settings.setDefaultCurrency(currency);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final language = await SelectionDialog.show<AppLanguage>(
      context,
      title: AppStrings.invoiceLanguage,
      options: AppLanguage.values,
      selected: settings.language,
      labelBuilder: (value) => value.label,
    );
    if (language == null) return;
    settings.setLanguage(language);
  }

  Future<void> _pickNumberFormat(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final format = await SelectionDialog.show<AppNumberFormat>(
      context,
      title: AppStrings.numberFormat,
      options: AppNumberFormat.values,
      selected: settings.numberFormat,
      labelBuilder: (value) => value.example,
    );
    if (format == null) return;
    settings.setNumberFormat(format);
  }

  Future<void> _pickDateFormat(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final format = await SelectionDialog.show<AppDateFormat>(
      context,
      title: AppStrings.dateFormat,
      options: AppDateFormat.values,
      selected: settings.dateFormat,
      labelBuilder: (value) => value.example,
      subtitleBuilder: (value) => value.pattern,
    );
    if (format == null) return;
    settings.setDateFormat(format);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return SectionCard(
      title: AppStrings.general,
      child: Column(
        children: [
          NavTile(
            title: AppStrings.defaultCurrency,
            subtitle: settings.defaultCurrency.label,
            onTap: () => _pickCurrency(context),
          ),
          NavTile(
            title: AppStrings.invoiceLanguage,
            subtitle: settings.language.label,
            onTap: () => _pickLanguage(context),
          ),
          NavTile(
            title: AppStrings.numberFormat,
            subtitle: settings.numberFormat.example,
            onTap: () => _pickNumberFormat(context),
          ),
          NavTile(
            title: AppStrings.dateFormat,
            subtitle: settings.dateFormat.example,
            onTap: () => _pickDateFormat(context),
          ),
        ],
      ),
    );
  }
}
