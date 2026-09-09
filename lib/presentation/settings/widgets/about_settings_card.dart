import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_links.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/presentation/common/dialogs/share_app_dialog.dart';
import 'package:invoicemaker/presentation/common/link_launcher.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';

/// Links out to feedback, policy and store pages.
class AboutSettingsCard extends StatelessWidget {
  const AboutSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.about,
      child: Column(
        children: [
          NavTile(
            title: AppStrings.helpUsTranslate,
            onTap: () => LinkLauncher.open(
              context,
              url: AppLinks.translationUrl,
              featureName: AppStrings.helpUsTranslate,
            ),
          ),
          NavTile(
            title: AppStrings.feedback,
            onTap: () => LinkLauncher.email(
              context,
              address: AppLinks.supportEmail,
              subject: LinkLauncher.feedbackSubject,
              featureName: AppStrings.feedback,
            ),
          ),
          NavTile(
            title: AppStrings.privacyPolicy,
            onTap: () => LinkLauncher.open(
              context,
              url: AppLinks.privacyPolicyUrl,
              featureName: AppStrings.privacyPolicy,
            ),
          ),
          NavTile(
            title: AppStrings.rateUs,
            onTap: () => LinkLauncher.open(
              context,
              url: AppLinks.storeListingUrl,
              featureName: AppStrings.rateUs,
            ),
          ),
          NavTile(
            title: AppStrings.shareApp,
            onTap: () => ShareAppDialog.show(context),
          ),
        ],
      ),
    );
  }
}
