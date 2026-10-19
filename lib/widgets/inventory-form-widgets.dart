// lib/widgets/inventory-form-widgets.dart
//
// Shared form shell for the inventory lookup forms (brands, product
// categories, tags, units, product variations): header, labels, the
// branch picker (with loading suffix) and the single-image picker.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/controllers/inventory_form_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';

/// Secondary header with back button + centered title.
class InventoryFormHeader extends StatelessWidget {
  final String title;

  const InventoryFormHeader({super.key, required this.title});

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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
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
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card shell for the form body.
class InventoryFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget child;

  const InventoryFormCard({
    super.key,
    required this.formKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(key: formKey, child: child),
      ),
    );
  }
}

class InventoryFieldLabel extends StatelessWidget {
  final String text;

  const InventoryFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }
}

/// Branch picker (owner only) with a loading suffix while branches load.
class InventoryBranchField extends StatelessWidget {
  final InventoryFormController controller;
  final String titleKey;
  final String hintKey;

  const InventoryBranchField({
    super.key,
    required this.controller,
    required this.titleKey,
    required this.hintKey,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.showBranch) return const SizedBox.shrink();
    return Obx(() => GestureDetector(
          onTap: controller.isLoadingBranches.value
              ? null
              : () => _showBranchPicker(context),
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
                    controller.selectedBranch.value.isEmpty
                        ? hintKey.trns()
                        : controller.selectedBranch.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.selectedBranch.value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.isLoadingBranches.value)
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

  void _showBranchPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: titleKey.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownItems:
            controller.branches.map((b) => b.displayLabel).toList(),
        textController: TextEditingController(),
        selectedValue: controller.branches
            .map((b) => b.value?.toString() ?? '')
            .toList(),
        currentlySelectedValue:
            controller.selectedBranchId.value?.toString() ?? '',
        onValueSelected: (v) => controller.onBranchSelected(v),
        showSearch: true,
      ),
    );
  }
}

/// Single image picker (media library) with preview + clear.
/// [hintKey]/[chooseKey]/[changeKey] are translation keys.
class InventoryImageField extends StatelessWidget {
  final InventoryFormController controller;
  final String chooseKey;
  final String changeKey;

  const InventoryImageField({
    super.key,
    required this.controller,
    required this.chooseKey,
    required this.changeKey,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final picked = controller.pickedImage.value;
      final preview = controller.imagePreviewUrl;
      return Row(
        children: [
          if (preview != null && preview.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppCachedImage(
                imageUrl: preview,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
          if (preview != null && preview.isNotEmpty)
            const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => MediaSelectorSheet.show(
                context,
                allowMultiple: false,
                initialSelectedIds:
                    picked == null ? const [] : [picked.mediaId],
                onConfirmed: (items) {
                  if (items.isNotEmpty) {
                    controller.pickedImage.value = items.first;
                  }
                },
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  (picked == null ? chooseKey : changeKey).trns(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          if (picked != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => controller.pickedImage.value = null,
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close,
                    size: 18, color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ],
      );
    });
  }
}
