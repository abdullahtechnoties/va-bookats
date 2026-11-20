// lib/app/modules/dailyClosing/views/widgets/closing_branch_picker.dart
//
// Compact single-select branch picker used by the daily closing form and the
// home opening-balance card. Mirrors the visual language of the reporting
// filter sheets (white sheet, orange selected state) without pulling in the
// full dropdown widget's search bar.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

Future<BranchModel?> showClosingBranchPicker(
  BuildContext context, {
  required List<BranchModel> branches,
  BranchModel? selected,
  String? title,
}) {
  return showModalBottomSheet<BranchModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ClosingBranchPickerSheet(
      branches: branches,
      selected: selected,
      title: title ?? 'dailyClosing.selectBranch'.trns(),
    ),
  );
}

class _ClosingBranchPickerSheet extends StatelessWidget {
  final List<BranchModel> branches;
  final BranchModel? selected;
  final String title;

  const _ClosingBranchPickerSheet({
    required this.branches,
    required this.title,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  final isSelected = branch.value == selected?.value;
                  return GestureDetector(
                    onTap: () => Get.back(result: branch),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary.withValues(alpha: 0.08)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary.withValues(alpha: 0.5)
                              : const Color(0xFFEEEEEE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              branch.displayLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
