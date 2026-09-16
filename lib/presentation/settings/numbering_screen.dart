import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/validators.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// How document numbers are generated.
class NumberingScreen extends StatefulWidget {
  const NumberingScreen({super.key});

  @override
  State<NumberingScreen> createState() => _NumberingScreenState();
}

class _NumberingScreenState extends State<NumberingScreen> with AsyncAction {
  late final TextEditingController _invoicePrefix;
  late final TextEditingController _estimatePrefix;
  late final TextEditingController _padding;
  late final TextEditingController _nextInvoice;
  late final TextEditingController _nextEstimate;

  /// Widest padding worth offering; beyond this the number stops reading as
  /// a number.
  static const int _maxPadding = 8;

  @override
  void initState() {
    super.initState();
    final values = context.read<SettingsController>().settings;

    _invoicePrefix = TextEditingController(text: values.invoicePrefix);
    _estimatePrefix = TextEditingController(text: values.estimatePrefix);
    _padding = TextEditingController(text: values.numberPadding.toString());
    _nextInvoice =
        TextEditingController(text: values.nextInvoiceSequence.toString());
    _nextEstimate =
        TextEditingController(text: values.nextEstimateSequence.toString());
  }

  @override
  void dispose() {
    for (final controller in [
      _invoicePrefix,
      _estimatePrefix,
      _padding,
      _nextInvoice,
      _nextEstimate,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final controller = context.read<SettingsController>();
    var didSave = false;

    await run(
      () async {
        await controller.setNumbering(
          invoicePrefix: _invoicePrefix.text.trim(),
          estimatePrefix: _estimatePrefix.text.trim(),
          padding: Validators.parseDays(_padding.text, fallback: 4)
              .clamp(1, _maxPadding),
          nextInvoiceSequence:
              Validators.parseDays(_nextInvoice.text, fallback: 1).clamp(1, 999999),
          nextEstimateSequence:
              Validators.parseDays(_nextEstimate.text, fallback: 1).clamp(1, 999999),
        );
        didSave = true;
      },
      successMessage: AppCopy.savedMessage,
    );
    if (!didSave || !mounted) return;

    Navigator.of(context).pop();
  }

  /// The number the next document would get, from the fields as typed.
  String _previewFor(DocumentKind kind) {
    final prefix = (kind.isInvoice ? _invoicePrefix : _estimatePrefix)
        .text
        .trim();
    final sequence = Validators.parseDays(
      (kind.isInvoice ? _nextInvoice : _nextEstimate).text,
      fallback: 1,
    );
    final width = Validators.parseDays(_padding.text, fallback: 4)
        .clamp(1, _maxPadding);

    final digits = sequence.toString().padLeft(width, '0');
    return prefix.isEmpty ? digits : '$prefix-$digits';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.numbering,
      bottomBar: BottomActionBar(
        children: [
          AppButton(
            label: AppStrings.save,
            icon: Icons.check,
            isBusy: isBusy,
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          Insets.lg,
          Insets.gutter,
          Insets.xl,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Next numbers'),
                _PreviewRow(
                  label: DocumentKind.invoice.label,
                  value: _previewFor(DocumentKind.invoice),
                ),
                Gap.h8,
                _PreviewRow(
                  label: DocumentKind.estimate.label,
                  value: _previewFor(DocumentKind.estimate),
                ),
                Gap.h12,
                Text(
                  'A number already in use is skipped automatically, so a '
                  'restored backup cannot create a duplicate.',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Gap.h16,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _invoicePrefix,
                        label: 'Invoice prefix',
                        hint: 'INV',
                        maxLength: 8,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: AppTextField(
                        controller: _estimatePrefix,
                        label: 'Estimate prefix',
                        hint: 'EST',
                        maxLength: 8,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                Gap.h16,
                AppTextField.integer(
                  controller: _padding,
                  label: 'Digits',
                  helper: 'How many digits the number is padded to',
                  max: _maxPadding,
                  onChanged: (_) => setState(() {}),
                ),
                Gap.h16,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField.integer(
                        controller: _nextInvoice,
                        label: 'Next invoice',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: AppTextField.integer(
                        controller: _nextEstimate,
                        label: 'Next estimate',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.text.titleMedium)),
          Text(value, style: context.textRoles.documentNumber),
        ],
      ),
    );
  }
}
