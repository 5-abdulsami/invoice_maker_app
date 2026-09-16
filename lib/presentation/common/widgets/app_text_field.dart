import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/input_formatters.dart';
import 'package:invoicemaker/core/utils/validators.dart';

/// The app's text field, with its label above rather than floating.
///
/// A static label keeps the row height constant whatever the text scale, so
/// forms do not reflow as the user types.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.helper,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.suffixText,
    this.suffixIcon,
    this.enabled = true,
    this.selectAllOnFocus = false,
    this.textAlign = TextAlign.start,
  });

  /// A field for money, using the given currency symbol as its prefix.
  factory AppTextField.money({
    Key? key,
    required TextEditingController controller,
    required String currencySymbol,
    String? label,
    String? helper,
    int decimalDigits = 2,
    double? max,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label,
      helper: helper,
      hint: 0.toStringAsFixed(decimalDigits),
      prefixText: currencySymbol,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        DecimalInputFormatter(max: max, decimalPlaces: decimalDigits),
      ],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction,
      textAlign: TextAlign.end,
      selectAllOnFocus: true,
    );
  }

  /// A field for a percentage, capped at 100.
  factory AppTextField.percent({
    Key? key,
    required TextEditingController controller,
    String? label,
    String? helper,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label,
      helper: helper,
      hint: '0',
      suffixText: '%',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        DecimalInputFormatter(max: Validators.maxPercent),
      ],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction,
      textAlign: TextAlign.end,
      selectAllOnFocus: true,
    );
  }

  /// A field for a quantity, which may be fractional.
  factory AppTextField.quantity({
    Key? key,
    required TextEditingController controller,
    String? label,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label,
      hint: '1',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [DecimalInputFormatter(decimalPlaces: 3)],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction,
      textAlign: TextAlign.end,
      selectAllOnFocus: true,
    );
  }

  /// A field for a whole number.
  factory AppTextField.integer({
    Key? key,
    required TextEditingController controller,
    String? label,
    String? helper,
    String? suffixText,
    int? max,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label,
      helper: helper,
      hint: '0',
      suffixText: suffixText,
      keyboardType: TextInputType.number,
      inputFormatters: [IntegerInputFormatter(max: max)],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction,
      selectAllOnFocus: true,
    );
  }

  /// A field for several lines of text, such as notes or terms.
  factory AppTextField.multiline({
    Key? key,
    required TextEditingController controller,
    String? label,
    String? hint,
    String? helper,
    int minLines = 3,
    int maxLines = 8,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helper: helper,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffixIcon;
  final bool enabled;

  /// Selects the existing text when focused, so typing replaces it. Used by
  /// numeric fields where the user almost always wants a new value.
  final bool selectAllOnFocus;

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      // Releases focus and the keyboard when the user taps anything outside
      // this field. This is the field's own TapRegion hook, so it covers taps
      // on any widget, on blank space and on a scrolling list alike.
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        helperText: helper,
        prefixText: prefixText,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );

    final labelled = label == null
        ? field
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldLabel(label!),
              Gap.h4,
              field,
            ],
          );

    if (!selectAllOnFocus) return labelled;

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus || controller.text.isEmpty) return;
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      child: labelled,
    );
  }
}

/// The caption above a field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.isOptional = false});

  final String text;

  /// Appends a quiet "optional" hint, so required fields read as the default.
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: context.text.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOptional) ...[
          Gap.w4,
          Text('optional', style: context.text.labelSmall),
        ],
      ],
    );
  }
}

/// A read-only field-shaped row that opens something when tapped.
///
/// Used where a value is chosen rather than typed, such as a date or a
/// customer, so those rows still look like part of the form.
class AppFieldButton extends StatelessWidget {
  const AppFieldButton({
    super.key,
    required this.value,
    required this.onTap,
    this.label,
    this.placeholder,
    this.icon,
    this.isPlaceholder = false,
  });

  final String value;
  final VoidCallback onTap;
  final String? label;
  final String? placeholder;
  final IconData? icon;

  /// Renders [value] in the muted placeholder colour.
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = value.trim().isEmpty ? (placeholder ?? '') : value;
    final showAsPlaceholder = isPlaceholder || value.trim().isEmpty;

    final field = Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.smAll,
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge?.copyWith(
                    color: showAsPlaceholder
                        ? palette.textTertiary
                        : palette.textPrimary,
                  ),
                ),
              ),
              Gap.w8,
              Icon(
                icon ?? Icons.expand_more,
                size: IconSizes.sm,
                color: palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [FieldLabel(label!), Gap.h4, field],
    );
  }
}
