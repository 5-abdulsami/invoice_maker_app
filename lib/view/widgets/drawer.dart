import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/business_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/buisness_info_screen/business_info_screen.dart';
import 'package:invoicemaker/view/export_import_screen/export_import_screen.dart';
import 'package:invoicemaker/view/report_screen/report_screen.dart';
import 'package:invoicemaker/view/sync_screen/sync_screen.dart';
import 'package:invoicemaker/view/widgets/dialogs/share_app_dialog.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

Widget drawerWidget(BuildContext context, PersistentTabController controller) {
  final businessProvider = Provider.of<BusinessProvider>(context);
  return Drawer(
    backgroundColor: whiteColor,
    child: ListView(
      children: [
        DrawerHeader(
            decoration: const BoxDecoration(color: blueColor),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BusinessInfoScreen()));
                  },
                  child: Column(
                    children: [
                      businessProvider.business.businessLogo != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(businessProvider
                                  .business.businessLogo!.absolute),
                              radius: 30,
                            )
                          : const CircleAvatar(
                              radius: 30,
                            ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        businessProvider.business.businessName.isNotEmpty
                            ? businessProvider.business.businessName
                            : 'Drawer Header',
                        style: const TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BusinessInfoScreen(),
                            fullscreenDialog: true));
                  },
                  child: Container(
                    height: 30,
                    width: 150,
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: whiteColor, width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.group_add_outlined, color: whiteColor),
                        Text(
                          'Manage Business',
                          style: TextStyle(fontSize: 12, color: whiteColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
              ],
            )),
        ListTile(
          leading: const Icon(
            Icons.insert_chart_outlined_outlined,
            color: blackColor,
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Report',
              style: TextStyle(
                color: blackColor,
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ReportScreen()));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.cloud_upload_outlined,
            color: blackColor,
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Sync',
              style: TextStyle(
                color: blackColor,
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SyncScreen()));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.import_export_outlined,
            color: blackColor,
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Export & Import',
              style: TextStyle(
                color: blackColor,
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExportImportScreen()));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.share_outlined,
            color: blackColor,
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Share App',
              style: TextStyle(
                color: blackColor,
              ),
            ),
          ),
          onTap: () {
            shareAppDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.settings_outlined,
            color: blackColor,
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Settings',
              style: TextStyle(
                color: blackColor,
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            controller.jumpToTab(4);
          },
        ),
      ],
    ),
  );
}
