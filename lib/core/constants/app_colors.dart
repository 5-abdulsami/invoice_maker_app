import 'package:flutter/material.dart';

/// Every colour used by the app. Never declare colours inline.
sealed class AppColors {
  static const Color scaffold = Color(0xFFF8F9FD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Colors.black;
  static const Color red = Colors.red;

  static const Color primary = Color(0xFF2A62FF);
  static const Color primaryDark = Color.fromARGB(255, 1, 18, 65);
  static const Color splash = Color(0xFF1777FF);

  static const Color grey = Color(0xFF999999);
  static const Color darkGrey = Color.fromARGB(255, 112, 108, 108);
  static const Color lightGrey = Color.fromARGB(255, 239, 241, 255);
  static const Color hintText = Color.fromARGB(255, 206, 206, 206);
  static const Color shadow = Color.fromARGB(255, 199, 199, 199);

  static const Color lightBlue = Color.fromARGB(255, 187, 205, 255);
  static const Color lightBlueText = Color.fromARGB(255, 111, 150, 255);
  static const Color buttonLightBlue = Color.fromARGB(255, 221, 230, 255);

  static const Color buttonLightGreen = Color.fromARGB(255, 202, 255, 204);
  static const Color lightGreenText = Color.fromARGB(255, 58, 204, 63);

  static const Color buttonLightOrange = Color.fromARGB(255, 255, 229, 190);
  static const Color lightOrangeText = Color.fromARGB(255, 255, 177, 60);

  static const Color filterText = Colors.white;
  static const Color previewBg = Color.fromARGB(255, 248, 251, 255);
}
