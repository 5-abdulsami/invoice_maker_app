import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/presentation/catalog/catalog_list_screen.dart';
import 'package:invoicemaker/presentation/customers/customer_list_screen.dart';
import 'package:invoicemaker/presentation/documents/document_list_screen.dart';
import 'package:invoicemaker/presentation/home/home_screen.dart';

/// The destinations in the bottom bar.
enum ShellTab {
  home(AppStrings.home, Icons.home_outlined, Icons.home),
  invoices(AppStrings.documents, Icons.receipt_long_outlined, Icons.receipt_long),
  estimates('Estimates', Icons.description_outlined, Icons.description),
  customers(AppStrings.customers, Icons.people_outline, Icons.people),
  items(AppStrings.catalog, Icons.inventory_2_outlined, Icons.inventory_2);

  const ShellTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Hosts the five main destinations.
///
/// Each tab keeps its own scroll position and filters via an [IndexedStack],
/// so switching away and back does not reset what the user was looking at.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ShellTab _tab = ShellTab.home;

  void _select(ShellTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab.index,
        children: [
          HomeScreen(onBrowseInvoices: () => _select(ShellTab.invoices)),
          const DocumentListScreen(kind: DocumentKind.invoice),
          const DocumentListScreen(kind: DocumentKind.estimate),
          const CustomerListScreen(),
          const CatalogListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab.index,
        onDestinationSelected: (index) => _select(ShellTab.values[index]),
        destinations: [
          for (final tab in ShellTab.values)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
              tooltip: tab.label,
            ),
        ],
      ),
    );
  }
}
