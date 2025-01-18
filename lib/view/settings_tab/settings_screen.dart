import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/view/settings_tab/settings_cards.dart';
import 'package:invoicemaker/view/widgets/drawer.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final tabControllerProvider = Provider.of<TabControllerProvider>(context);
    final controller = tabControllerProvider.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: drawerWidget(context, controller),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Business Card
                businessCard(context),
                //Invoice Card
                invoiceCard(context),
                //General Card
                generalCard(context),
                // About Card
                aboutCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
