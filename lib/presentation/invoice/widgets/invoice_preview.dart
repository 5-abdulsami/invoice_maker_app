import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/client_provider.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:invoicemaker/services/pdf/pdf_service.dart';
import 'package:provider/provider.dart';

/// Renders page one of an invoice's PDF as an image.
///
/// Replaces the old templates-as-widgets arrangement: the layout is built by
/// [PdfService], and this widget only handles loading and failure states.
class InvoicePreview extends StatefulWidget {
  const InvoicePreview({
    super.key,
    required this.invoice,
    this.template,
    this.pdfService = const PdfService(),
  });

  final Invoice invoice;

  /// Renders this template instead of the invoice's own, for the picker.
  final InvoiceTemplate? template;
  final PdfService pdfService;

  @override
  State<InvoicePreview> createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends State<InvoicePreview> {
  Future<Uint8List?>? _preview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(InvoicePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = oldWidget.invoice != widget.invoice ||
        oldWidget.template != widget.template;
    if (changed) _load();
  }

  void _load() {
    final business = context.read<BusinessProvider>().business;
    final client = context.read<ClientProvider>().client;
    final signature = context.read<SignatureProvider>().signature;

    setState(() {
      _preview = widget.pdfService.execute(
        invoice: widget.invoice,
        business: business,
        client: client,
        signature: signature,
        action: PdfAction.preview,
        templateOverride: widget.template,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _preview,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          return _PreviewMessage(
            message: error is AppException
                ? error.message
                : AppStrings.noPreview,
            onRetry: _load,
          );
        }

        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return const _PreviewMessage(message: AppStrings.noPreview);
        }

        return Image.memory(bytes, fit: BoxFit.contain);
      },
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
            if (onRetry != null) ...[
              Gap.sm,
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
