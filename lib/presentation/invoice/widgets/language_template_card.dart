import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/app_language.dart';
import 'package:invoicemaker/presentation/common/widgets/app_fa_icon.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';

/// Language and PDF template pickers on the invoice form.
class LanguageTemplateCard extends StatelessWidget {
  const LanguageTemplateCard({
    super.key,
    required this.language,
    required this.templateLabel,
    required this.onLanguageTap,
    required this.onTemplateTap,
  });

  final AppLanguage language;
  final String templateLabel;
  final VoidCallback onLanguageTap;
  final VoidCallback onTemplateTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          NavTile(
            leadingWidget: const AppFaIcon(FontAwesomeIcons.globe),
            title: AppStrings.invoiceLanguage,
            value: language.label,
            onTap: onLanguageTap,
          ),
          NavTile(
            icon: Icons.list_alt_outlined,
            title: AppStrings.templates,
            value: templateLabel,
            onTap: onTemplateTap,
          ),
        ],
      ),
    );
  }
}
