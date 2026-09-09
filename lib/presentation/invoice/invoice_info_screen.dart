import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:provider/provider.dart';

/// Edits an invoice's number, dates, PO number and title.
class InvoiceInfoScreen extends StatefulWidget {
  const InvoiceInfoScreen({super.key, required this.args});

  final InvoiceInfoArgs args;

  @override
  State<InvoiceInfoScreen> createState() => _InvoiceInfoScreenState();
}

class _InvoiceInfoScreenState extends State<InvoiceInfoScreen> {
  late final TextEditingController _numberController =
      TextEditingController(text: widget.args.invoice.invoiceNumber);
  late final TextEditingController _poController =
      TextEditingController(text: widget.args.invoice.poNumber);
  late final TextEditingController _titleController =
      TextEditingController(text: widget.args.invoice.invoiceTitle);

  @override
  void dispose() {
    _numberController.dispose();
    _poController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final provider = context.read<InvoiceProvider>();
    final number = _numberController.text.trim();

    if (number.isEmpty) {
      context.showSnackBar('Invoice number is required.', isError: true);
      return;
    }
    if (!provider.isInvoiceNumberUnique(
      number,
      exceptId: widget.args.invoice.id,
    )) {
      context.showSnackBar(AppStrings.duplicateInvoiceNumber, isError: true);
      return;
    }

    provider.updateDraft(
      (draft) => draft.copyWith(
        invoiceNumber: number,
        poNumber: _poController.text.trim(),
        invoiceTitle: _titleController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickCreationDate(DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      initialDate: current,
    );
    if (picked == null || !mounted) return;
    context.read<InvoiceProvider>().setCreationDate(picked);
  }

  Future<void> _pickDueDate(DateTime current, DateTime creationDate) async {
    final picked = await showDatePicker(
      context: context,
      // Never allow a due date before the invoice was created.
      firstDate: creationDate,
      lastDate: DateTime(2100),
      initialDate: current.isBefore(creationDate) ? creationDate : current,
    );
    if (picked == null || !mounted) return;
    context.read<InvoiceProvider>().setDueDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final invoice = context.watch<InvoiceProvider>().invoice;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.invoiceInfo),
        actions: [
          IconButton(
            tooltip: AppStrings.save,
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
          Gap.wSm,
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Invoice Number',
                    child: AppTextField(
                      controller: _numberController,
                      hintText: 'Enter invoice number',
                      maxLength: 15,
                    ),
                  ),
                  LabeledField(
                    label: 'Creation Date',
                    child: _DateTile(
                      label: invoice.creationDate.formatted,
                      onTap: () => _pickCreationDate(invoice.creationDate),
                    ),
                  ),
                  Gap.md,
                  LabeledField(
                    label: AppStrings.dueTerms,
                    child: _DateTile(
                      label: invoice.creationDate
                              .isSameDay(invoice.dueDate)
                          ? 'Due on Receipt'
                          : '${invoice.dueTerms} day(s)',
                      showIcon: false,
                    ),
                  ),
                  Gap.md,
                  LabeledField(
                    label: 'Due Date',
                    child: _DateTile(
                      label: invoice.dueDate.formatted,
                      onTap: () => _pickDueDate(
                        invoice.dueDate,
                        invoice.creationDate,
                      ),
                    ),
                  ),
                  Gap.md,
                  LabeledField(
                    label: 'P.O.#',
                    child: AppTextField(
                      controller: _poController,
                      hintText: 'Enter purchase order number',
                    ),
                  ),
                  LabeledField(
                    label: 'Invoice Title Name',
                    child: AppTextField(
                      controller: _titleController,
                      hintText: 'INVOICE',
                    ),
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

/// A grey strip showing a date, tappable to open the picker.
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    this.onTap,
    this.showIcon = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return FieldTile(
      color: AppColors.lightGrey,
      onTap: onTap,
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: showIcon ? const Icon(Icons.calendar_month) : null,
      ),
    );
  }
}
