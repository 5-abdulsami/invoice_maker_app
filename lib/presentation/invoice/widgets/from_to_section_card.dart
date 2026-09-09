import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/presentation/common/widgets/app_fa_icon.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';

/// The business and client rows on the invoice and estimate forms.
class FromToSectionCard extends StatelessWidget {
  const FromToSectionCard({
    super.key,
    required this.from,
    required this.to,
    required this.onFromTap,
    required this.onToTap,
  });

  final String from;
  final String to;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          NavTile(
            leadingWidget: const AppFaIcon(FontAwesomeIcons.user),
            title: AppStrings.from,
            titleStyle: AppTextStyles.tileTitleDark,
            subtitle: from.isNotEmpty ? from : AppStrings.addBusiness,
            onTap: onFromTap,
          ),
          NavTile(
            leadingWidget: const AppFaIcon(FontAwesomeIcons.arrowRight),
            title: AppStrings.billTo,
            titleStyle: AppTextStyles.tileTitleDark,
            subtitle: to.isNotEmpty ? to : AppStrings.addClient,
            onTap: onToTap,
          ),
        ],
      ),
    );
  }
}
