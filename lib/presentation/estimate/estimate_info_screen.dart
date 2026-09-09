import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/core/extensions/date_extensions.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:provider/provider.dart';

/// Edits an estimate's number, dates and title.
class EstimateInfoScreen extends StatefulWidget {
  const EstimateInfoScreen({super.key});

  @override
  State<EstimateInfoScreen> createState() => _EstimateInfoScreenState();
}

class _EstimateInfoScreenState extends State<EstimateInfoScreen> {
  late final EstimateProvider _provider = context.read<EstimateProvider>();

  late final TextEditingController _numberController =
      TextEditingController(text: _provider.estimate.estimateNumber);
  late final TextEditingController _titleController =
      TextEditingController(text: _provider.estimate.estimateTitle);

  @override
  void dispose() {
    _numberController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final number = _numberController.text.trim();
    if (number.isEmpty) {
      context.showSnackBar('Estimate number is required.', isError: true);
      return;
    }
    if (!_provider.isEstimateNumberUnique(
      number,
      exceptId: _provider.estimate.id,
    )) {
      context.showSnackBar(
        'Estimate number must be unique.',
        isError: true,
      );
      return;
    }

    _provider.updateDraft(
      (draft) => draft.copyWith(
        estimateNumber: number,
        estimateTitle: _titleController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickDate({required bool isCreation}) async {
    final estimate = _provider.estimate;
    final initial = isCreation ? estimate.creationDate : estimate.dueDate;

    final picked = await showDatePicker(
      context: context,
      firstDate: isCreation ? DateTime(1950) : estimate.creationDate,
      lastDate: DateTime(2100),
      initialDate: initial.isBefore(estimate.creationDate) && !isCreation
          ? estimate.creationDate
          : initial,
    );
    if (picked == null || !mounted) return;

    if (isCreation) {
      _provider.setCreationDate(picked);
    } else {
      _provider.setDueDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estimate = context.watch<EstimateProvider>().estimate;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.estimateInfo),
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
                    label: 'Estimate Number',
                    child: AppTextField(
                      controller: _numberController,
                      hintText: 'Enter estimate number',
                      maxLength: 15,
                    ),
                  ),
                  LabeledField(
                    label: 'Creation Date',
                    child: _DateTile(
                      label: estimate.creationDate.formatted,
                      onTap: () => _pickDate(isCreation: true),
                    ),
                  ),
                  Gap.md,
                  LabeledField(
                    label: AppStrings.dueTerms,
                    child: _DateTile(
                      label: estimate.creationDate.isSameDay(estimate.dueDate)
                          ? 'Valid on Receipt'
                          : '${estimate.dueTerms} day(s)',
                      showIcon: false,
                    ),
                  ),
                  Gap.md,
                  LabeledField(
                    label: 'Due Date',
                    child: _DateTile(
                      label: estimate.dueDate.formatted,
                      onTap: () => _pickDate(isCreation: false),
                    ),
                  ),
                  Gap.md,
                  LabeledField(
                    label: 'Estimate Title Name',
                    child: AppTextField(
                      controller: _titleController,
                      hintText: 'ESTIMATE',
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
  const _DateTile({required this.label, this.onTap, this.showIcon = true});

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
