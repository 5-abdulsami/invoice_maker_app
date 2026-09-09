import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/widgets/nav_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:provider/provider.dart';

/// Business info, payment methods and signature settings.
class BusinessSettingsCard extends StatelessWidget {
  const BusinessSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final signatureProvider = context.watch<SignatureProvider>();

    return SectionCard(
      title: AppStrings.business,
      child: Column(
        children: [
          NavTile(
            title: AppStrings.businessInfo,
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.businessInfo),
          ),
          NavTile(
            title: 'Change Business',
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.businessInfo),
          ),
          NavTile(
            title: AppStrings.paymentMethod,
            onTap: () => Navigator.of(context).pushNamed(
              RouteNames.paymentMethod,
              arguments: const PaymentMethodArgs(manageOnly: true),
            ),
          ),
          NavTile(
            title: AppStrings.signature,
            trailingWidget: signatureProvider.hasSignature
                ? Image.memory(
                    signatureProvider.signature,
                    width: 50,
                    height: 30,
                  )
                : null,
            onTap: () => Navigator.of(context).pushNamed(RouteNames.signature),
          ),
        ],
      ),
    );
  }
}
