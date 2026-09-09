import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/number_extensions.dart';
import 'package:invoicemaker/presentation/common/widgets/app_fa_icon.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';

/// The discount, tax, shipping and total rows below the line items.
class TotalsSectionCard extends StatelessWidget {
  const TotalsSectionCard({
    super.key,
    required this.currency,
    required this.subTotal,
    required this.discount,
    required this.taxName,
    required this.tax,
    required this.shippingCharges,
    required this.total,
    required this.onDiscountTap,
    required this.onTaxTap,
    required this.onShippingTap,
  });

  final Currency currency;
  final double subTotal;

  /// Discount percentage applied to [subTotal].
  final double discount;
  final String taxName;

  /// Tax percentage applied to [subTotal].
  final double tax;
  final double shippingCharges;
  final double total;
  final VoidCallback onDiscountTap;
  final VoidCallback onTaxTap;
  final VoidCallback onShippingTap;

  @override
  Widget build(BuildContext context) {
    final discountAmount = subTotal * (discount / 100);
    final taxAmount = subTotal * (tax / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavTile(
          leadingWidget: const AppFaIcon(FontAwesomeIcons.percent),
          title: AppStrings.discount,
          titleStyle: AppTextStyles.tileTitleDark,
          subtitle: discount == 0 ? null : discount.asPercent,
          value: discount == 0
              ? null
              : '-${discountAmount.asCurrency(currency)}',
          onTap: onDiscountTap,
        ),
        NavTile(
          leadingWidget: const AppFaIcon(FontAwesomeIcons.buildingColumns),
          title: AppStrings.tax,
          titleStyle: AppTextStyles.tileTitleDark,
          subtitle: tax == 0 ? null : '$taxName(${tax.asPercent})',
          value: tax == 0 ? null : taxAmount.asCurrency(currency),
          onTap: onTaxTap,
        ),
        NavTile(
          leadingWidget: const AppFaIcon(FontAwesomeIcons.truckPickup),
          title: AppStrings.shipping,
          titleStyle: AppTextStyles.tileTitleDark,
          value: shippingCharges == 0
              ? null
              : shippingCharges.asCurrency(currency),
          onTap: onShippingTap,
        ),
        Gap.sm,
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: ListTile(
            title: const Text(AppStrings.total, style: AppTextStyles.totalRow),
            trailing: Text(
              total.asCurrency(currency),
              style: AppTextStyles.totalRow,
            ),
          ),
        ),
      ],
    );
  }
}
