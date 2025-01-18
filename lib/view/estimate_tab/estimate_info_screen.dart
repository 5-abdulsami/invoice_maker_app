import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/estimate_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/view/widgets/custom_textfield.dart';

class EstimateInfoScreen extends StatelessWidget {
  const EstimateInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var numberController = TextEditingController();
    var titleController = TextEditingController();

    numberController.text = 'EST00001';

    //Initialize Providers

    //initialize DatesProvider
    final estimateProvider = Provider.of<EstimateProvider>(context);

    //initialize EstimateProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimate Info'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.check,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            color: whiteColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimate Number',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  CustomTextField(
                    controller: numberController,
                    hintText: 'Enter estimate number',
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Creation Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: lightGreyColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 55,
                    child: ListTile(
                      leading: Text(
                        DateFormat('yMMMd')
                            .format(estimateProvider.estimate.creationDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        DateTime? pickedCreationDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          initialDate: estimateProvider.estimate.creationDate,
                        );
                        if (pickedCreationDate != null) {
                          estimateProvider.setCreationDate(pickedCreationDate);
                          estimateProvider.updateDueTerms();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Due Terms',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: lightGreyColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 55,
                    child: ListTile(
                      leading: Text(
                        "${estimateProvider.estimate.dueTerms} days",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(
                        Icons.arrow_drop_down,
                        color: darkGreyColor,
                      ),
                      onTap: () async {
                        // Logic to select due terms
                        // For simplicity, not implemented here
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: lightGreyColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 55,
                    child: ListTile(
                      leading: Text(
                        DateFormat('yMMMd')
                            .format(estimateProvider.estimate.dueDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        DateTime? pickedDueDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          initialDate: estimateProvider.estimate.dueDate,
                        );
                        if (pickedDueDate != null) {
                          estimateProvider.setDueDate(pickedDueDate);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Estimate Title Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGreyColor,
                      height: 2.1,
                    ),
                  ),
                  CustomTextField(
                    controller: titleController,
                    hintText: 'ESTIMATE',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
