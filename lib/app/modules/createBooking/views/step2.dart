// lib/app/modules/create_booking/steps/step2_packages.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/app/modules/createBooking/views/widgets/step_form_card.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step2Packages extends StatelessWidget {
  const Step2Packages({super.key});

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateBookingController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Add Package + plus btn
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'createBooking.step2.addPackage'.trns(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: controller.addPackage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Package Items
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.packageItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = controller.packageItems[index];
              return _PackageCard(
                index: index,
                item: item,
                controller: controller,
                onDropdown: _showDropdown,
                context: context,
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        MainBtn(
          text: 'createBooking.next'.trns(),
          onPressed: controller.nextStep,
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final int index;
  final PackageItem item;
  final CreateBookingController controller;
  final BuildContext context;
  final void Function(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
  }) onDropdown;

  const _PackageCard({
    required this.index,
    required this.item,
    required this.controller,
    required this.onDropdown,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    return StepFormCard(
      title: 'createBooking.step2.packagesInfo'.trns(),
      showDelete: true,
      onDelete: () => controller.removePackage(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package
          _FieldLabel('createBooking.step2.package'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintTextColor: AppColors.grey,
            hintText: 'createBooking.step2.selectPackage'.trns(),
            controller: item.packageCtrl,
            readOnly: true,
            height: 50,
            hintTextSize: 13,
            onTap: () => onDropdown(
              buildContext,
              title: 'createBooking.step2.package'.trns(),
              items: controller.packageOptions,
              selectedItem: item.selectedPackage,
              textCtrl: item.packageCtrl,
            ),
          ),
          const SizedBox(height: 16),

          // Employee
          _FieldLabel('createBooking.step2.employee'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintTextColor: AppColors.grey,
            hintText: 'createBooking.step2.selectEmployee'.trns(),
            controller: item.employeeCtrl,
            readOnly: true,
            height: 50,
            hintTextSize: 13,
            onTap: () => onDropdown(
              buildContext,
              title: 'createBooking.step2.employee'.trns(),
              items: controller.employeeOptions,
              selectedItem: item.selectedEmployee,
              textCtrl: item.employeeCtrl,
            ),
          ),
          const SizedBox(height: 16),

          // Amount
          _FieldLabel('createBooking.step2.amount'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintTextColor: AppColors.grey,
            hintText: '00',
            controller: item.amountCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
          const SizedBox(height: 16),

          // Discount
          _FieldLabel('createBooking.step2.discount'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintTextColor: AppColors.grey,
            hintText: '00',
            controller: item.discountCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
          const SizedBox(height: 16),

          // Total
          _FieldLabel('createBooking.step2.total'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintTextColor: AppColors.grey,
            hintText: '00',
            controller: item.totalCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
        ],
      ),
    );
  }
}

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