import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:share_plus/share_plus.dart';

/// Invites the user to tell others about the app.
class ShareAppDialog extends StatelessWidget {
  const ShareAppDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ShareAppDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radius),
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.shareAppTitle,
                    style: AppTextStyles.heading2,
                  ),
                  Gap.sm,
                  const Text(
                    AppStrings.shareAppMessage,
                    textAlign: TextAlign.center,
                  ),
                  Gap.lg,
                  AppButton(
                    label: 'SHARE NOW',
                    icon: Icons.share_outlined,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Share.share(
                        'Try ${AppStrings.appName} - ${AppStrings.tagline}',
                        subject: AppStrings.appName,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
