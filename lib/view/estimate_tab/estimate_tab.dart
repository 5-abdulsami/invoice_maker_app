import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/tab_controller_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/estimate_tab/new_estimate_screen.dart';
import 'package:invoicemaker/view/widgets/drawer.dart';
import 'package:provider/provider.dart';

class EstimateScreen extends StatefulWidget {
  const EstimateScreen({super.key});

  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  @override
  Widget build(BuildContext context) {
    final tabControllerProvider = Provider.of<TabControllerProvider>(context);
    final controller = tabControllerProvider.controller;

    var width = MediaQuery.of(context).size.width * 1;
    var height = MediaQuery.of(context).size.height * 1;

    List filters = <String>["All", "Pending", "Approved", "Overdue", "Cancel"];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimate Screen'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: whiteColor,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      drawer: drawerWidget(context, controller),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Filters Row
              SizedBox(
                width: width * 0.84,
                height: height * 0.056,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                          clipBehavior: Clip.hardEdge,
                          color: whiteColor,
                          elevation: 2,
                          child: SizedBox(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                child: Text(filters[index]),
                              ),
                            ),
                          ));
                    }),
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.filter_alt_outlined,
                size: 30,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: height * 0.015,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 7,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 120,
                      color: lightBlueColor,
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: blueColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NewEstimateScreen()));
        },
        child: const Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
    );
  }
}
