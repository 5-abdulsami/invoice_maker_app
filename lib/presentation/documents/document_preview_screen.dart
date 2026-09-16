import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/presentation/documents/document_actions.dart';
import 'package:invoicemaker/presentation/documents/widgets/document_preview.dart';

/// The document full screen, as it will print.
///
/// Reachable from the editor before saving, which is what lets someone check
/// the layout without committing a half-finished document to their history.
class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({super.key, required this.document});

  final SalesDocument document;

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen>
    with AsyncAction {
  Future<void> _output(PdfAction action) async {
    await run(
      () => DocumentActionRunner.output(
        context,
        document: widget.document,
        action: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;

    return AppScaffold(
      title: document.number,
      maxContentWidth: Layout.listWidth,
      bottomBar: BottomActionBar(
        children: [
          AppButton.secondary(
            label: AppStrings.print,
            icon: Icons.print_outlined,
            onPressed: isBusy ? null : () => _output(PdfAction.print),
          ),
          AppButton(
            label: AppStrings.share,
            icon: Icons.ios_share,
            isBusy: isBusy,
            onPressed: () => _output(PdfAction.share),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        message: 'Preparing the PDF',
        child: ListView(
          padding: const EdgeInsets.all(Insets.gutter),
          children: [
            DocumentPreview(document: document),
            Gap.h12,
            Text(
              'Page one of the ${document.template.label} template. '
              'Sharing or printing includes every page.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
