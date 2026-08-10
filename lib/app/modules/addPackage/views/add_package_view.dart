// lib/app/modules/add_package/views/add_package_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addPackage/controllers/add_package_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
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
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownItems: items,
        selectedItem: selectedItem,
        textController: textCtrl,
        currentlySelectedValue: selectedItem.value,
        showSearch: false,
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
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _AddPackageHeader(),

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                children: [
                  // ── Package Info Card ──────────────────────────────
                  _PackageInfoCard(
                    controller: controller,
                    onShowDropdown: _showDropdown,
                    onPickDate: _pickDate,
                    buildContext: context,
                  ),
                  const SizedBox(height: 14),

                  // ── Add Service Section ────────────────────────────
                  Obx(
                    () => Column(
                      children: [
                        ...controller.serviceItems.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AddServiceCard(
                              index: entry.key,
                              item: entry.value,
                              controller: controller,
                              onShowDropdown: _showDropdown,
                              buildContext: context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Description Card ───────────────────────────────
                  _DescriptionCard(controller: controller),
                  const SizedBox(height: 20),

                  // ── Save ───────────────────────────────────────────
                  MainBtn(
                    text: 'addPackage.save'.trns(),
                    onPressed: controller.save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AddPackageHeader extends StatelessWidget {
  const _AddPackageHeader();

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
                  'addPackage.title'.trns(),
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

// ─── Package Info Card ────────────────────────────────────────────────────────

class _PackageInfoCard extends StatelessWidget {
  final AddPackageController controller;
  final BuildContext buildContext;
  final void Function(BuildContext context,
      {required String title,
      required List<String> items,
      required RxString selectedItem,
      required TextEditingController textCtrl}) onShowDropdown;
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

            // Branch
            _FieldLabel('addPackage.branch'.trns()),
            const SizedBox(height: 8),
            Obx(
              () => CommonTextInputField(
                hintText: 'addPackage.selectBranch'.trns(),
                controller: controller.branchCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                onTap: () => onShowDropdown(
                  buildContext,
                  title: 'addPackage.branch'.trns(),
                  items: controller.branches,
                  selectedItem: controller.selectedBranch,
                  textCtrl: controller.branchCtrl,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
            Obx(
              () => CommonTextInputField(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Service Card ─────────────────────────────────────────────────────────

class _AddServiceCard extends StatelessWidget {
  final int index;
  final PackageServiceItem item;
  final AddPackageController controller;
  final BuildContext buildContext;
  final void Function(BuildContext context,
      {required String title,
      required List<String> items,
      required RxString selectedItem,
      required TextEditingController textCtrl}) onShowDropdown;

  const _AddServiceCard({
    required this.index,
    required this.item,
    required this.controller,
    required this.onShowDropdown,
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
            // Header: Add Service + plus btn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'addPackage.addService'.trns(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: controller.addServiceItem,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Service fields grid (2 columns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select Service
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SmallLabel('addPackage.selectService'.trns()),
                      const SizedBox(height: 6),
                      Obx(
                        () => _SelectServiceField(
                          controller: item.serviceCtrl,
                          hint: 'addPackage.selectService'.trns(),
                          onTap: () => onShowDropdown(
                            buildContext,
                            title: 'addPackage.selectService'.trns(),
                            items: controller.serviceOptions,
                            selectedItem: item.selectedService,
                            textCtrl: item.serviceCtrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SmallLabel('addPackage.price'.trns()),
                      const SizedBox(height: 6),
                      CommonTextInputField(
                        hintText: '999.00',
                        controller: item.priceCtrl,
                        keyboardType: TextInputType.number,
                        height: 46,
                        hintTextSize: 13,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Total Price (Auto)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SmallLabel('addPackage.totalPriceAuto'.trns()),
                      const SizedBox(height: 6),
                      CommonTextInputField(
                        hintText: '999.00',
                        controller: item.totalPriceCtrl,
                        keyboardType: TextInputType.number,
                        height: 46,
                        hintTextSize: 13,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Package Price (Custom)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SmallLabel('addPackage.packagePriceCustom'.trns()),
                      const SizedBox(height: 6),
                      CommonTextInputField(
                        hintText: '599.00',
                        controller: item.packagePriceCtrl,
                        keyboardType: TextInputType.number,
                        height: 46,
                        hintTextSize: 13,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delete Button
            GestureDetector(
              onTap: () => controller.removeServiceItem(index),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'addPackage.delete'.trns(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.delete_outline,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Select Service Field (with dropdown arrow) ───────────────────────────────

class _SelectServiceField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  const _SelectServiceField({
    required this.controller,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  fontSize: 13,
                  color: controller.text.isEmpty
                      ? const Color(0xFFAAAAAA)
                      : AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF888888),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Description Card ─────────────────────────────────────────────────────────

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
              height: 110,
              hintTextSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field Labels ─────────────────────────────────────────────────────────────

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

class _SmallLabel extends StatelessWidget {
  final String text;
  const _SmallLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      );
}