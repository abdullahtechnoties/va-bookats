import 'package:va_bookats/utilities/colors.dart';
import 'package:flutter/material.dart';

class LightTheme {
  ThemeData lightTheme(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: "Poppins",
  );
}