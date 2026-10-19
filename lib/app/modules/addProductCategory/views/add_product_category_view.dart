import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addProductCategory/controllers/add_product_category_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/inventory-form-widgets.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddProductCategoryView
    extends GetView<AddProductCategoryController> {
  const AddProductCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          InventoryFormHeader(
            title: controller.isEditMode
                ? 'addProductCategory.editTitle'.trns()
                : 'addProductCategory.title'.trns(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: InventoryFormCard(
                formKey: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isEditMode
                          ? 'addProductCategory.editFormTitle'.trns()
                          : 'addProductCategory.formTitle'.trns(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 22),
                    InventoryFieldLabel(
                        'addProductCategory.branch'.trns()),
                    const SizedBox(height: 8),
                    InventoryBranchField(
                      controller: controller,
                      titleKey: 'addProductCategory.branch',
                      hintKey: 'addProductCategory.selectBranch',
                    ),
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addProductCategory.name'.trns()),
                    const SizedBox(height: 8),
                    CommonTextInputField(
                      hintText: 'addProductCategory.enterName'.trns(),
                      controller: controller.nameCtrl,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 20),
                    InventoryFieldLabel(
                        'addProductCategory.parent'.trns()),
                    const SizedBox(height: 8),
                    _ParentField(controller: controller),
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addProductCategory.image'.trns()),
                    const SizedBox(height: 8),
                    InventoryImageField(
                      controller: controller,
                      chooseKey: 'addProductCategory.chooseImage',
                      changeKey: 'addProductCategory.changeImage',
                    ),
                    const SizedBox(height: 28),
                    Obx(() => MainBtn(
                          text: controller.isEditMode
                              ? 'addProductCategory.update'.trns()
                              : 'addProductCategory.save'.trns(),
                          isLoading: controller.isSaving.value,
                          onPressed: () => controller.save(context),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Parent picker (optional, branch-scoped, excludes self) ────────────────

class _ParentField extends StatelessWidget {
  final AddProductCategoryController controller;

  const _ParentField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: controller.isLoadingParents.value
              ? null
              : () => _showParentPicker(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.parentLabel.value.isEmpty
                        ? 'addProductCategory.noParent'.trns()
                        : controller.parentLabel.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.parentLabel.value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.isLoadingParents.value)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: Color(0xFF888888),
                  ),
              ],
            ),
          ),
        ));
  }

  void _showParentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: 'addProductCategory.parent'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.55,
        dropdownItems: [
          'addProductCategory.noParent'.trns(),
          ...controller.parentOptions.map((o) => o.label),
        ],
        textController: TextEditingController(),
        selectedValue: [
          '',
          ...controller.parentOptions.map((o) => o.value.toString()),
        ],
        currentlySelectedValue:
            controller.selectedParentId.value?.toString() ?? '',
        onValueSelected: (v) {
          final raw = v.toString();
          controller.selectParent(
              raw.isEmpty ? null : int.tryParse(raw));
        },
        showSearch: true,
      ),
    );
  }
}
