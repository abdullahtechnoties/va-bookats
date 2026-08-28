// lib/app/modules/addPackage/views/add_package_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addPackage/controllers/add_package_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddPackageView extends GetView<AddPackageController> {
  const AddPackageView({super.key});

  void _showDropdown(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? selectedValue,
    Function(dynamic)? onValueSelected,
    bool showSearch = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownItems: items,
        selectedItem: selectedItem,
        textController: textCtrl,
        currentlySelectedValue: selectedItem.value,
        selectedValue: selectedValue,
        onValueSelected: onValueSelected,
        showSearch: showSearch,
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.secondary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Column(
            children: [
              _AddPackageHeader(controller: controller),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            _AddPackageHeader(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    _PackageInfoCard(
                      controller: controller,
                      onShowDropdown: _showDropdown,
                      onPickDate: _pickDate,
                      buildContext: context,
                    ),
                    const SizedBox(height: 14),

                    // ─── Services ────────────────────────────────
                    _ServicesSection(
                      controller: controller,
                      onShowDropdown: _showDropdown,
                      buildContext: context,
                    ),

                    // Description
                    _DescriptionCard(controller: controller),
                    const SizedBox(height: 14),

                    // Total + Package Price
                    _PriceSection(controller: controller),
                    const SizedBox(height: 20),

                    // Save
                    Obx(
                      () => MainBtn(
                        text: controller.saveButtonText,
                        isLoading: controller.isSaving.value,
                        onPressed: controller.isSaving.value
                            ? null
                            : controller.save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AddPackageHeader extends StatelessWidget {
  final AddPackageController controller;
  const _AddPackageHeader({required this.controller});

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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
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
                child: Text(
                  controller.formTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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

// ─── Package Info Card ──────────────────────────────────────────────────────

class _PackageInfoCard extends StatelessWidget {
  final AddPackageController controller;
  final BuildContext buildContext;
  final void Function(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? selectedValue,
    Function(dynamic)? onValueSelected,
    bool showSearch,
  }) onShowDropdown;
  final Future<void> Function(BuildContext, TextEditingController) onPickDate;

  const _PackageInfoCard({
    required this.controller,
    required this.onShowDropdown,
    required this.onPickDate,
    required this.buildContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addPackage.packageInfo'.trns(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 18),

            // Branch (owner only)
            if (controller.showBranch) ...[
              _FieldLabel('addPackage.branch'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintText: 'addPackage.selectBranch'.trns(),
                controller: controller.branchCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                onTap: () => onShowDropdown(
                  buildContext,
                  title: 'addPackage.branch'.trns(),
                  items: controller.branchLabels,
                  selectedItem: controller.selectedBranch,
                  textCtrl: controller.branchCtrl,
                  selectedValue: controller.branchIds,
                  onValueSelected: controller.onBranchSelected,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Name
            _FieldLabel('addPackage.name'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addPackage.enterFullName'.trns(),
              controller: controller.nameCtrl,
              height: 50,
              hintTextSize: 13,
            ),
            const SizedBox(height: 16),

            // Starting From
            _FieldLabel('addPackage.startingFrom'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addPackage.datePlaceholder'.trns(),
              controller: controller.startDateCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () => onPickDate(buildContext, controller.startDateCtrl),
            ),
            const SizedBox(height: 16),

            // Ending On
            _FieldLabel('addPackage.endingOn'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addPackage.datePlaceholder'.trns(),
              controller: controller.endDateCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () => onPickDate(buildContext, controller.endDateCtrl),
            ),
            const SizedBox(height: 16),

            // Status
            _FieldLabel('addPackage.status'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addPackage.selectStatus'.trns(),
              controller: controller.statusCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () => onShowDropdown(
                buildContext,
                title: 'addPackage.status'.trns(),
                items: controller.statusOptions,
                selectedItem: controller.selectedStatus,
                textCtrl: controller.statusCtrl,
                selectedValue: controller.statusOptions,
                onValueSelected: (val) {
                  controller.selectedStatus.value = val.toString();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Services Section (header + rows + add button) ────────────────────────

class _ServicesSection extends StatelessWidget {
  final AddPackageController controller;
  final BuildContext buildContext;
  final void Function(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? selectedValue,
    Function(dynamic)? onValueSelected,
    bool showSearch,
  }) onShowDropdown;

  const _ServicesSection({
    required this.controller,
    required this.onShowDropdown,
    required this.buildContext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'addPackage.service'.trns(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            GestureDetector(
              onTap: () => controller.addServiceItem(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: AppColors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'addPackage.addService'.trns(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Service rows
        Obx(
          () => Column(
            children: List.generate(controller.serviceItems.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ServiceRow(
                  index: index,
                  item: controller.serviceItems[index],
                  controller: controller,
                  onShowDropdown: onShowDropdown,
                  buildContext: buildContext,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Single Service Row ─────────────────────────────────────────────────────

class _ServiceRow extends StatelessWidget {
  final int index;
  final PackageServiceItem item;
  final AddPackageController controller;
  final BuildContext buildContext;
  final void Function(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? selectedValue,
    Function(dynamic)? onValueSelected,
    bool showSearch,
  }) onShowDropdown;

  const _ServiceRow({
    required this.index,
    required this.item,
    required this.controller,
    required this.onShowDropdown,
    required this.buildContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Service dropdown
          Expanded(
            flex: 2,
            child: _CompactSelectField(
              displayLabel: item.selectedServiceLabel,
              hint: 'addPackage.selectService'.trns(),
              onTap: () => onShowDropdown(
                buildContext,
                title: 'addPackage.selectService'.trns(),
                items: controller.availableServiceLabels(index),
                selectedItem: item.selectedServiceIdStr,
                textCtrl: item.serviceCtrl,
                selectedValue: controller.availableServiceIds(index),
                onValueSelected: (val) =>
                    controller.onServiceSelected(index, val),
                showSearch: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Variation dropdown (conditional)
          Obx(() {
            if (!item.isVariationType) return const SizedBox.shrink();
            return Expanded(
              flex: 2,
              child: _CompactSelectField(
                displayLabel: item.selectedVariationLabel,
                hint: 'addPackage.selectVariation'.trns(),
                onTap: () {
                  final variationNames = item.variations
                      .map((v) => v.name ?? '')
                      .toList();
                  final variationIds = item.variations
                      .map((v) => v.id?.toString() ?? '')
                      .toList();
                  onShowDropdown(
                    buildContext,
                    title: 'addPackage.selectVariation'.trns(),
                    items: variationNames,
                    selectedItem: item.selectedVariationIdStr,
                    textCtrl: item.variationCtrl,
                    selectedValue: variationIds,
                    onValueSelected: (val) =>
                        controller.onVariationSelected(index, val),
                  );
                },
              ),
            );
          }),
          if (item.isVariationType) const SizedBox(width: 8),

          // Delete button
          GestureDetector(
            onTap: controller.serviceItems.length > 1
                ? () => controller.removeServiceItem(index)
                : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: controller.serviceItems.length > 1
                    ? AppColors.red.withValues(alpha: 0.10)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: controller.serviceItems.length > 1
                    ? AppColors.red
                    : const Color(0xFFBBBBBB),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compact Select Field ──────────────────────────────────────────────────

class _CompactSelectField extends StatelessWidget {
  final RxString displayLabel;
  final String hint;
  final VoidCallback onTap;

  const _CompactSelectField({
    required this.displayLabel,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(
        () => Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  displayLabel.value.isEmpty ? hint : displayLabel.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: displayLabel.value.isEmpty
                        ? const Color(0xFFAAAAAA)
                        : AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Color(0xFF888888),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Description Card ──────────────────────────────────────────────────────

class _DescriptionCard extends StatelessWidget {
  final AddPackageController controller;
  const _DescriptionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('addPackage.description'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addPackage.writeSomething'.trns(),
              controller: controller.descriptionCtrl,
              maxLines: 4,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              height: 110,
              hintTextSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Price Section (total + package price) ────────────────────────────────

class _PriceSection extends StatelessWidget {
  final AddPackageController controller;
  const _PriceSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Computed total
            _FieldLabel('addPackage.totalPrice'.trns()),
            const SizedBox(height: 6),
            Obx(
              () => Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rs: ${controller.computedTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Package Price (custom)
            _FieldLabel('addPackage.packagePrice'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'addPackage.packagePricePlaceholder'.trns(),
              controller: controller.packagePriceCtrl,
              keyboardType: TextInputType.number,
              height: 50,
              hintTextSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Labels ────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      );
}
