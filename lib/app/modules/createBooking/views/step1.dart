// lib/app/modules/create_booking/steps/step1_booking_info.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/add-customer_dialog.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step1BookingInfo extends StatelessWidget {
  const Step1BookingInfo({super.key});

  void _showDropdown(
    BuildContext context,
    CreateBookingController controller, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    Function(dynamic)? onSelected,
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
        onValueSelected: onSelected,
        showSearch: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateBookingController>();

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
              'createBooking.step1.title'.trns(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Branch
            _FieldLabel('createBooking.step1.branch'.trns()),
            const SizedBox(height: 8),
            Obx(
              () => CommonTextInputField(
                hintTextColor: AppColors.grey,

                hintText: 'createBooking.step1.selectBranch'.trns(),
                controller: controller.branchCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                onTap: () => _showDropdown(
                  context,
                  controller,
                  title: 'createBooking.step1.branch'.trns(),
                  items: controller.branches,
                  selectedItem: controller.selectedBranch,
                  textCtrl: controller.branchCtrl,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Type
            _FieldLabel('createBooking.step1.bookingType'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
                hintTextColor: AppColors.grey,

              hintText: 'createBooking.step1.selectBookingType'.trns(),
              controller: controller.bookingTypeCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () => _showDropdown(
                context,
                controller,
                title: 'createBooking.step1.bookingType'.trns(),
                items: controller.bookingTypes,
                selectedItem: controller.selectedBookingType,
                textCtrl: controller.bookingTypeCtrl,
              ),
            ),
            const SizedBox(height: 16),

            // Customer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FieldLabel('createBooking.step1.customer'.trns()),
                GestureDetector(
                  onTap: () => Get.dialog(const AddCustomerDialog()),
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
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'createBooking.step1.addCustomer'.trns(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CommonTextInputField(
                hintTextColor: AppColors.grey,

              hintText: 'createBooking.step1.selectCustomerType'.trns(),
              controller: controller.customerCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              showSuffixIcon: true,
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF888888),
              ),
              onTap: () => _showDropdown(
                context,
                controller,
                title: 'createBooking.step1.customer'.trns(),
                items: controller.customers,
                selectedItem: controller.selectedCustomer,
                textCtrl: controller.customerCtrl,
                // showSearch: true,
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _FieldLabel('createBooking.step1.date'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
                hintTextColor: AppColors.grey,

              hintText: 'createBooking.step1.datePlaceholder'.trns(),
              controller: controller.dateCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
                  controller.dateCtrl.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                }
              },
            ),
            const SizedBox(height: 16),

            // Start Time
            _FieldLabel('createBooking.step1.startTime'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
                hintTextColor: AppColors.grey,

              hintText: 'createBooking.step1.startTimePlaceholder'.trns(),
              controller: controller.startTimeCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
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
                  controller.startTimeCtrl.text = picked.format(context);
                }
              },
            ),
            const SizedBox(height: 16),

            // End Time
            _FieldLabel('createBooking.step1.endTime'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
                hintTextColor: AppColors.grey,

              hintText: 'createBooking.step1.endTimePlaceholder'.trns(),
              controller: controller.endTimeCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
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
                  controller.endTimeCtrl.text = picked.format(context);
                }
              },
            ),
            const SizedBox(height: 16),

            // Note
            _FieldLabel('createBooking.step1.note'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
                hintTextColor: AppColors.grey,

              hintText: 'createBooking.step1.notePlaceholder'.trns(),
              controller: controller.noteCtrl,
              maxLines: 4,
              height: 100,
              hintTextSize: 13,
            ),
            const SizedBox(height: 16),

            // Service Type
            _FieldLabel('createBooking.step1.serviceType'.trns()),
            const SizedBox(height: 10),
            Obx(
              () => Row(
                children: [
                  _RadioOption(
                    label: 'createBooking.step1.packages'.trns(),
                    value: ServiceType.packages,
                    groupValue: controller.selectedServiceType.value,
                    onChanged: (v) => controller.selectedServiceType.value = v!,
                  ),
                  const SizedBox(width: 18),
                  _RadioOption(
                    label: 'createBooking.step1.services'.trns(),
                    value: ServiceType.services,
                    groupValue: controller.selectedServiceType.value,
                    onChanged: (v) => controller.selectedServiceType.value = v!,
                  ),
                  const SizedBox(width: 18),
                  _RadioOption(
                    label: 'createBooking.step1.products'.trns(),
                    value: ServiceType.products,
                    groupValue: controller.selectedServiceType.value,
                    onChanged: (v) => controller.selectedServiceType.value = v!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            MainBtn(
              text: 'createBooking.next'.trns(),
              onPressed: controller.nextStep,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

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

class _RadioOption<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioOption({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.secondary : const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.secondary : const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension helper to pass showSearch
extension on void Function(
  BuildContext context,
  CreateBookingController controller, {
  required String title,
  required List<String> items,
  required RxString selectedItem,
  required TextEditingController textCtrl,
  Function(dynamic)? onSelected,
}) {}