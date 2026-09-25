import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/domain/entitlements.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/status_chip.dart';
import 'package:invoicemaker/presentation/documents/widgets/document_preview.dart';
import 'package:provider/provider.dart';

/// Swipes through the layouts, showing each one rendered with this document's
/// own contents rather than a generic sample.
class TemplatePickerScreen extends StatefulWidget {
  const TemplatePickerScreen({super.key, required this.document});

  final SalesDocument document;

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  static const List<InvoiceTemplate> _templates = InvoiceTemplate.values;

  late final PageController _controller = PageController(
    initialPage: _initialIndex,
    viewportFraction: _viewportFraction,
  );

  late int _index = _initialIndex;

  int get _initialIndex {
    final current = _templates.indexOf(widget.document.template);
    return current == -1 ? 0 : current;
  }

  /// Slightly less than full width, so the neighbouring pages peek in and the
  /// row reads as something to swipe.
  static const double _viewportFraction = 0.82;

  @override
  void initState() {
    super.initState();
    _warmAround(_initialIndex);
  }

  /// Renders the pages either side of [index] in the background, so the
  /// next swipe in either direction lands on a finished page.
  ///
  /// A newer swipe supersedes an older warm-up, so flicking through several
  /// pages never queues renders for the ones already passed.
  void _warmAround(int index) {
    final generation = ++_warmGeneration;
    unawaited(
      DocumentPreview.precacheAround(
        context,
        document: widget.document,
        around: _templates[index],
        keepGoing: () => generation == _warmGeneration,
      ),
    );
  }

  int _warmGeneration = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entitlements = context.read<Entitlements>();
    final template = _templates[_index];

    return AppScaffold(
      title: 'Choose a template',
      maxContentWidth: Layout.listWidth,
      bottomBar: BottomActionBar(
        children: [
          AppButton(
            label: 'Use ${template.label}',
            icon: Icons.check,
            onPressed: () => Navigator.of(context).pop(template),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _templates.length,
              onPageChanged: (index) {
                setState(() => _index = index);
                _warmAround(index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.sm,
                    vertical: Insets.lg,
                  ),
                  child: DocumentPreview(
                    document: widget.document,
                    templateOverride: _templates[index],
                  ),
                );
              },
            ),
          ),
          _Caption(
            template: template,
            position: _index + 1,
            total: _templates.length,
            isPro: template.isPro,
            proNote: entitlements.statusNote,
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({
    required this.template,
    required this.position,
    required this.total,
    required this.isPro,
    required this.proNote,
  });

  final InvoiceTemplate template;
  final int position;
  final int total;
  final bool isPro;
  final String proNote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.gutter,
        0,
        Insets.gutter,
        Insets.lg,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(template.label, style: context.text.titleLarge),
              if (isPro) ...[Gap.w8, const ProBadge()],
              Gap.w8,
              Text(
                '$position / $total',
                style: context.text.labelMedium,
              ),
            ],
          ),
          Gap.h4,
          Text(
            template.description,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
          if (isPro) ...[
            Gap.h8,
            Text(
              proNote,
              textAlign: TextAlign.center,
              style: context.text.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
