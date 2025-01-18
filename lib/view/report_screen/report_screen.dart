import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.check,
                color: whiteColor,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: const Center(
        child: Text('Report'),
      ),
    );
  }
}
