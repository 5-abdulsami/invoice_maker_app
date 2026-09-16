import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/core/utils/validators.dart';
import 'package:invoicemaker/data/models/adjustment.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';

/// Asks for the document-level discount, as a percentage or a fixed amount.
sealed class DiscountSheet {
  static Future<Adjustment?> show(
    BuildContext context, {
    required Adjustment current,
    required MoneyFormat money,
  }) {
    return AppSheet.show<Adjustment>(
      context: context,
      title: AppStrings.discount,
      subtitle: 'Applied to the subtotal before tax.',
      builder: (sheetContext) => _DiscountForm(current: current, money: money),
    );
  }
}

class _DiscountForm extends StatefulWidget {
  const _DiscountForm({required this.current, required this.money});

  final Adjustment current;
  final MoneyFormat money;

  @override
  State<_DiscountForm> createState() => _DiscountFormState();
}

class _DiscountFormState extends State<_DiscountForm> {
  late AdjustmentMode _mode = widget.current.mode;
  late final TextEditingController _controller = TextEditingController(
    text: widget.current.isZero ? '' : _initialText(),
  );

  String _initialText() {
    final value = widget.current.value;
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _mode == AdjustmentMode.percent
        ? Validators.parsePercent(_controller.text)
        : Validators.parseAmount(_controller.text);

    Navigator.of(context).pop(Adjustment(mode: _mode, value: raw));
  }

  @override
  Widget build(BuildContext context) {
    final isPercent = _mode == AdjustmentMode.percent;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Insets.gutter,
        0,
        Insets.gutter,
        Insets.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<AdjustmentMode>(
            segments: [
              const ButtonSegment(
                value: AdjustmentMode.percent,
                label: Text('Percent'),
                icon: Icon(Icons.percent, size: IconSizes.xs),
              ),
              ButtonSegment(
                value: AdjustmentMode.amount,
                label: Text(widget.money.currency.code),
                icon: const Icon(Icons.numbers, size: IconSizes.xs),
              ),
            ],
            selected: {_mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _mode = selection.first),
          ),
          Gap.h16,
          if (isPercent)
            AppTextField.percent(
              controller: _controller,
              label: 'Discount rate',
              onSubmitted: (_) => _submit(),
            )
          else
            AppTextField.money(
              controller: _controller,
              currencySymbol: widget.money.currency.symbol,
              label: 'Discount amount',
              decimalDigits: widget.money.currency.decimalDigits,
              onSubmitted: (_) => _submit(),
            ),
          Gap.h20,
          AppButton(label: AppStrings.apply, onPressed: _submit),
          Gap.h8,
          AppButton.secondary(
            label: 'Remove discount',
            onPressed: () =>
                Navigator.of(context).pop(const Adjustment.none()),
          ),
        ],
      ),
    );
  }
}

/// The tax name and rate applied to a document.
typedef TaxSelection = ({String label, double percent});

sealed class TaxSheet {
  static Future<TaxSelection?> show(
    BuildContext context, {
    required String currentLabel,
    required double currentPercent,
  }) {
    return AppSheet.show<TaxSelection>(
      context: context,
      title: AppStrings.tax,
      subtitle: 'Charged on the discounted item amounts.',
      builder: (sheetContext) => _TaxForm(
        currentLabel: currentLabel,
        currentPercent: currentPercent,
      ),
    );
  }
}

class _TaxForm extends StatefulWidget {
  const _TaxForm({required this.currentLabel, required this.currentPercent});

  final String currentLabel;
  final double currentPercent;

  @override
  State<_TaxForm> createState() => _TaxFormState();
}

class _TaxFormState extends State<_TaxForm> {
  late final TextEditingController _labelController =
      TextEditingController(text: widget.currentLabel);
  late final TextEditingController _rateController = TextEditingController(
    text: widget.currentPercent == 0
        ? ''
        : widget.currentPercent.toStringAsFixed(
            widget.currentPercent == widget.currentPercent.roundToDouble()
                ? 0
                : 2,
          ),
  );

  @override
  void dispose() {
    _labelController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _submit() {
    final percent = Validators.parsePercent(_rateController.text);
    final label = _labelController.text.trim();

    Navigator.of(context).pop(
      (
        label: label.isEmpty && percent > 0 ? AppStrings.tax : label,
        percent: percent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Insets.gutter,
        0,
        Insets.gutter,
        Insets.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _labelController,
            label: AppStrings.taxLabel,
            hint: 'VAT, GST, Sales tax',
            textCapitalization: TextCapitalization.characters,
          ),
          Gap.h16,
          AppTextField.percent(
            controller: _rateController,
            label: AppStrings.taxRate,
            onSubmitted: (_) => _submit(),
          ),
          Gap.h20,
          AppButton(label: AppStrings.apply, onPressed: _submit),
          Gap.h8,
          AppButton.secondary(
            label: 'Remove tax',
            onPressed: () =>
                Navigator.of(context).pop((label: '', percent: 0.0)),
          ),
        ],
      ),
    );
  }
}

/// Asks for a single money amount, such as shipping or a part payment.
sealed class AmountSheet {
  static Future<double?> show(
    BuildContext context, {
    required String title,
    required String fieldLabel,
    required Currency currency,
    double current = 0,
    double? max,
    String? subtitle,
    String? helper,
    String clearLabel = 'Clear',
  }) {
    return AppSheet.show<double>(
      context: context,
      title: title,
      subtitle: subtitle,
      builder: (sheetContext) => _AmountForm(
        fieldLabel: fieldLabel,
        currency: currency,
        current: current,
        max: max,
        helper: helper,
        clearLabel: clearLabel,
      ),
    );
  }
}

class _AmountForm extends StatefulWidget {
  const _AmountForm({
    required this.fieldLabel,
    required this.currency,
    required this.current,
    required this.clearLabel,
    this.max,
    this.helper,
  });

  final String fieldLabel;
  final Currency currency;
  final double current;
  final double? max;
  final String? helper;
  final String clearLabel;

  @override
  State<_AmountForm> createState() => _AmountFormState();
}

class _AmountFormState extends State<_AmountForm> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.current == 0
        ? ''
        : widget.current.toStringAsFixed(widget.currency.decimalDigits),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = Validators.parseAmount(_controller.text, max: widget.max);
    Navigator.of(context).pop(Money.roundFor(amount, widget.currency));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Insets.gutter,
        0,
        Insets.gutter,
        Insets.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField.money(
            controller: _controller,
            currencySymbol: widget.currency.symbol,
            label: widget.fieldLabel,
            helper: widget.helper,
            decimalDigits: widget.currency.decimalDigits,
            max: widget.max,
            onSubmitted: (_) => _submit(),
          ),
          Gap.h20,
          AppButton(label: AppStrings.apply, onPressed: _submit),
          Gap.h8,
          AppButton.secondary(
            label: widget.clearLabel,
            onPressed: () => Navigator.of(context).pop(0),
          ),
        ],
      ),
    );
  }
}

/// Asks for a block of text, such as notes or payment terms.
sealed class TextBlockSheet {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String fieldLabel,
    String current = '',
    String? hint,
    String? subtitle,
  }) {
    return AppSheet.show<String>(
      context: context,
      title: title,
      subtitle: subtitle,
      builder: (sheetContext) => _TextBlockForm(
        fieldLabel: fieldLabel,
        current: current,
        hint: hint,
      ),
    );
  }
}

class _TextBlockForm extends StatefulWidget {
  const _TextBlockForm({
    required this.fieldLabel,
    required this.current,
    this.hint,
  });

  final String fieldLabel;
  final String current;
  final String? hint;

  @override
  State<_TextBlockForm> createState() => _TextBlockFormState();
}

class _TextBlockFormState extends State<_TextBlockForm> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.current);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Insets.gutter,
        0,
        Insets.gutter,
        Insets.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField.multiline(
            controller: _controller,
            label: widget.fieldLabel,
            hint: widget.hint,
            maxLines: 10,
          ),
          Gap.h20,
          AppButton(
            label: AppStrings.save,
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          ),
        ],
      ),
    );
  }
}
