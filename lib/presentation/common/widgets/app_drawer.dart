import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/dialogs/share_app_dialog.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

/// The app-wide navigation drawer.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeader(),
            _DrawerTile(
              icon: Icons.insert_chart_outlined_outlined,
              label: AppStrings.report,
              onTap: () => _go(context, RouteNames.report),
            ),
            _DrawerTile(
              icon: Icons.cloud_upload_outlined,
              label: AppStrings.sync,
              onTap: () => _go(context, RouteNames.sync),
            ),
            _DrawerTile(
              icon: Icons.import_export_outlined,
              label: AppStrings.exportImport,
              onTap: () => _go(context, RouteNames.exportImport),
            ),
            _DrawerTile(
              icon: Icons.share_outlined,
              label: AppStrings.shareApp,
              onTap: () {
                Navigator.of(context).pop();
                ShareAppDialog.show(context);
              },
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: AppStrings.settings,
              onTap: () {
                Navigator.of(context).pop();
                context.read<NavigationProvider>().goToTab(AppTab.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context)
      ..pop()
      ..pushNamed(route);
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;

    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _openBusinessInfo(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white,
                  foregroundImage: business.hasLogo
                      ? FileImage(File(business.logoPath!))
                      : null,
                  child: const Icon(
                    Icons.business_outlined,
                    color: AppColors.primary,
                  ),
                ),
                Gap.sm,
                Text(
                  business.businessName.isNotEmpty
                      ? business.businessName
                      : AppStrings.addBusiness,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Gap.sm,
          OutlinedButton.icon(
            onPressed: () => _openBusinessInfo(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.white.withValues(alpha: 0.15),
              side: const BorderSide(color: AppColors.white),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.group_add_outlined, size: 18),
            label: const Text(
              'Manage Business',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _openBusinessInfo(BuildContext context) {
    Navigator.of(context)
      ..pop()
      ..pushNamed(RouteNames.businessInfo);
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Text(label, style: const TextStyle(color: AppColors.black)),
      ),
      onTap: onTap,
    );
  }
}
