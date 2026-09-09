import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_assets.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// Shown wherever a list has nothing in it yet.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.showImage = true,
  });

  final String message;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showImage) ...[
              Image.asset(
                AppAssets.emptyBox,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
              Gap.md,
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.tileSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
