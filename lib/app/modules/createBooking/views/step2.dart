// lib/app/modules/createBooking/views/step2.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/app/modules/createBooking/views/widgets/step_form_card.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step2Packages extends GetView<CreateBookingController> {
  const Step2Packages({super.key});

  void _showThree(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? values,
    Function(dynamic)? onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.55,
        dropdownItems: items,
        selectedItem: selectedItem,
        textController: textCtrl,
        selectedValue: values,
        currentlySelectedValue: selectedItem.value,
        onValueSelected: onSelected,
        showSearch: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.stepKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Obx(() {
            if (controller.isLoadingPackages.value &&
                controller.packageOptions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                ),
              );
            }
            if (controller.packageItems.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: const Text(
                  'No packages added (optional).\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.packageItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = controller.packageItems[index];
                final employeeLabels = item.employeeOptions
                    .map((o) => o.label)
                    .toList();
                final employeeValues = item.employeeOptions
                    .map((o) => o.value)
                    .toList();
                return StepFormCard(
                  title:
                      'createBooking.step2.packagesInfo'.trns(),
                  showDelete: true,
                  onDelete: () => controller.removePackage(index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                          'createBooking.step2.package'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: 'createBooking.step2.selectPackage'
                            .trns(),
                        controller: item.packageCtrl,
                        readOnly: true,
                        height: 50,
                        hintTextSize: 13,
                        onTap: () => _showThree(
                          context,
                          title: 'createBooking.step2.package'
                              .trns(),
                          items: controller.packageLabels,
                          selectedItem: item.selectedPackageId,
                          textCtrl: item.packageCtrl,
                          values: controller.packageValues,
                          onSelected: (v) =>
                              controller.onPackageSelected(item, v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step2.employee'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: 'createBooking.step2.selectEmployee'
                            .trns(),
                        controller: item.employeeCtrl,
                        readOnly: true,
                        height: 50,
                        hintTextSize: 13,
                        showSuffixIcon: true,
                        suffixIcon: item.isLoadingStaffs.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        onTap: item.selectedPackageId.value.isEmpty
                            ? null
                            : () => _showThree(
                                  context,
                                  title:
                                      'createBooking.step2.employee'
                                          .trns(),
                                  items: employeeLabels,
                                  selectedItem:
                                      item.selectedEmployeeId,
                                  textCtrl: item.employeeCtrl,
                                  values: employeeValues,
                                  onSelected: (v) => controller
                                      .onPackageEmployeeSelected(item, v),
                                ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step2.amount'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: '00',
                        controller: item.amountCtrl,
                        keyboardType: TextInputType.number,
                        height: 50,
                        hintTextSize: 13,
                        onChanged: (_) =>
                            controller.recalcPackageRow(item),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step2.discount'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: '00',
                        controller: item.discountCtrl,
                        keyboardType: TextInputType.number,
                        height: 50,
                        hintTextSize: 13,
                        onChanged: (_) =>
                            controller.recalcPackageRow(item),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step2.total'.trns()),
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
              },
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.previousStep,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: MainBtn(
                  text: 'createBooking.next'.trns(),
                  onPressed: controller.nextStep,
                ),
              ),
            ],
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
