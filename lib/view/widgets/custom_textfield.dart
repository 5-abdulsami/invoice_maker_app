import 'package:flutter/material.dart';
import 'package:invoicemaker/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType,
    this.onChanged,
    this.minLines,
    this.maxLines,
    this.selectAllOnFocus = false,
    this.helperTextColor = Colors.black,
    this.maxLength,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final Icon? suffixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final int? minLines;
  final int? maxLines;
  final bool selectAllOnFocus;
  final Color helperTextColor;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && selectAllOnFocus) {
          // Select all text when the TextField gains focus
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      },
      child: TextFormField(
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        validator: validator,
        keyboardType: keyboardType,
        onChanged: onChanged,
        strutStyle: const StrutStyle(height: 1),
        controller: controller,
        decoration: InputDecoration(
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: darkGreyColor),
          suffixIcon: suffixIcon,
          suffixIconColor: darkGreyColor,
          helperText: helperText,
          helperStyle: TextStyle(color: helperTextColor),
          helperMaxLines: 2,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: hintTextColor,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: lightGreyColor,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
