import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/presentation/invoice/widgets/invoice_preview.dart';

/// Swipes through the seven PDF layouts and returns the chosen one.
class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key, required this.args});

  final TemplateSelectionArgs args;

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  static const List<InvoiceTemplate> _templates = InvoiceTemplate.values;

  late int _index = _templates.indexOf(widget.args.invoice.template);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: AppBar(
        title: const Text(AppStrings.selectTemplate),
        actions: [
          IconButton(
            tooltip: 'Use this template',
            onPressed: () => Navigator.of(context).pop(_templates[_index]),
            icon: const Icon(Icons.check),
          ),
          Gap.wSm,
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: _templates.length,
              itemBuilder: (context, index, realIndex) => ColoredBox(
                color: AppColors.white,
                child: InvoicePreview(
                  invoice: widget.args.invoice,
                  template: _templates[index],
                ),
              ),
              options: CarouselOptions(
                initialPage: _index,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                enableInfiniteScroll: false,
                animateToClosest: true,
                viewportFraction: 0.9,
                enlargeFactor: 0.22,
                height: double.infinity,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) =>
                    setState(() => _index = index),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              '${_templates[_index].label}  (${_index + 1}/${_templates.length})',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
