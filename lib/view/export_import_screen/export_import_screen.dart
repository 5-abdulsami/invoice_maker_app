import 'package:flutter/material.dart';

class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Import'),
      ),
      body: const Center(
        child: Text('Export & Import Screen'),
      ),
    );
  }
}
