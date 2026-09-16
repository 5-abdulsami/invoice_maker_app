import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_info.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:url_launcher/url_launcher.dart';

/// Version, the privacy summary, and the outward links.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Opens [url], telling the user plainly when there is nothing to open yet.
  Future<void> _open(
    BuildContext context, {
    required String url,
    required String label,
  }) async {
    if (url.isEmpty) {
      context.showMessage('$label is not available yet.');
      return;
    }

    final uri = Uri.tryParse(url);
    final opened = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      context.showErrorMessage('Could not open $label.');
    }
  }

  Future<void> _sendFeedback(BuildContext context) async {
    if (AppInfo.supportEmail.isEmpty) {
      context.showMessage('Feedback is not available yet.');
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: AppInfo.supportEmail,
      queryParameters: {
        'subject': '${AppStrings.appName} ${AppInfo.versionName} feedback',
      },
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      context.showErrorMessage('Could not open your email app.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.about,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          Insets.lg,
          Insets.gutter,
          Insets.xl,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.appName, style: context.text.headlineSmall),
                Gap.h4,
                Text(AppStrings.tagline, style: context.text.bodyMedium),
                Gap.h12,
                Text(
                  '${AppStrings.version} ${AppInfo.versionName}',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Gap.h20,
          const SectionHeader(title: AppStrings.privacy),
          AppCard(
            child: Text(AppCopy.privacyBody, style: context.text.bodyMedium),
          ),
          Gap.h20,
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Insets.xs),
            child: AppTileGroup(
              children: [
                AppTile(
                  title: AppStrings.privacyPolicy,
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _open(
                    context,
                    url: AppInfo.privacyPolicyUrl,
                    label: AppStrings.privacyPolicy,
                  ),
                ),
                AppTile(
                  title: AppStrings.sendFeedback,
                  icon: Icons.mail_outline,
                  onTap: () => _sendFeedback(context),
                ),
                AppTile(
                  title: AppStrings.rateApp,
                  icon: Icons.star_outline,
                  onTap: () => _open(
                    context,
                    url: AppInfo.storeListingUrl,
                    label: AppStrings.rateApp,
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
