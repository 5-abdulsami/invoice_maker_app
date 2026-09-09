import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// Placeholder body for features that are planned but not built.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppColors.lightBlue),
            Gap.lg,
            Text(title, style: AppTextStyles.heading2),
            Gap.sm,
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.tileSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
