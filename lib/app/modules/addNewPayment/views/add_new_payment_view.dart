import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addNewPayment/controllers/add_new_payment_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_two.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddNewPaymentView extends GetView<AddNewPaymentController> {
  const AddNewPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isPrefilling.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Heading ───────────────────────────────────────────────
                Text(
                  controller.isEditMode
                      ? 'addNewPayment.editHeading'.trns()
                      : 'addNewPayment.heading'.trns(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Branch (prefilled, read-only) ──────────────────────────
                _FieldLabel(label: 'addNewPayment.branch'.trns()),
                CommonTextInputField(
                  hintText: 'addNewPayment.selectBranch'.trns(),
                  controller: controller.branchController,
                  readOnly: true,
                ),
                const SizedBox(height: 14),

                // ── Total Amount ───────────────────────────────────────────
                _FieldLabel(label: 'addNewPayment.totalAmount'.trns()),
                CommonTextInputField(
                  hintText: 'addNewPayment.enterAmount'.trns(),
                  controller: controller.totalAmountController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                // ── Paid Amount ──────────────────────────────────────────────
                _FieldLabel(label: 'addNewPayment.paidAmount'.trns()),
                CommonTextInputField(
                  hintText: 'addNewPayment.enterAmount'.trns(),
                  controller: controller.paidAmountController,
                  keyboardType: TextInputType.number,
                ),
                Obx(() => controller.paidExceedsTotal.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'addNewPayment.validation.paidExceedsTotal'.trns(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 14),

                // ── Balance (auto-computed, never typed) ─────────────────────
                _FieldLabel(label: 'addNewPayment.balance'.trns()),
                CommonTextInputField(
                  hintText: 'addNewPayment.enterAmount'.trns(),
                  controller: controller.balanceController,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                const SizedBox(height: 14),

              // ── Date ─────────────────────────────────────────────────────
              _FieldLabel(label: 'addNewPayment.date'.trns()),
              GestureDetector(
                onTap: () => controller.pickDate(context),
                child: AbsorbPointer(
                  child: CommonTextInputField(
                    hintText: 'mm/dd/yyyy',
                    controller: controller.dateController,
                    readOnly: true,
                    showSuffixIcon: true,
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Payment Method ───────────────────────────────────────────
              _FieldLabel(label: 'addNewPayment.paymentMethod'.trns()),
              GestureDetector(
                onTap: () => _showPaymentMethodPicker(context),
                child: AbsorbPointer(
                  child: CommonTextInputField(
                    hintText: 'addNewPayment.selectPaymentMethod'.trns(),
                    controller: controller.paymentMethodController,
                    readOnly: true,
                    showSuffixIcon: true,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Status ───────────────────────────────────────────────────
              _FieldLabel(label: 'addNewPayment.status'.trns()),
              GestureDetector(
                onTap: () => _showStatusPicker(context),
                child: AbsorbPointer(
                  child: CommonTextInputField(
                    hintText: 'addNewPayment.selectStatus'.trns(),
                    controller: controller.statusController,
                    readOnly: true,
                    showSuffixIcon: true,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Payment Slip ─────────────────────────────────────────────
              _FieldLabel(label: 'addNewPayment.paymentSlip'.trns()),
              _FileUploadField(controller: controller),
              const SizedBox(height: 14),

              // ── Transaction ID ───────────────────────────────────────────
              _FieldLabel(label: 'addNewPayment.transactionId'.trns()),
              CommonTextInputField(
                hintText: 'addNewPayment.enterTransactionId'.trns(),
                controller: controller.transactionIdController,
              ),
              const SizedBox(height: 24),

              // ── Save Button ──────────────────────────────────────────────
              Obx(() => MainBtn(
                    text: controller.isEditMode
                        ? 'addNewPayment.update'.trns()
                        : 'addNewPayment.save'.trns(),
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.save(context),
                  )),
            ],
          ),
        ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left,
              color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        controller.isEditMode
            ? 'addNewPayment.editTitle'.trns()
            : 'addNewPayment.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  void _showPaymentMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => CommonDropdownBottomSheetTwo(
        title: 'addNewPayment.selectPaymentMethod'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
        dropdownItems: controller.paymentMethods,
        currentlySelectedValue: controller.paymentMethodController.text,
        onItemSelected: (val) {
          controller.paymentMethodController.text = val;
        },
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => CommonDropdownBottomSheetTwo(
        title: 'addNewPayment.selectStatus'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
        dropdownItems: controller.statusOptions,
        currentlySelectedValue: controller.statusController.text,
        onItemSelected: (val) {
          controller.statusController.text = val;
        },
      ),
    );
  }
}

// ── Field Label ────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }
}

// ── Payment Slip Field (media library single-select) ─────────────────────────
class _FileUploadField extends StatelessWidget {
  final AddNewPaymentController controller;

  const _FileUploadField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final preview = controller.slipPreviewUrl;
      final hasSlip = preview != null && preview.isNotEmpty;
      return Row(
        children: [
          if (hasSlip)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppCachedImage(
                imageUrl: preview,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
          if (hasSlip) const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.black.withValues(alpha: 0.20),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                controller.slipDisplayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (hasSlip) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.clearSlip,
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.close,
                    size: 18, color: Color(0xFF6B7280)),
              ),
            ),
          ],
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => MediaSelectorSheet.show(
              context,
              allowMultiple: false,
              initialSelectedIds: [
                ...controller.initialSlipIds,
                if (controller.selectedSlip.value != null)
                  controller.selectedSlip.value!.mediaId,
              ],
              onConfirmed: controller.onSlipConfirmed,
            ),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                hasSlip
                    ? 'addNewPayment.changeFile'.trns()
                    : 'addNewPayment.chooseFile'.trns(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}