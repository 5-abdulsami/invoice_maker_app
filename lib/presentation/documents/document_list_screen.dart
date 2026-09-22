import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/domain/document_query.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/filter_chip_row.dart';
import 'package:invoicemaker/presentation/common/widgets/search_field.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/presentation/documents/document_actions.dart';
import 'package:invoicemaker/presentation/documents/widgets/document_card.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// The list of invoices or estimates, with search, status filters and sort.
class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key, required this.kind});

  final DocumentKind kind;

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen>
    with AsyncAction {
  late final List<DocumentFilter> _filters =
      DocumentFilter.forKind(widget.kind);

  late DocumentFilter _filter = _filters.first;
  DocumentSort _sort = DocumentSort.fallback;
  String _query = '';

  Future<void> _create() async {
    await AppNavigator.openEditor(context, kind: widget.kind);
  }

  Future<void> _open(SalesDocument document) async {
    await AppNavigator.openDocumentDetail(context, document);
  }

  Future<void> _pickSort() async {
    final sort = await AppSheet.choose<DocumentSort>(
      context,
      title: AppStrings.sortBy,
      options: DocumentSort.values,
      selected: _sort,
      labelOf: (option) => option.label,
    );
    if (sort == null) return;
    setState(() => _sort = sort);
  }

  Future<void> _openActions(SalesDocument document) async {
    final action = await DocumentActionsSheet.show(
      context,
      document: document,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case DocumentAction.share:
        await run(
          () => DocumentActionRunner.output(
            context,
            document: document,
            action: PdfAction.share,
          ),
        );
      case DocumentAction.print:
        await run(
          () => DocumentActionRunner.output(
            context,
            document: document,
            action: PdfAction.print,
          ),
        );
      case DocumentAction.edit:
        await AppNavigator.openEditor(
          context,
          kind: document.kind,
          documentId: document.id,
        );
      case DocumentAction.changeStatus:
        await DocumentActionRunner.changeStatus(context, document: document);
      case DocumentAction.duplicate:
        final copy =
            await context.read<DocumentController>().duplicate(document);
        if (!mounted) return;
        context.showMessage('${copy.number} created');
      case DocumentAction.convertToInvoice:
        final invoice = await context
            .read<DocumentController>()
            .convertToInvoice(document);
        if (!mounted) return;
        context.showMessage('Invoice ${invoice.number} created');
      case DocumentAction.delete:
        final deleted =
            await DocumentActionRunner.delete(context, document: document);
        if (deleted && mounted) context.showMessage(AppCopy.deletedMessage);
    }
  }

  /// How many documents each filter would show, for the chip counts.
  int? _countFor(DocumentFilter filter, List<SalesDocument> all) {
    if (filter.isAll) return null;
    return all.where(filter.matches).length;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocumentController>();
    final settings = context.watch<SettingsController>();

    final all = controller.ofKind(widget.kind);
    final documents = DocumentQuery.apply(
      all,
      kind: widget.kind,
      filter: _filter,
      sort: _sort,
      query: _query,
    );

    final isSearching = _query.trim().isNotEmpty;
    final hasAny = all.isNotEmpty;

    return AppScaffold(
      title: widget.kind.plural,
      maxContentWidth: Layout.listWidth,
      actions: [
        if (hasAny)
          IconButton(
            onPressed: _pickSort,
            icon: const Icon(Icons.sort),
            tooltip: AppStrings.sortBy,
          ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        // Every tab stays alive in the shell's IndexedStack, so each button
        // needs its own hero tag; the default one is shared and asserts.
        heroTag: 'fab-${widget.kind.name}',
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text('New ${widget.kind.label.toLowerCase()}'),
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        message: 'Preparing the PDF',
        child: Column(
          children: [
            if (hasAny) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Insets.gutter,
                  Insets.md,
                  Insets.gutter,
                  Insets.md,
                ),
                child: AppSearchField(
                  hint: 'Search ${widget.kind.plural.toLowerCase()}',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              FilterChipRow<DocumentFilter>(
                options: _filters,
                selected: _filter,
                labelOf: (option) => option.label,
                countOf: (option) => _countFor(option, all),
                onSelected: (option) => setState(() => _filter = option),
              ),
              Gap.h12,
            ],
            Expanded(
              child: documents.isEmpty
                  ? _emptyState(isSearching: isSearching, hasAny: hasAny)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Insets.gutter,
                        Insets.xs,
                        Insets.gutter,
                        Insets.scrollBottom,
                      ),
                      itemCount: documents.length,
                      separatorBuilder: (_, __) => Gap.h12,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        return DocumentCard(
                          document: document,
                          money: settings.moneyFormatFor(document.currency),
                          dateFormat: settings.dateFormat,
                          onTap: () => _open(document),
                          onLongPress: () => _openActions(document),
                          onStatusTap: document.isInvoice
                              ? () => DocumentActionRunner.changeStatus(
                                    context,
                                    document: document,
                                  )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({required bool isSearching, required bool hasAny}) {
    if (isSearching || hasAny) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: AppCopy.noSearchResultsTitle,
        message: AppCopy.noSearchResultsBody,
      );
    }

    return AppEmptyState(
      icon: widget.kind.isInvoice
          ? Icons.receipt_long_outlined
          : Icons.description_outlined,
      title: 'No ${widget.kind.plural.toLowerCase()} yet',
      message: widget.kind.isInvoice
          ? AppCopy.noDocumentsBody
          : 'Send a quote before you invoice, and convert it in one tap.',
    );
  }
}
