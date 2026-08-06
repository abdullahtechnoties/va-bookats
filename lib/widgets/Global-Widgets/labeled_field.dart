// lib/app/modules/create_booking/widgets/labeled_field.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final int? maxLines;
  final double? height;
  final Widget? suffixIcon;
  final bool showSuffixIcon;

  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.maxLines = 1,
    this.height = 50,
    this.suffixIcon,
    this.showSuffixIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        CommonTextInputField(
          hintText: hint,
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType ?? TextInputType.text,
          maxLines: maxLines,
          height: height,
          hintTextSize: 13,
          suffixIcon: suffixIcon,
          showSuffixIcon: showSuffixIcon,
        ),
      ],
    );
  }
}