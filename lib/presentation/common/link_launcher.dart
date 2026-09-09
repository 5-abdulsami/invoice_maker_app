import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/presentation/common/dialogs/coming_soon_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external links, degrading to a "coming soon" dialog when a link has
/// not been configured yet.
sealed class LinkLauncher {
  /// Opens [url] in the platform browser or app.
  static Future<void> open(
    BuildContext context, {
    required String url,
    required String featureName,
  }) async {
    if (url.isEmpty) {
      await ComingSoonDialog.show(context, featureName);
      return;
    }

    final uri = Uri.tryParse(url);
    final launched = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      context.showSnackBar('Could not open $featureName.', isError: true);
    }
  }

  /// Opens the mail app with a message addressed to [address].
  static Future<void> email(
    BuildContext context, {
    required String address,
    required String subject,
    required String featureName,
  }) {
    return open(
      context,
      url: address.isEmpty
          ? ''
          : Uri(
              scheme: 'mailto',
              path: address,
              queryParameters: {'subject': subject},
            ).toString(),
      featureName: featureName,
    );
  }

  /// Convenience for the app-name subject line used by feedback mails.
  static String get feedbackSubject => '${AppStrings.appName} feedback';
}
