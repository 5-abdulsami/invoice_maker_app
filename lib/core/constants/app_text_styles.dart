import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';

/// Shared text styles. Prefer these over inline `TextStyle`s.
sealed class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle invoiceNumber = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
  );

  static const TextStyle amount = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    height: 2,
  );

  /// Label shown above a form field.
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 14,
    color: AppColors.darkGrey,
    height: 2.1,
  );

  static const TextStyle fieldLabelDark = TextStyle(
    fontSize: 14,
    color: AppColors.primaryDark,
    height: 2.1,
  );

  static const TextStyle tileTitle = TextStyle(fontWeight: FontWeight.w500);

  static const TextStyle tileTitleDark = TextStyle(
    color: AppColors.primaryDark,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle tileSubtitle = TextStyle(color: AppColors.grey);

  static const TextStyle body = TextStyle(fontSize: 14);

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );

  static const TextStyle listHeader = TextStyle(
    fontSize: 16,
    color: AppColors.primaryDark,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle totalRow = TextStyle(
    fontSize: 20,
    color: AppColors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtotalRow = TextStyle(
    fontSize: 18,
    color: AppColors.primaryDark,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogCancel = TextStyle(color: AppColors.grey);
  static const TextStyle dialogConfirm = TextStyle(color: AppColors.primary);
}
