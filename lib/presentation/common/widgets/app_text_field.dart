import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';
import 'package:invoicemaker/core/utils/input_formatters.dart';

/// The app's single text field, styled from the theme.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.helperTextColor = AppColors.black,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.selectAllOnFocus = false,
    this.autofocus = false,
  });

  /// A field for money or percentages, capped at [max].
  factory AppTextField.decimal({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    double? max,
    String? helperText,
    Color helperTextColor = AppColors.black,
    String? suffixText,
    Icon? suffixIcon,
    ValueChanged<String>? onChanged,
    bool selectAllOnFocus = true,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      hintText: hintText,
      helperText: helperText,
      helperTextColor: helperTextColor,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [DecimalInputFormatter(max: max)],
      onChanged: onChanged,
      selectAllOnFocus: selectAllOnFocus,
    );
  }

  /// A field for whole numbers such as a quantity.
  factory AppTextField.integer({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    int? max,
    ValueChanged<String>? onChanged,
    bool selectAllOnFocus = true,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.number,
      inputFormatters: [IntegerInputFormatter(max: max)],
      onChanged: onChanged,
      selectAllOnFocus: selectAllOnFocus,
    );
  }

  /// A multi-line field for notes, terms and payment details.
  factory AppTextField.multiline({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    int minLines = 4,
    int maxLines = 50,
    bool autofocus = false,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      hintText: hintText,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      autofocus: autofocus,
    );
  }

  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final Color helperTextColor;
  final Icon? suffixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final FormFieldValidator<String>? validator;

  /// Selects the existing text on focus, so typing replaces it.
  final bool selectAllOnFocus;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus || !selectAllOnFocus) return;
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      child: TextFormField(
        controller: controller,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        strutStyle: const StrutStyle(height: 1),
        decoration: InputDecoration(
          hintText: hintText,
          helperText: helperText,
          helperMaxLines: 2,
          helperStyle: TextStyle(color: helperTextColor),
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: AppColors.darkGrey),
          suffixIcon: suffixIcon,
          suffixIconColor: AppColors.darkGrey,
        ),
      ),
    );
  }
}

/// A field with its caption above it — the layout every form here uses.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.labelStyle = AppTextStyles.fieldLabel,
  });

  final String label;
  final Widget child;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        child,
      ],
    );
  }
}
