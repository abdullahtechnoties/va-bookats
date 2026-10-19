import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addProduct/controllers/add_product_controller.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/app/modules/products/views/widgets/rounded_app_bar.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: RoundedOrangeAppBar(
        title: controller.isEditMode
            ? 'addProduct.editTitle'.trns()
            : 'addProduct.title'.trns(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isPrefilling.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.navOutline.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isEditMode
                      ? 'addProduct.editHeading'.trns()
                      : 'addProduct.formTitle'.trns(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Product type (top selector) ─────────────────────────
                _FormLabel(text: 'addProduct.labels.productType'.trns()),
                _TypeSelector(controller: controller),
                const SizedBox(height: 16),

                // ── Branch (first: everything below depends on it) ─────
                _FormLabel(text: 'addProduct.labels.branch'.trns()),
                _PickerField(
                  hint: 'addProduct.placeholders.selectBranch'.trns(),
                  value: controller.branchLabel.value,
                  isLoading: controller.isLoadingBranches.value,
                  onTap: () => _showBranchPicker(context),
                ),
                const SizedBox(height: 16),

                // ── Name ────────────────────────────────────────────────
                _FormLabel(text: 'addProduct.labels.name'.trns()),
                CommonTextInputField(
                  hintText: 'addProduct.placeholders.enterFullName'.trns(),
                  controller: controller.nameCtrl,
                ),
                const SizedBox(height: 16),

                // ── Short description ───────────────────────────────────
                _FormLabel(text: 'addProduct.labels.shortDescription'.trns()),
                CommonTextInputField(
                  hintText:
                      'addProduct.placeholders.enterShortDescription'.trns(),
                  controller: controller.shortDescCtrl,
                ),
                const SizedBox(height: 16),

                // ── Images (media library, multi) ───────────────────────
                _FormLabel(text: 'addProduct.labels.images'.trns()),
                _ImagesField(controller: controller),
                const SizedBox(height: 16),

                // ── Description ─────────────────────────────────────────
                _FormLabel(text: 'addProduct.labels.description'.trns()),
                CommonTextInputField(
                  hintText: 'addProduct.placeholders.writeSomething'.trns(),
                  controller: controller.descCtrl,
                  maxLines: 4,
                  height: 100,
                ),
                const SizedBox(height: 16),

                // ── Brand (+ runtime add) ───────────────────────────────
                _LabelWithAction(
                  label: 'addProduct.labels.brand'.trns(),
                  actionText: 'addProduct.actions.addBrand'.trns(),
                  onActionTap: () => _showAddBrandDialog(context),
                ),
                _PickerField(
                  hint: 'addProduct.placeholders.selectBrand'.trns(),
                  value: controller.brandLabel.value,
                  isLoading: controller.isLoadingBrands.value,
                  onTap: () {
                    if (!controller.ensureBranch()) return;
                    _showSinglePicker(
                      context,
                      title: 'addProduct.labels.brand'.trns(),
                      items: controller.brands
                          .map((b) => b.label)
                          .toList(),
                      values: controller.brands
                          .map((b) => b.value.toString())
                          .toList(),
                      current: controller.selectedBrandId.value?.toString() ??
                          '',
                      onPick: (v) => controller.selectBrand(
                          int.tryParse(v.toString()) ?? 0),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Categories (multi + runtime add) ────────────────────
                _LabelWithAction(
                  label: 'addProduct.labels.categories'.trns(),
                  actionText: 'addProduct.actions.addCategory'.trns(),
                  onActionTap: () => _showAddCategoryDialog(context),
                ),
                _MultiPickerField(
                  hint: 'addProduct.placeholders.selectCategories'.trns(),
                  display: _multiDisplay(
                    controller.selectedCategoryIds,
                    controller.categories
                        .map((c) => MapEntry(c.value, c.label)),
                  ),
                  isLoading: controller.isLoadingCategories.value,
                  onTap: () {
                    if (!controller.ensureBranch()) return;
                    _showMultiPicker(
                      context,
                      title: 'addProduct.labels.categories'.trns(),
                      items: controller.categories,
                      selected: controller.selectedCategoryIds,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Tags (multi + runtime add) ──────────────────────────
                _LabelWithAction(
                  label: 'addProduct.labels.tags'.trns(),
                  actionText: 'addProduct.actions.addTags'.trns(),
                  onActionTap: () => _showAddTagDialog(context),
                ),
                _MultiPickerField(
                  hint: 'addProduct.placeholders.selectTags'.trns(),
                  display: _multiDisplay(
                    controller.selectedTagIds,
                    controller.tags.map((t) => MapEntry(t.value, t.label)),
                  ),
                  isLoading: controller.isLoadingTags.value,
                  onTap: () {
                    if (!controller.ensureBranch()) return;
                    _showMultiPicker(
                      context,
                      title: 'addProduct.labels.tags'.trns(),
                      items: controller.tags,
                      selected: controller.selectedTagIds,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Unit (+ runtime add) ────────────────────────────────
                _LabelWithAction(
                  label: 'addProduct.labels.units'.trns(),
                  actionText: 'addProduct.actions.addUnits'.trns(),
                  onActionTap: () => _showAddUnitDialog(context),
                ),
                _PickerField(
                  hint: 'addProduct.placeholders.selectUnits'.trns(),
                  value: controller.unitLabel.value,
                  isLoading: controller.isLoadingUnits.value,
                  onTap: () {
                    if (!controller.ensureBranch()) return;
                    _showSinglePicker(
                      context,
                      title: 'addProduct.labels.units'.trns(),
                      items:
                          controller.units.map((u) => u.label).toList(),
                      values: controller.units
                          .map((u) => u.value.toString())
                          .toList(),
                      current:
                          controller.selectedUnitId.value?.toString() ?? '',
                      onPick: (v) => controller.selectUnit(
                          int.tryParse(v.toString()) ?? 0),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Status ──────────────────────────────────────────────
                _FormLabel(text: 'addProduct.labels.status'.trns()),
                _PickerField(
                  hint: 'addProduct.placeholders.selectStatus'.trns(),
                  value: controller.status.value == 'active'
                      ? 'products.card.active'.trns()
                      : 'products.card.inactive'.trns(),
                  onTap: () => _showSinglePicker(
                    context,
                    title: 'addProduct.labels.status'.trns(),
                    items: [
                      'products.card.active'.trns(),
                      'products.card.inactive'.trns(),
                    ],
                    values: const ['active', 'inactive'],
                    current: controller.status.value,
                    onPick: (v) => controller.setStatus(v.toString()),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Type-specific section ───────────────────────────────
                if (controller.isSimple) ...[
                  _FormLabel(text: 'addProduct.labels.price'.trns()),
                  CommonTextInputField(
                    hintText: 'addProduct.placeholders.enterPrice'.trns(),
                    controller: controller.priceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _FormLabel(text: 'addProduct.labels.stock'.trns()),
                  CommonTextInputField(
                    hintText: 'addProduct.placeholders.enterStock'.trns(),
                    controller: controller.stockCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _FormLabel(text: 'addProduct.labels.sku'.trns()),
                  CommonTextInputField(
                    hintText: 'addProduct.placeholders.enterSku'.trns(),
                    controller: controller.skuCtrl,
                  ),
                  const SizedBox(height: 16),
                  _FormLabel(text: 'addProduct.labels.code'.trns()),
                  CommonTextInputField(
                    hintText: 'addProduct.placeholders.enterCode'.trns(),
                    controller: controller.codeCtrl,
                  ),
                ] else ...[
                  _VariationSets(controller: controller),
                  const SizedBox(height: 16),
                  _Combinations(controller: controller),
                ],
                const SizedBox(height: 24),

                // ── Save ────────────────────────────────────────────────
                Obx(() => MainBtn(
                      text: controller.isEditMode
                          ? 'addProduct.actions.update'.trns()
                          : 'addProduct.actions.save'.trns(),
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

  // ── Pickers ─────────────────────────────────────────────────────────────

  void _showBranchPicker(BuildContext context) {
    _showSinglePicker(
      context,
      title: 'addProduct.labels.branch'.trns(),
      items: controller.branches.map((b) => b.displayLabel).toList(),
      values:
          controller.branches.map((b) => b.value.toString()).toList(),
      current: controller.selectedBranchId.value?.toString() ?? '',
      onPick: (v) {
        final id = int.tryParse(v.toString());
        if (id != null) controller.selectBranch(id);
      },
    );
  }

  void _showSinglePicker(
    BuildContext context, {
    required String title,
    required List<String> items,
    required List<String> values,
    required String current,
    required Function(dynamic) onPick,
  }) {
    showSinglePickerSheet(
      context,
      title: title,
      items: items,
      values: values,
      current: current,
      onPick: onPick,
    );
  }

  void _showMultiPicker(
    BuildContext context, {
    required String title,
    required List<ProductLookup> items,
    required RxSet<int> selected,
  }) {
    final RxSet<String> temp =
        selected.map((e) => e.toString()).toSet().obs;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.6,
        dropdownItems: items.map((e) => e.label).toList(),
        textController: TextEditingController(),
        selectedValue: items.map((e) => e.value.toString()).toList(),
        currentlySelectedValue: '',
        isMultiSelect: true,
        selectedValues: temp,
        doneButtonText: 'reports.common.done'.trns(),
        onDone: () {
          selected.assignAll(
            temp.map((e) => int.tryParse(e)).whereType<int>().toSet(),
          );
        },
        showSearch: true,
      ),
    );
  }

  String _multiDisplay(
    Set<int> selected,
    Iterable<MapEntry<int, String>> options,
  ) {
    if (selected.isEmpty) return '';
    final byId = {for (final o in options) o.key: o.value};
    final names =
        selected.map((id) => byId[id]).whereType<String>().toList();
    if (names.isEmpty) return '${selected.length} selected';
    if (names.length == 1) return names.first;
    return '${names.first} +${names.length - 1}';
  }

  // ── Runtime-add dialogs ─────────────────────────────────────────────────

  void _showAddBrandDialog(BuildContext context) {
    if (!controller.ensureBranch()) return;
    _showNameDialog(
      context,
      title: 'addProduct.popups.addBrand'.trns(),
      label: 'addProduct.labels.brand'.trns(),
      withImage: true,
    ).then((result) {
      if (result == null) return;
      controller.createBrand(
        result.name,
        logoMediaId: result.mediaId,
      );
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    if (!controller.ensureBranch()) return;
    showDialog(
      context: context,
      builder: (_) => _CategoryDialog(controller: controller),
    ).then((result) {
      if (result is _CategoryResult) {
        controller.createCategory(
          result.name,
          parentId: result.parentId,
          mediaId: result.mediaId,
        );
      }
    });
  }

  void _showAddTagDialog(BuildContext context) {
    if (!controller.ensureBranch()) return;
    _showNameDialog(
      context,
      title: 'addProduct.popups.addTag'.trns(),
      label: 'addProduct.labels.tags'.trns(),
    ).then((result) {
      if (result != null) controller.createTag(result.name);
    });
  }

  void _showAddUnitDialog(BuildContext context) {
    if (!controller.ensureBranch()) return;
    _showNameDialog(
      context,
      title: 'addProduct.popups.addUnit'.trns(),
      label: 'addProduct.labels.units'.trns(),
    ).then((result) {
      if (result != null) controller.createUnit(result.name);
    });
  }

  Future<_NameResult?> _showNameDialog(
    BuildContext context, {
    required String title,
    required String label,
    bool withImage = false,
  }) {
    final nameCtrl = TextEditingController();
    MediaItem? picked;
    return showDialog<_NameResult>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
               shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.white,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextInputField(
                hintText: label,
                controller: nameCtrl,
              ),
              if (withImage) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (picked != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppCachedImage(
                          imageUrl: picked!.thumbnailUrl ?? picked!.networkUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (picked != null) const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => MediaSelectorSheet.show(
                          context,
                          allowMultiple: false,
                          initialSelectedIds: picked == null
                              ? const []
                              : [picked!.mediaId],
                          onConfirmed: (items) {
                            if (items.isNotEmpty) {
                              setState(() => picked = items.first);
                            }
                          },
                        ),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            picked == null
                                ? 'addProduct.actions.chooseFile'.trns()
                                : 'addProduct.actions.changeFile'.trns(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('products.cancel'.trns()),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Get.back(
                  result: _NameResult(
                    nameCtrl.text.trim(),
                    mediaId: picked?.mediaId,
                  ),
                );
              },
              child: Text(
                'products.confirm'.trns(),
                style: const TextStyle(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(nameCtrl.dispose);
  }
}

// ── Shared single-select sheet (used by the form + nested set rows) ─────────

void showAddVariationDialog(
    BuildContext context, AddProductController controller) {
  if (!controller.ensureBranch()) return;
  showDialog(
    context: context,
    builder: (_) => _VariationDialog(controller: controller),
  );
}

void showSinglePickerSheet(
  BuildContext context, {
  required String title,
  required List<String> items,
  required List<String> values,
  required String current,
  required Function(dynamic) onPick,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommonDropdownBottomSheetThree(
      title: title,
      bottomSheetHeight: MediaQuery.of(context).size.height * 0.55,
      dropdownItems: items,
      textController: TextEditingController(),
      selectedValue: values,
      currentlySelectedValue: current,
      onValueSelected: onPick,
      showSearch: true,
    ),
  );
}

// ── Small widgets ───────────────────────────────────────────────────────────

class _NameResult {
  final String name;
  final int? mediaId;
  _NameResult(this.name, {this.mediaId});
}

class _CategoryResult {
  final String name;
  final int? parentId;
  final int? mediaId;
  _CategoryResult({required this.name, this.parentId, this.mediaId});
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _LabelWithAction extends StatelessWidget {
  final String label;
  final String actionText;
  final VoidCallback onActionTap;

  const _LabelWithAction({
    required this.label,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only dropdown field with an optional loading suffix.
class _PickerField extends StatelessWidget {
  final String hint;
  final String value;
  final bool isLoading;
  final VoidCallback onTap;

  const _PickerField({
    required this.hint,
    required this.value,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: value.isEmpty
                      ? const Color(0xFF9CA3AF)
                      : AppColors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select field showing the selection summary.
class _MultiPickerField extends StatelessWidget {
  final String hint;
  final String display;
  final bool isLoading;
  final VoidCallback onTap;

  const _MultiPickerField({
    required this.hint,
    required this.display,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PickerField(
      hint: hint,
      value: display,
      isLoading: isLoading,
      onTap: onTap,
    );
  }
}

/// Product type segmented selector (top of the form).
class _TypeSelector extends StatelessWidget {
  final AddProductController controller;

  const _TypeSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSimple =
          controller.productType.value == ProductType.simple;
      return Row(
        children: [
          Expanded(
            child: _TypeOption(
              label: 'addProduct.types.simple'.trns(),
              selected: isSimple,
              onTap: () => controller.setProductType(ProductType.simple),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeOption(
              label: 'addProduct.types.variation'.trns(),
              selected: !isSimple,
              onTap: () => controller.setProductType(ProductType.variation),
            ),
          ),
        ],
      );
    });
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary
              : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.secondary
                : AppColors.black.withValues(alpha: 0.15),
            width: selected ? 0 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}

/// Gallery preview (kept + picked) with remove actions + add button.
class _ImagesField extends StatelessWidget {
  final AddProductController controller;

  const _ImagesField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final kept = controller.keptMedia;
      final picked = controller.pickedImages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kept.isNotEmpty || picked.isNotEmpty)
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: kept.length + picked.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isKept = i < kept.length;
                  final url = isKept
                      ? (kept[i].thumbnailUrl ?? kept[i].url)
                      : (picked[i - kept.length].thumbnailUrl ??
                          picked[i - kept.length].networkUrl);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AppCachedImage(
                          imageUrl: url,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => isKept
                              ? controller.removeKeptMedia(kept[i])
                              : controller
                                  .removePickedImage(picked[i - kept.length]),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xCC000000),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 13,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (kept.isNotEmpty || picked.isNotEmpty)
            const SizedBox(height: 10),
          GestureDetector(
            onTap: () => MediaSelectorSheet.show(
              context,
              allowMultiple: true,
              initialSelectedIds: controller.initialImageIds,
              onConfirmed: controller.onImagesConfirmed,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    (kept.isNotEmpty || picked.isNotEmpty)
                        ? 'addProduct.actions.changeImages'.trns()
                        : 'addProduct.actions.chooseFile'.trns(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Variation sets builder.
class _VariationSets extends StatelessWidget {
  final AddProductController controller;

  const _VariationSets({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'addProduct.labels.variationSets'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        showAddVariationDialog(context, controller),
                    child: Text(
                      'addProduct.actions.addVariation'.trns(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => controller.addSet(),
                    child: Text(
                      'addProduct.actions.addSet'.trns(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (controller.sets.isEmpty)
            Text(
              'addProduct.messages.noSets'.trns(),
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ...controller.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${'addProduct.labels.variationSet'.trns()} ${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.removeSet(index),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _PickerField(
                    hint: 'addProduct.placeholders.selectVariation'.trns(),
                    value: set.typeLabel.value,
                    isLoading:
                        controller.isLoadingVariationTypes.value,
                    onTap: () {
                      if (!controller.ensureBranch()) return;
                      // ignore: invalid_use_of_protected_member
                      _showTypePicker(context, set);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SetValues(controller: controller, set: set),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  void _showTypePicker(BuildContext context, VariationSetDraft set) {
    showSinglePickerSheet(
      context,
      title: 'addProduct.labels.variation'.trns(),
      items: controller.variationTypes.map((t) => t.label).toList(),
      values: controller.variationTypes
          .map((t) => t.value.toString())
          .toList(),
      current: set.typeId.value?.toString() ?? '',
      onPick: (v) {
        final id = int.tryParse(v.toString());
        if (id != null) controller.selectSetType(set, id);
      },
    );
  }
}

/// Values multi-select for one set.
class _SetValues extends StatelessWidget {
  final AddProductController controller;
  final VariationSetDraft set;

  const _SetValues({required this.controller, required this.set});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (set.typeId.value == null) {
        return Text(
          'addProduct.messages.selectTypeFirst'.trns(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        );
      }
      if (set.isLoadingValues.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      if (set.values.isEmpty) {
        return Text(
          'addProduct.messages.noValues'.trns(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: set.values.map((v) {
          final selected =
              v.id != null && set.selectedValueIds.contains(v.id);
          return GestureDetector(
            onTap: v.id == null
                ? null
                : () => controller.toggleSetValue(set, v.id!),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.secondary
                    : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.secondary
                      : const Color(0xFFD1D5DB),
                ),
              ),
              child: Text(
                v.name ?? '',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

/// Auto-generated combinations with editable price/stock/sku/code.
class _Combinations extends StatelessWidget {
  final AddProductController controller;

  const _Combinations({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.combinations.isEmpty) {
        return Text(
          'addProduct.messages.noCombinations'.trns(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'addProduct.labels.combinations'.trns()} (${controller.combinations.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...controller.combinations.asMap().entries.map((entry) {
            final combo = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    combo.name.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextInputField(
                          hintText: 'addProduct.placeholders.enterPrice'.trns(),
                          controller: combo.priceCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonTextInputField(
                          hintText: 'addProduct.placeholders.enterStock'.trns(),
                          controller: combo.stockCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextInputField(
                          hintText: 'addProduct.placeholders.enterSku'.trns(),
                          controller: combo.skuCtrl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonTextInputField(
                          hintText: 'addProduct.placeholders.enterCode'.trns(),
                          controller: combo.codeCtrl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

/// Runtime-add category dialog (name + optional parent + image).
class _CategoryDialog extends StatefulWidget {
  final AddProductController controller;

  const _CategoryDialog({required this.controller});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final nameCtrl = TextEditingController();
  int? parentId;
  String parentLabel = '';
  MediaItem? logo;

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AlertDialog(
           shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.white,
      title: Text('addProduct.popups.addCategory'.trns()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonTextInputField(
              hintText: 'addProduct.placeholders.enterName'.trns(),
              controller: nameCtrl,
            ),
            const SizedBox(height: 12),
            _PickerField(
              hint: 'addProduct.placeholders.selectParentCategory'.trns(),
              value: parentLabel,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CommonDropdownBottomSheetThree(
                  title: 'addProduct.placeholders.selectParentCategory'.trns(),
                  bottomSheetHeight:
                      MediaQuery.of(context).size.height * 0.55,
                  dropdownItems: [
                    'addProduct.placeholders.noParent'.trns(),
                    ...controller.categories.map((c) => c.label),
                  ],
                  textController: TextEditingController(),
                  selectedValue: [
                    '',
                    ...controller.categories.map((c) => c.value.toString()),
                  ],
                  currentlySelectedValue: parentId?.toString() ?? '',
                  onValueSelected: (v) {
                    final raw = v.toString();
                    setState(() {
                      parentId =
                          raw.isEmpty ? null : int.tryParse(raw);
                      parentLabel = raw.isEmpty
                          ? ''
                          : controller.categories
                                  .firstWhereOrNull(
                                      (c) => c.value.toString() == raw)
                                  ?.label ??
                              '';
                    });
                  },
                  showSearch: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (logo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppCachedImage(
                      imageUrl:
                          logo!.thumbnailUrl ?? logo!.networkUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (logo != null) const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => MediaSelectorSheet.show(
                      context,
                      allowMultiple: false,
                      initialSelectedIds:
                          logo == null ? const [] : [logo!.mediaId],
                      onConfirmed: (items) {
                        if (items.isNotEmpty) {
                          setState(() => logo = items.first);
                        }
                      },
                    ),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        logo == null
                            ? 'addProduct.actions.chooseFile'.trns()
                            : 'addProduct.actions.changeFile'.trns(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('products.cancel'.trns()),
        ),
        TextButton(
          onPressed: () {
            if (nameCtrl.text.trim().isEmpty) return;
            Get.back(
              result: _CategoryResult(
                name: nameCtrl.text.trim(),
                parentId: parentId,
                mediaId: logo?.mediaId,
              ),
            );
          },
          child: Text(
            'products.confirm'.trns(),
            style: const TextStyle(color: AppColors.secondary),
          ),
        ),
      ],
    );
  }
}

/// Runtime-add variation dialog (name + dynamic value rows).
class _VariationDialog extends StatefulWidget {
  final AddProductController controller;

  const _VariationDialog({required this.controller});

  @override
  State<_VariationDialog> createState() => _VariationDialogState();
}

class _VariationDialogState extends State<_VariationDialog> {
  final nameCtrl = TextEditingController();
  final valueCtrls = <TextEditingController>[TextEditingController()];

  @override
  void dispose() {
    nameCtrl.dispose();
    for (final c in valueCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        
      ),
      backgroundColor: AppColors.white,
      title: Text('addProduct.popups.addVariation'.trns()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonTextInputField(
              hintText: 'addProduct.placeholders.enterVariationName'.trns(),
              controller: nameCtrl,
            ),
            const SizedBox(height: 12),
            Text(
              'addProduct.labels.valueNames'.trns(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...valueCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonTextInputField(
                        hintText:
                            '${'addProduct.placeholders.enterName'.trns()} ${i + 1}',
                        controller: ctrl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (valueCtrls.length <= 1) return;
                        setState(() {
                          ctrl.dispose();
                          valueCtrls.removeAt(i);
                        });
                      },
                      child: const Icon(
                        Icons.remove_circle_outline,
                        color: Color(0xFFC62828),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              );
            }),
            GestureDetector(
              onTap: () => setState(
                () => valueCtrls.add(TextEditingController()),
              ),
              child: Text(
                'addProduct.actions.addValue'.trns(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('products.cancel'.trns()),
        ),
        Obx(() => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final values = valueCtrls
                          .map((c) => c.text.trim())
                          .where((v) => v.isNotEmpty)
                          .toList();
                      if (values.isEmpty) return;
                      controller
                          .createVariationType(
                        nameCtrl.text.trim(),
                        values,
                      ).then((ok) {
                        if (ok) Get.back();
                      });
                    },
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'addProduct.actions.addVariation'.trns(),
                      style:
                          const TextStyle(color: AppColors.secondary),
                    ),
            )),
      ],
    );
  }
}

