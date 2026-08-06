import 'package:va_bookats/utilities/colors.dart';
import 'package:flutter/material.dart';

class DarkTheme {
  ThemeData darkTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: "Plus Jakarta Sans",
  );
}