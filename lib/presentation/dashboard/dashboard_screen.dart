import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/navigation/app_router.dart';
import 'package:invoicemaker/presentation/client/client_list_screen.dart';
import 'package:invoicemaker/presentation/estimate/estimate_list_screen.dart';
import 'package:invoicemaker/presentation/invoice/invoice_list_screen.dart';
import 'package:invoicemaker/presentation/item/item_list_screen.dart';
import 'package:invoicemaker/presentation/settings/settings_screen.dart';
import 'package:invoicemaker/providers/navigation_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

/// Hosts the five bottom-navigation tabs.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<Widget> _screens = [
    InvoiceListScreen(),
    EstimateListScreen(),
    ClientListScreen(),
    ItemListScreen(),
    SettingsScreen(),
  ];

  static const List<({FaIconData icon, String title})> _tabs = [
    (icon: FontAwesomeIcons.receipt, title: AppStrings.invoice),
    (icon: FontAwesomeIcons.solidFileLines, title: AppStrings.estimate),
    (icon: FontAwesomeIcons.solidUser, title: AppStrings.client),
    (icon: FontAwesomeIcons.bagShopping, title: AppStrings.item),
    (icon: FontAwesomeIcons.gear, title: AppStrings.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NavigationProvider>().controller;

    return SafeArea(
      child: Scaffold(
        body: PersistentTabView(
          context,
          controller: controller,
          screens: _screens,
          items: [
            for (final tab in _tabs)
              PersistentBottomNavBarItem(
                icon: FaIcon(tab.icon, size: 18),
                title: tab.title,
                activeColorPrimary: AppColors.primary,
                inactiveColorPrimary: AppColors.grey,
                // Each tab gets its own Navigator, so it needs the app's route
                // generator to resolve named routes pushed from inside a tab.
                routeAndNavigatorSettings: const RouteAndNavigatorSettings(
                  onGenerateRoute: AppRouter.generateRoute,
                ),
              ),
          ],
          backgroundColor: AppColors.white,
          navBarStyle: NavBarStyle.style6,
          padding: const EdgeInsets.all(10),
          decoration: const NavBarDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                offset: Offset(0, -0.5),
                color: AppColors.lightGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
