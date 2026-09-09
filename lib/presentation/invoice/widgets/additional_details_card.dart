import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/presentation/common/widgets/app_fa_icon.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';

/// Currency, signature, terms and payment method rows on the document forms.
class AdditionalDetailsCard extends StatelessWidget {
  const AdditionalDetailsCard({
    super.key,
    required this.currency,
    required this.terms,
    required this.paymentMethod,
    required this.onCurrencyTap,
    required this.onSignatureTap,
    required this.onTermsTap,
    required this.onPaymentMethodTap,
    this.signature,
  });

  final Currency currency;
  final String terms;
  final String paymentMethod;

  /// PNG bytes of the saved signature, shown as a thumbnail when present.
  final Uint8List? signature;
  final VoidCallback onCurrencyTap;
  final VoidCallback onSignatureTap;
  final VoidCallback onTermsTap;
  final VoidCallback onPaymentMethodTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          NavTile(
            icon: Icons.money,
            title: AppStrings.currency,
            value: currency.label,
            onTap: onCurrencyTap,
          ),
          NavTile(
            leadingWidget: const AppFaIcon(FontAwesomeIcons.pen),
            title: AppStrings.signature,
            subtitle: AppStrings.addSignature,
            trailingWidget: signature == null
                ? null
                : Image.memory(signature!, width: 50, height: 30),
            onTap: onSignatureTap,
          ),
          NavTile(
            leadingWidget: const AppFaIcon(FontAwesomeIcons.clipboard),
            title: AppStrings.terms,
            subtitle: terms.isEmpty ? null : terms,
            onTap: onTermsTap,
          ),
          NavTile(
            leadingWidget: const AppFaIcon(FontAwesomeIcons.creditCard),
            title: AppStrings.paymentMethod,
            subtitle: paymentMethod.isEmpty ? null : paymentMethod,
            onTap: onPaymentMethodTap,
          ),
        ],
      ),
    );
  }
}
