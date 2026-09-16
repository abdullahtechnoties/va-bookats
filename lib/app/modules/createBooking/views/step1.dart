// lib/app/modules/createBooking/views/step1.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/add-customer_dialog.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step1BookingInfo extends GetView<CreateBookingController> {
  const Step1BookingInfo({super.key});

  void _showThree(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? values,
    Function(dynamic)? onSelected,
    bool showSearch = true,
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
        showSearch: showSearch,
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
        child: Form(
          key: controller.stepKeys[0],
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

              // Branch — owner only
              Obx(() => controller.showBranch
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(
                            'createBooking.step1.branch'.trns()),
                        const SizedBox(height: 8),
                        Obx(() => CommonTextInputField(
                              hintTextColor: AppColors.grey,
                              hintText:
                                  'createBooking.step1.selectBranch'.trns(),
                              controller: controller.branchCtrl,
                              readOnly: true,
                              height: 50,
                              hintTextSize: 13,
                              showSuffixIcon: true,
                              suffixIcon:
                                  controller.isLoadingBranches.value
                                      ? _loaderSuffix()
                                      : const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF888888),
                                        ),
                              validator: (_) => controller.showBranch &&
                                      controller.selectedBranchId.value ==
                                          null
                                  ? 'Please select a branch'
                                  : null,
                              onTap: controller.isLoadingBranches.value
                                  ? null
                                  : () => _showThree(
                                        context,
                                        title:
                                            'createBooking.step1.branch'
                                                .trns(),
                                        items: controller.branchLabels,
                                        selectedItem: controller
                                            .selectedBranchValue,
                                        textCtrl: controller.branchCtrl,
                                        values: controller.branchValues,
                                        onSelected: (v) {
                                          controller.onBranchSelected(v);
                                          // Keep the visible label in sync.
                                          final idx = controller.branchValues
                                              .indexOf(v?.toString() ?? '');
                                          if (idx != -1) {
                                            controller.selectedBranch.value =
                                                controller.branchLabels[idx];
                                          }
                                        },
                                      ),
                            )),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink()),

              // Booking Type (static: Guest / Customer)
              _FieldLabel('createBooking.step1.bookingType'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText:
                    'createBooking.step1.selectBookingType'.trns(),
                controller: controller.bookingTypeCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                showSuffixIcon: true,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888),
                ),
                validator: (_) =>
                    controller.selectedBookingType.value.isEmpty
                        ? 'Please select a booking type'
                        : null,
                onTap: () => _showThree(
                  context,
                  title: 'createBooking.step1.bookingType'.trns(),
                  items: CreateBookingController.bookingTypes,
                  selectedItem: controller.selectedBookingType,
                  textCtrl: controller.bookingTypeCtrl,
                  showSearch: false,
                  onSelected: (v) => controller
                      .onBookingTypeSelected(v?.toString() ?? ''),
                ),
              ),
              const SizedBox(height: 16),

              // Customer — only when type is Customer
              Obx(() => controller.isCustomerType
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel('createBooking.step1.customer'
                                .trns()),
                            GestureDetector(
                              onTap: () =>
                                  Get.dialog(const AddCustomerDialog()),
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
                                    'createBooking.step1.addCustomer'
                                        .trns(),
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
                        Obx(() => CommonTextInputField(
                              hintTextColor: AppColors.grey,
                              hintText:
                                  'createBooking.step1.selectCustomerType'
                                      .trns(),
                              controller: controller.customerCtrl,
                              readOnly: true,
                              height: 50,
                              hintTextSize: 13,
                              showSuffixIcon: true,
                              suffixIcon:
                                  controller.isLoadingCustomers.value
                                      ? _loaderSuffix()
                                      : const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF888888),
                                        ),
                              validator: (_) =>
                                  controller.isCustomerType &&
                                          controller.selectedCustomerId
                                                  .value ==
                                              null
                                      ? 'Please select a customer'
                                      : null,
                              onTap: () => _showThree(
                                context,
                                title: 'createBooking.step1.customer'
                                    .trns(),
                                items: controller.customerOptions
                                    .map((o) => o.label)
                                    .toList(),
                                selectedItem:
                                    controller.selectedCustomerValue,
                                textCtrl: controller.customerCtrl,
                                values: controller.customerOptions
                                    .map((o) => o.value)
                                    .toList(),
                                onSelected: (v) {
                                  controller.onCustomerSelected(v);
                                  final idx = controller.customerOptions
                                      .indexWhere((o) =>
                                          o.value == v?.toString());
                                  if (idx != -1) {
                                    controller.selectedCustomer.value =
                                        controller
                                            .customerOptions[idx].label;
                                  }
                                },
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink()),

              // Guest fields — only when type is Guest
              Obx(() => controller.isGuestType
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Guest Name'),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintText: 'Enter guest name',
                          controller: controller.guestNameCtrl,
                          height: 50,
                          hintTextSize: 13,
                          validator: (_) =>
                              controller.isGuestType &&
                                      controller
                                          .guestNameCtrl.text.trim().isEmpty
                                  ? 'Please enter guest name'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Guest Email'),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintText: 'Enter guest email',
                          controller: controller.guestEmailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          height: 50,
                          hintTextSize: 13,
                          validator: (_) {
                            if (!controller.isGuestType) return null;
                            final v = controller.guestEmailCtrl.text.trim();
                            if (v.isEmpty) {
                              return 'Please enter guest email';
                            }
                            if (!GetUtils.isEmail(v)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Guest Phone'),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintText: 'Enter guest phone',
                          controller: controller.guestPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          height: 50,
                          hintTextSize: 13,
                          validator: (_) =>
                              controller.isGuestType &&
                                      controller
                                          .guestPhoneCtrl.text.trim().isEmpty
                                  ? 'Please enter guest phone'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink()),

              // Date
              _FieldLabel('createBooking.step1.date'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'YYYY-MM-DD',
                controller: controller.dateCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                validator: (_) => controller.dateCtrl.text.trim().isEmpty
                    ? 'Please select a date'
                    : null,
                onTap: () => controller.pickDate(context),
              ),
              const SizedBox(height: 16),

              // Start Time
              _FieldLabel('createBooking.step1.startTime'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'HH:MM',
                controller: controller.startTimeCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                validator: (_) =>
                    controller.startTimeCtrl.text.trim().isEmpty
                        ? 'Please select start time'
                        : null,
                onTap: () => controller.pickTime(
                    context, controller.startTimeCtrl),
              ),
              const SizedBox(height: 16),

              // End Time
              _FieldLabel('createBooking.step1.endTime'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'HH:MM',
                controller: controller.endTimeCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                validator: (_) =>
                    controller.endTimeCtrl.text.trim().isEmpty
                        ? 'Please select end time'
                        : null,
                onTap: () =>
                    controller.pickTime(context, controller.endTimeCtrl),
              ),
              const SizedBox(height: 16),

              // Note
              _FieldLabel('createBooking.step1.note'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                hintTextColor: AppColors.grey,
                hintText:
                    'createBooking.step1.notePlaceholder'.trns(),
                controller: controller.noteCtrl,
                maxLines: 4,
                height: 100,
                hintTextSize: 13,
              ),
              const SizedBox(height: 24),

              MainBtn(
                text: 'createBooking.next'.trns(),
                onPressed: controller.nextStep,
              ),
            ],
          ),
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
