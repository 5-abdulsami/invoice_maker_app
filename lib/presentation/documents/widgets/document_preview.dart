import 'dart:collection';
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

  /// Renders [template] ahead of time so its preview appears without a
  /// loader when it is scrolled into view.
  ///
  /// Resolves once the render has finished, so callers can warm several
  /// templates one after another instead of all at once.
  static Future<void> precache(
    BuildContext context, {
    required SalesDocument document,
    InvoiceTemplate? template,
  }) async {
    try {
      await _PreviewCache.render(context, document, template).future;
    } on Object {
      // Surfaced by the preview itself, with a retry, if it is ever shown.
    }
  }

  /// Renders [document] in every template, starting with its own and
  /// spreading outwards in picker order, so the template picker opens onto
  /// finished pages.
  ///
  /// One at a time: rendering all of them together would stall the screen on
  /// a slower phone. Stops early once [context] is unmounted.
  static Future<void> precacheAll(
    BuildContext context, {
    required SalesDocument document,
  }) async {
    const templates = InvoiceTemplate.values;
    final start = templates.indexOf(document.template);
    final order = List<int>.generate(templates.length, (i) => i)
      ..sort((a, b) => (a - start).abs().compareTo((b - start).abs()));

    for (final index in order) {
      if (!context.mounted) return;
      await precache(context, document: document, template: templates[index]);
    }
  }

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  _PreviewEntry? _entry;

  @override
  void initState() {
    super.initState();
    // Resolved straight away rather than after the first frame, so a page
    // that is already cached never flashes the loader.
    _entry = _PreviewCache.render(
      context,
      widget.document,
      widget.templateOverride,
    );
  }

  @override
  void didUpdateWidget(DocumentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final key = _PreviewCache.keyFor(
      context,
      widget.document,
      widget.templateOverride,
    );
    if (key != _entry?.key) _render();
  }

  void _render() {
    if (!mounted) return;
    setState(() {
      _entry = _PreviewCache.render(
        context,
        widget.document,
        widget.templateOverride,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final entry = _entry;

    // Centred so the page keeps its A4 proportions even when the parent hands
    // down a box of another shape; the frame then hugs the paper exactly.
    return Center(
      child: AspectRatio(
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
                  future: entry?.future,
                  // A page rendered earlier, by the picker's warm-up or a
                  // previous visit, shows on the first frame with no loader.
                  initialData: entry?.bytes,
                  builder: (context, snapshot) {
                    if (entry == null) return const InlineLoader();

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
                    if (bytes != null && bytes.isNotEmpty) {
                      return Image.memory(
                        bytes,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      );
                    }

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const InlineLoader();
                    }

                    return const AppErrorState(
                      message: AppCopy.noPreviewAvailable,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One rendered page, shared by every preview that shows it.
class _PreviewEntry {
  _PreviewEntry(this.key, this.future);

  final String key;
  final Future<Uint8List?> future;

  /// Set once [future] completes, so a later preview can skip the loader.
  Uint8List? bytes;
}

/// Recently rendered pages, keyed by everything that changes the output.
///
/// Rendering a template takes a noticeable moment, and the picker, the
/// detail screen and the full-screen preview often ask for the same page.
class _PreviewCache {
  static const int _capacity = 16;

  static final LinkedHashMap<String, _PreviewEntry> _entries =
      LinkedHashMap<String, _PreviewEntry>();

  /// Compared as encoded content rather than by identity, because a document
  /// being edited keeps the same id while its contents change.
  static String keyFor(
    BuildContext context,
    SalesDocument document,
    InvoiceTemplate? template,
  ) {
    final settings = context.read<SettingsController>();
    return jsonEncode({
      'document': document.toJson(),
      'template': (template ?? document.template).name,
      'grouping': settings.settings.numberGrouping.name,
      'dateFormat': settings.dateFormat.name,
    });
  }

  static _PreviewEntry render(
    BuildContext context,
    SalesDocument document,
    InvoiceTemplate? template,
  ) {
    final key = keyFor(context, document, template);

    final cached = _entries.remove(key);
    if (cached != null) {
      // Re-inserted to mark it most recently used.
      _entries[key] = cached;
      return cached;
    }

    final settings = context.read<SettingsController>();
    final service = context.read<DocumentPdfService>();

    final future = service.execute(
      document: document,
      action: PdfAction.preview,
      grouping: settings.settings.numberGrouping,
      dateFormat: settings.dateFormat,
      templateOverride: template,
    );
    final entry = _PreviewEntry(key, future);

    future.then(
      (bytes) => entry.bytes = bytes,
      // A failed render is dropped so a retry starts afresh.
      onError: (Object _) {
        if (identical(_entries[key], entry)) _entries.remove(key);
      },
    );

    _entries[key] = entry;
    while (_entries.length > _capacity) {
      _entries.remove(_entries.keys.first);
    }
    return entry;
  }
}
