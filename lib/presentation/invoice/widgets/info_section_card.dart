import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';

/// The document number and dates at the top of the invoice and estimate forms.
class InfoSectionCard extends StatelessWidget {
  const InfoSectionCard({
    super.key,
    required this.documentNumber,
    required this.creationDate,
    required this.dueDate,
    required this.onTap,
  });

  final String documentNumber;
  final DateTime creationDate;
  final DateTime dueDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        title: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(documentNumber, style: AppTextStyles.invoiceNumber),
        ),
        subtitle: Text(
          'Created on ${creationDate.formatted}\nDue on ${dueDate.formatted}',
          style: AppTextStyles.tileSubtitle,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_sharp,
          size: 16,
          color: AppColors.primaryDark,
        ),
        onTap: onTap,
      ),
    );
  }
}
