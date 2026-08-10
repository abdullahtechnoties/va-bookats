// lib/app/widgets/add_service_category_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddServiceCategoryDialog extends StatefulWidget {
  const AddServiceCategoryDialog({super.key});

  @override
  State<AddServiceCategoryDialog> createState() =>
      _AddServiceCategoryDialogState();
}

class _AddServiceCategoryDialogState extends State<AddServiceCategoryDialog> {
  final TextEditingController _branchCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final RxString _selectedBranch = ''.obs;

  final List<String> _branches = ['Branch A', 'Branch B', 'Branch C'];

  void _showBranchDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: 'addServiceCategory.branch'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
        dropdownItems: _branches,
        selectedItem: _selectedBranch,
        textController: _branchCtrl,
        currentlySelectedValue: _selectedBranch.value,
        showSearch: false,
      ),
    );
  }

  void _save() {
    if (_branchCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      SnackbarService.showError(
        title: 'Validation Error',
        message: 'Please fill all fields',
      );
      return;
    }
    SnackbarService.showSuccess(
      title: 'Success',
      message: 'Category added successfully!',
    );
    Get.back();
  }

  @override
  void dispose() {
    _branchCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addServiceCategory.dialogTitle'.trns(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 22),

            // Branch
            Text(
              'addServiceCategory.branch'.trns(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => CommonTextInputField(
                hintText: 'addServiceCategory.selectBranch'.trns(),
                controller: _branchCtrl,
                readOnly: true,
                height: 52,
                hintTextSize: 13,
                onTap: () => _showBranchDropdown(context),
              ),
            ),
            const SizedBox(height: 18),

            // Name
            Text(
              'addServiceCategory.name'.trns(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addServiceCategory.enterFullName'.trns(),
              controller: _nameCtrl,
              height: 52,
              hintTextSize: 13,
            ),
            const SizedBox(height: 24),

            MainBtn(
              text: 'addServiceCategory.save'.trns(),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}