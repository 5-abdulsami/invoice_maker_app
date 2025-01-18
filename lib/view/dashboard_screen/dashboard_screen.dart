import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/client_tab/client_tab.dart';
import 'package:invoicemaker/view/estimate_tab/estimate_tab.dart';
import 'package:invoicemaker/view/invoice_tab/invoice_tab.dart';
import 'package:invoicemaker/view/item_tab/item_tab.dart';
import 'package:invoicemaker/view/settings_tab/settings_screen.dart';
import 'package:invoicemaker/view/widgets/drawer.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Widget> _buildScreens() {
    return [
      const InvoiceTab(),
      const EstimateScreen(),
      const ClientTab(),
      const ItemTab(),
      const SettingsTab(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
          icon: const Icon(
            FontAwesomeIcons.receipt,
            size: 18,
          ),
          title: 'Invoice',
          activeColorPrimary: blueColor,
          inactiveColorPrimary: greyColor),
      PersistentBottomNavBarItem(
          icon: const Icon(
            FontAwesomeIcons.solidFileLines,
            size: 18,
          ),
          title: 'Estimate',
          activeColorPrimary: blueColor,
          inactiveColorPrimary: greyColor),
      PersistentBottomNavBarItem(
          icon: const Icon(
            FontAwesomeIcons.solidUser,
            size: 18,
          ),
          title: 'Client',
          activeColorPrimary: blueColor,
          inactiveColorPrimary: greyColor),
      PersistentBottomNavBarItem(
          icon: const Icon(
            FontAwesomeIcons.bagShopping,
            size: 18,
          ),
          title: 'Item',
          activeColorPrimary: blueColor,
          inactiveColorPrimary: greyColor),
      PersistentBottomNavBarItem(
          icon: const Icon(
            FontAwesomeIcons.gear,
            size: 18,
          ),
          title: 'Settings',
          activeColorPrimary: blueColor,
          inactiveColorPrimary: greyColor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabControllerProvider = Provider.of<TabControllerProvider>(context);
    final controller = tabControllerProvider.controller;
    return SafeArea(
      child: Scaffold(
        drawer: drawerWidget(context, controller),
        body: PersistentTabView(
          context,
          screens: _buildScreens(),
          items: _navBarItems(),
          controller: controller,
          backgroundColor: whiteColor,
          navBarStyle: NavBarStyle.style6,
          padding: const EdgeInsets.all(10),
          decoration: const NavBarDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 1,
                  offset: Offset(0, -0.5),
                  color: lightGreyColor),
            ],
          ),
        ),
      ),
    );
  }
}
