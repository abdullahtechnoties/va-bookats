// lib/widgets/report_column_selector_sheet.dart
//
// One shared column selector for every reporting flow.
// Source of truth is a temp RxSet of column keys owned by the controller and
// initialized ONCE by the sheet opener (never inside build), so checkmarks
// can never desync from the header count. Each row is wrapped in its own
// Obx for granular rebuilds, with a single tap path (no nested detectors).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ReportColumnSelectorSheet extends StatelessWidget {
  final String title;
  final List<ReportColumnOption> columns;
  final RxSet<String> tempSelected;
  final VoidCallback onApply;
  final VoidCallback onReset;
  final VoidCallback onSelectAll;

  const ReportColumnSelectorSheet({
    super.key,
    required this.title,
    required this.columns,
    required this.tempSelected,
    required this.onApply,
    required this.onReset,
    required this.onSelectAll,
  });

  static void show({
    required BuildContext context,
    required String title,
    required List<ReportColumnOption> columns,
    required RxSet<String> tempSelected,
    required VoidCallback onApply,
    required VoidCallback onReset,
    required VoidCallback onSelectAll,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ReportColumnSelectorSheet(
        title: title,
        columns: columns,
        tempSelected: tempSelected,
        onApply: onApply,
        onReset: onReset,
        onSelectAll: onSelectAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    '$title (${tempSelected.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppColors.black),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                TextButton(
                  onPressed: onSelectAll,
                  child: Text('reports.columns.selectAll'.trns()),
                ),
                TextButton(
                  onPressed: () {
                    onReset();
                    Get.back();
                  },
                  child: Text('reports.filter.reset'.trns()),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: columns.length,
              itemBuilder: (ctx, i) {
                final col = columns[i];
                return Obx(() {
                  final checked = tempSelected.contains(col.key);
                  return GestureDetector(
                    onTap: () {
                      if (checked) {
                        tempSelected.remove(col.key);
                      } else {
                        tempSelected.add(col.key);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          _ReportCheckBox(value: checked),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              col.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  onApply();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'reports.filter.apply'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCheckBox extends StatelessWidget {
  final bool value;

  const _ReportCheckBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: value ? AppColors.primary : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
      child: value
          ? const Icon(Icons.check, color: AppColors.white, size: 14)
          : null,
    );
  }
}
