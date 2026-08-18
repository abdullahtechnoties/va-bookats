// lib/app/modules/addService/views/add_service_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addService/controllers/add_service_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/add-service-category.dart';
import 'package:va_bookats/widgets/app_touchable.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddServiceView extends GetView<AddServiceController> {
  const AddServiceView({super.key});

  void _showDropdown(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? values,
    Function(dynamic)? onValueSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownItems: items,
        selectedValue: values,
        onValueSelected: onValueSelected,
        selectedItem: selectedItem,
        textController: textCtrl,
        currentlySelectedValue: selectedItem.value,
        showSearch: false,
      ),
    );
  }

  Widget _loaderSuffix() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const _AddServiceHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.isEditMode
                                ? 'addService.editFormTitle'.trns()
                                : 'addService.formTitle'.trns(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Branch — only for owner role
                        Obx(
                          () => controller.showBranch
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('addService.branch'.trns()),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => AppTouchable(
                                        child: CommonTextInputField(
                                          hintText: 'addService.selectBranch'
                                              .trns(),
                                          controller: controller.branchCtrl,
                                          readOnly: true,
                                          height: 52,
                                          hintTextSize: 13,
                                          showSuffixIcon: true,
                                          suffixIcon:
                                              controller.isLoadingBranches.value
                                              ? _loaderSuffix()
                                              : const SizedBox(),
                                          validator: controller.validateBranch,
                                          onTap:
                                              controller.isLoadingBranches.value
                                              ? null
                                              : () => _showDropdown(
                                                  context,
                                                  title: 'addService.branch'
                                                      .trns(),
                                                  items:
                                                      controller.branchLabels,
                                                  selectedItem:
                                                      controller.selectedBranch,
                                                  textCtrl:
                                                      controller.branchCtrl,
                                                  values:
                                                      controller.branchValues,
                                                  onValueSelected: controller
                                                      .onBranchSelected,
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Categories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel('addService.categories'.trns()),
                            AppTouchable(
                              child: GestureDetector(
                                onTap: () => Get.dialog(
                                  AddServiceCategoryDialog(
                                    onCategoryCreated:
                                        controller.onCategoryCreated,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: AppColors.white,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'addService.addCategory'.trns(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => AppTouchable(
                            child: CommonTextInputField(
                              hintText: 'addService.selectCategories'.trns(),
                              controller: controller.categoryCtrl,
                              readOnly: true,
                              height: 52,
                              hintTextSize: 13,
                              showSuffixIcon: true,
                              suffixIcon: controller.isLoadingCategories.value
                                  ? _loaderSuffix()
                                  : const SizedBox(),
                              validator: controller.validateCategory,
                              onTap: controller.isLoadingCategories.value
                                  ? null
                                  : () => _showDropdown(
                                      context,
                                      title: 'addService.categories'.trns(),
                                      items: controller.categoryLabels,
                                      selectedItem: controller.selectedCategory,
                                      textCtrl: controller.categoryCtrl,
                                      values: controller.categoryValues,
                                      onValueSelected:
                                          controller.onCategorySelected,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Name
                        _FieldLabel('addService.name'.trns()),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintTextColor: AppColors.grey,
                          hintText: 'addService.enterFullName'.trns(),
                          controller: controller.nameCtrl,
                          height: 52,
                          hintTextSize: 13,
                          validator: controller.validateName,
                        ),
                        const SizedBox(height: 18),

                        // Image
                        _FieldLabel('addService.addAnImage'.trns()),
                        const SizedBox(height: 8),
                        _ImagePickerField(controller: controller),
                        const SizedBox(height: 18),

                        // Service Duration
                        _FieldLabel('addService.serviceDuration'.trns()),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintTextColor: AppColors.grey,
                          hintText: 'addService.durationPlaceholder'.trns(),
                          controller: controller.durationCtrl,
                          keyboardType: TextInputType.number,
                          height: 52,
                          hintTextSize: 13,
                        ),
                        const SizedBox(height: 18),

                        // Status
                        _FieldLabel('addService.status'.trns()),
                        const SizedBox(height: 8),
                        Obx(
                          () => AppTouchable(
                            child: CommonTextInputField(
                              hintTextColor: AppColors.grey,
                              hintText: 'addService.selectStatus'.trns(),
                              controller: controller.statusCtrl,
                              readOnly: true,
                              height: 52,
                              hintTextSize: 13,
                              onTap: () => _showDropdown(
                                context,
                                title: 'addService.status'.trns(),
                                items: controller.statusOptions,
                                selectedItem: controller.selectedStatus,
                                textCtrl: controller.statusCtrl,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Type
                        _FieldLabel('addService.type'.trns()),
                        const SizedBox(height: 8),
                        Obx(
                          () => AppTouchable(
                            child: CommonTextInputField(
                              hintTextColor: AppColors.grey,
                              hintText: 'addService.selectType'.trns(),
                              controller: controller.typeCtrl,
                              readOnly: true,
                              height: 52,
                              hintTextSize: 13,
                              onTap: () => _showDropdown(
                                context,
                                title: 'addService.type'.trns(),
                                items: controller.typeOptions,
                                selectedItem: controller.selectedType,
                                textCtrl: controller.typeCtrl,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Type-specific section: price or variations
                        Obx(
                          () => controller.isVariationType
                              ? _VariationsSection(controller: controller)
                              : _DefaultPriceSection(controller: controller),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        _FieldLabel('addService.description'.trns()),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintTextColor: AppColors.grey,
                          hintText: 'addService.writeSomething'.trns(),
                          controller: controller.descriptionCtrl,
                          maxLines: 4,
                          height: 120,
                          hintTextSize: 13,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        const SizedBox(height: 26),

                        // Save Button
                        Obx(
                          () => MainBtn(
                            text: controller.isEditMode
                                ? 'addService.update'.trns()
                                : 'addService.save'.trns(),
                            onPressed: controller.isSaving.value
                                ? null
                                : () => controller.save(context),
                            isLoading: controller.isSaving.value,
                          ),
                        ),
                      ],
                    ),
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

// ─── Default Price Section ───────────────────────────────────────────────────

class _DefaultPriceSection extends StatelessWidget {
  final AddServiceController controller;

  const _DefaultPriceSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('addService.defaultPrice'.trns()),
        const SizedBox(height: 8),
        CommonTextInputField(
          hintTextColor: AppColors.grey,
          hintText: 'addService.pricePlaceholder'.trns(),
          controller: controller.defaultPriceCtrl,
          keyboardType: TextInputType.number,
          height: 52,
          hintTextSize: 13,
          validator: controller.validatePrice,
        ),
      ],
    );
  }
}

// ─── Variations Section ──────────────────────────────────────────────────────

class _VariationsSection extends StatelessWidget {
  final AddServiceController controller;

  const _VariationsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inputs = controller.variationInputs;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FieldLabel('addService.variations'.trns()),
                Text(
                  '${inputs.length} '
                  '${'addService.variationCount'.trns()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (inputs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Text(
                'addService.noVariations'.trns(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            )
          else
            ...List.generate(inputs.length, (index) {
              final input = inputs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: 'addService.variationName'.trns(),
                        controller: input.nameCtrl,
                        height: 48,
                        hintTextSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: 'addService.variationPrice'.trns(),
                        controller: input.priceCtrl,
                        keyboardType: TextInputType.number,
                        height: 48,
                        hintTextSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.removeVariation(index),
                      child: Container(
                        width: 40,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.secondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          AppTouchable(
            child: GestureDetector(
              onTap: controller.addVariation,
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'addService.addVariation'.trns(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AddServiceHeader extends StatelessWidget {
  const _AddServiceHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    Get.find<AddServiceController>().isEditMode
                        ? 'addService.editTitle'.trns()
                        : 'addService.title'.trns(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Image Picker Field ───────────────────────────────────────────────────────

class _ImagePickerField extends StatelessWidget {
  final AddServiceController controller;

  const _ImagePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.selectedImage.value;
      final imageUrl = controller.existingImageUrl;
      final fileName = controller.imageFileName.value;
      return Row(
        children: [
          // Preview thumbnail
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4E4), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : imageUrl != null
                ? AppCachedImage(imageUrl: imageUrl, fit: BoxFit.cover)
                : const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFBBBBBB),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
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
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  fileName.isEmpty
                      ? imageUrl ?? 'addService.noFileChosen'.trns()
                      : fileName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AppTouchable(
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'addService.chooseFile'.trns(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }
}
