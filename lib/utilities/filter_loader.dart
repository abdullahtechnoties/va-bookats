// lib/utilities/filter_loader.dart
//
// Shared graceful loader for lazy filter lookups. CRUD / reporting filter
// sheets fetch their dynamic dropdown data only when the filter icon is
// tapped; this dialog covers that short fetch so the sheet never pops with
// empty dropdowns and no feedback.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'dart:async' show unawaited;

/// Shows a blocking loader while filter lookups load.
/// Safe to call even when nothing needs fetching (caller decides).
Future<void> showFilterLoader() async {
  // Avoid stacking multiple loaders if tapped twice quickly.
  if (Get.isDialogOpen == true) return;
  await Get.dialog(
    PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'common.loadingFilters'.trns(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideFilterLoader() {
  if (Get.isDialogOpen == true) Get.back();
}

/// Runs [task] behind the filter loader. The loader is only shown when
/// [shouldShow] is true so cached filter data opens the sheet instantly
/// with no flicker.
Future<void> runWithFilterLoader(
  Future<void> Function() task, {
  bool shouldShow = true,
}) async {
  if (!shouldShow) {
    await task();
    return;
  }
  // Show without awaiting (dialog completes only on hide).
  unawaited(showFilterLoader());
  try {
    await task();
  } finally {
    hideFilterLoader();
  }
}
