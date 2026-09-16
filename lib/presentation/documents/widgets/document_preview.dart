import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/services/pdf/document_pdf_service.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// Shows page one of a document as it will print.
///
/// The preview is the real PDF rasterised, not a second rendering of the
/// layout in Flutter widgets, so what the user sees here cannot drift from
/// the file they share.
class DocumentPreview extends StatefulWidget {
  const DocumentPreview({
    super.key,
    required this.document,
    this.templateOverride,
    this.onTap,
  });

  final SalesDocument document;

  /// Renders another template instead of the document's own, for the picker.
  final InvoiceTemplate? templateOverride;

  final VoidCallback? onTap;

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  Future<Uint8List?>? _preview;
  String? _renderedSignature;

  @override
  void initState() {
    super.initState();
    // Deferred: the render needs providers, which are not available until the
    // first build has a context.
    WidgetsBinding.instance.addPostFrameCallback((_) => _render());
  }

  @override
  void didUpdateWidget(DocumentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature != _renderedSignature) _render();
  }

  /// Everything that changes the rendered page.
  ///
  /// Compared as encoded content rather than by identity, because a document
  /// being edited keeps the same id while its contents change.
  String get _signature => jsonEncode({
        'document': widget.document.toJson(),
        'template': widget.templateOverride?.name,
      });

  void _render() {
    if (!mounted) return;

    final settings = context.read<SettingsController>();
    final service = context.read<DocumentPdfService>();
    final signature = _signature;

    setState(() {
      _renderedSignature = signature;
      _preview = service.execute(
        document: widget.document,
        action: PdfAction.preview,
        grouping: settings.settings.numberGrouping,
        dateFormat: settings.dateFormat,
        templateOverride: widget.templateOverride,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AspectRatio(
      aspectRatio: Layout.pageAspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Always a white page, in both themes: this is paper.
          color: Colors.white,
          borderRadius: Radii.smAll,
          border: Border.all(color: palette.border),
        ),
        child: ClipRRect(
          borderRadius: Radii.smAll,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              child: FutureBuilder<Uint8List?>(
                future: _preview,
                builder: (context, snapshot) {
                  if (_preview == null ||
                      snapshot.connectionState != ConnectionState.done) {
                    return const InlineLoader();
                  }

                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    return AppErrorState(
                      message: error is AppException
                          ? error.message
                          : AppCopy.noPreviewAvailable,
                      onRetry: _render,
                    );
                  }

                  final bytes = snapshot.data;
                  if (bytes == null || bytes.isEmpty) {
                    return const AppErrorState(
                      message: AppCopy.noPreviewAvailable,
                    );
                  }

                  return Image.memory(bytes, fit: BoxFit.contain);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
