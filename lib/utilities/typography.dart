import 'package:flutter/material.dart';

import 'colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get mainTitle => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static TextStyle get bodyText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
    height: 1.6,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );


}
