// lib/app/modules/addService/controllers/add_service_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/app/modules/services/repositories/service_repository.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/models/service_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';

/// A single editable variation row (name + price).
class VariationInput {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;

  VariationInput({String name = '', String price = ''})
    : nameCtrl = TextEditingController(text: name),
      priceCtrl = TextEditingController(text: price);

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class AddServiceController extends GetxController {
  AddServiceController({required ServiceRepository repository})
    : _repository = repository;

  final ServiceRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ─── Form controllers ────────────────────────────────────────────────────
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController durationCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();
  final TextEditingController defaultPriceCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();

  // ─── Observable selections ───────────────────────────────────────────────
  final RxString selectedBranch = ''.obs;
  final RxnInt selectedBranchId = RxnInt();
  final RxString selectedCategory = ''.obs;
  final RxnInt selectedCategoryId = RxnInt();
  // Empty in create mode so the dropdown never pre-highlights a default; the
  // first tap always selects instead of being interpreted as a deselect.
  // (The dropdown sheet toggles off when the pre-selected item is tapped.)
  final RxString selectedStatus = ''.obs;
  final RxString selectedType = ''.obs;

  // ─── Data + states ───────────────────────────────────────────────────────
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<ServiceCategoryModel> categories = <ServiceCategoryModel>[].obs;
  final RxBool isLoadingBranches = false.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isSaving = false.obs;

  // ─── Image (media-library based) ─────────────────────────────────────────
  /// WordPress-style selection — UI reflects the chosen library item and only
  /// its `media_id` is sent to the API (no raw file upload).
  final Rxn<MediaItem> selectedMedia = Rxn<MediaItem>();
  final RxString imageFileName = RxString('');
  String? existingImageUrl;

  int? get selectedMediaId => selectedMedia.value?.mediaId;

  // ─── Variations ──────────────────────────────────────────────────────────
  final RxList<VariationInput> variationInputs = <VariationInput>[].obs;

  ServiceModel? _editingService;

  bool get isEditMode => _editingService != null;
  bool get showBranch => _authService.isOwner;
  bool get isVariationType => selectedType.value == 'variation';

  List<String> get statusOptions => ['active', 'inactive'];
  List<String> get typeOptions => ['normal', 'variation'];

  List<String> get branchLabels => branches.map((b) => b.displayLabel).toList();

  List<String> get branchValues =>
      branches.map((b) => b.value?.toString() ?? '').toList();

  List<String> get categoryLabels =>
      categories.map((c) => c.name ?? '').toList();

  List<String> get categoryValues =>
      categories.map((c) => c.id?.toString() ?? '').toList();

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    if (showBranch) {
      fetchBranches();
    }
    fetchCategories();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is! ServiceModel) return;

    _editingService = args;
    _applyService(args);
  }

  /// Populates every form field from a [ServiceModel]. The list payload
  /// already includes `type` and the full `variations`, so edit mode prefills
  /// completely from the passed service — no extra fetch needed.
  void _applyService(ServiceModel service) {
    nameCtrl.text = service.name ?? '';
    durationCtrl.text = service.serviceDuration ?? '';
    descriptionCtrl.text = service.description ?? '';
    defaultPriceCtrl.text = service.defaultPrice ?? '';
    existingImageUrl = service.imageUrl.isEmpty ? null : service.imageUrl;

    selectedStatus.value = service.status ?? 'active';
    statusCtrl.text = selectedStatus.value;

    selectedType.value = service.type ?? 'normal';
    typeCtrl.text = selectedType.value;

    for (final input in variationInputs) {
      input.dispose();
    }
    variationInputs.clear();
    for (final v in service.variations) {
      variationInputs.add(
        VariationInput(name: v.name ?? '', price: v.price ?? ''),
      );
    }

    if (categories.isNotEmpty) _prefillCategory();
    if (branches.isNotEmpty) _prefillBranch();
  }

  // ─── Data loading ────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    if (branches.isNotEmpty) return;
    isLoadingBranches.value = true;
    final response = await _repository.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
      _prefillBranch();
    } else {
      SnackbarService.showError(
        title: 'addService.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    isLoadingBranches.value = false;
  }

  Future<void> fetchCategories() async {
    if (categories.isNotEmpty) return;
    isLoadingCategories.value = true;
    final response = await _repository.getCategories();
    if (response.isCompleted && response.data != null) {
      categories.assignAll(_dedupeCategories(response.data!));
      _prefillCategory();
    } else {
      SnackbarService.showError(
        title: 'addService.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    isLoadingCategories.value = false;
  }

  /// Collapses duplicate categories so the dropdown never repeats a row.
  /// Duplicates may be repeated rows (same id) or the same name existing for
  /// several branches; when a duplicate matches the service being edited, it
  /// is kept so the preselected value is preserved.
  List<ServiceCategoryModel> _dedupeCategories(
    List<ServiceCategoryModel> list,
  ) {
    final result = <ServiceCategoryModel>[];
    final seenIds = <int>{};
    final selectedId = _editingService?.categoryId;

    for (final category in list) {
      final id = category.id;
      if (id == null || !seenIds.add(id)) continue;

      final name = (category.name ?? '').trim();
      if (name.isEmpty) {
        result.add(category);
        continue;
      }

      final existingIndex = result.indexWhere(
        (c) => (c.name ?? '').trim() == name,
      );
      if (existingIndex == -1) {
        result.add(category);
      } else if (id == selectedId) {
        result[existingIndex] = category;
      }
    }
    return result;
  }

  /// Adds a freshly created category and selects it in the form so it is
  /// immediately usable without reopening the screen.
  void onCategoryCreated(ServiceCategoryModel category) {
    categories.add(category);
    categories.value = _dedupeCategories(categories);
    selectedCategory.value = category.name ?? '';
    categoryCtrl.text = category.name ?? '';
    selectedCategoryId.value = category.id;
  }

  void _prefillBranch() {
    final id = _editingService?.branchId;
    if (id == null) return;
    for (final b in branches) {
      if (b.value == id) {
        selectedBranch.value = b.displayLabel;
        branchCtrl.text = b.displayLabel;
        selectedBranchId.value = id;
        break;
      }
    }
  }

  void _prefillCategory() {
    final id = _editingService?.categoryId;
    if (id == null) return;
    for (final c in categories) {
      if (c.id == id) {
        selectedCategory.value = c.name ?? '';
        categoryCtrl.text = c.name ?? '';
        selectedCategoryId.value = id;
        break;
      }
    }
  }

  // ─── Dropdown callbacks ──────────────────────────────────────────────────

  void onBranchSelected(dynamic value) {
    selectedBranchId.value = value == null
        ? null
        : int.tryParse(value.toString());
  }

  void onCategorySelected(dynamic value) {
    selectedCategoryId.value = value == null
        ? null
        : int.tryParse(value.toString());
  }

  // ─── Variations ──────────────────────────────────────────────────────────

  void addVariation() {
    variationInputs.add(VariationInput());
  }

  void removeVariation(int index) {
    if (index < 0 || index >= variationInputs.length) return;
    variationInputs[index].dispose();
    variationInputs.removeAt(index);
  }

  List<VariationDraft> _buildVariationDrafts() {
    final drafts = <VariationDraft>[];
    for (final input in variationInputs) {
      final name = input.nameCtrl.text.trim();
      final price = input.priceCtrl.text.trim();
      if (name.isEmpty || price.isEmpty) continue;
      drafts.add(VariationDraft(name: name, price: price));
    }
    return drafts;
  }

  // ─── Validators ──────────────────────────────────────────────────────────

  String? validateBranch(String? value) {
    if (!showBranch) return null;
    if (selectedBranchId.value == null) {
      return 'addService.validation.branchRequired'.trns();
    }
    return null;
  }

  String? validateCategory(String? value) {
    if (selectedCategoryId.value == null) {
      return 'addService.validation.categoryRequired'.trns();
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'addService.validation.nameRequired'.trns();
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (isVariationType) return null;
    final price = value?.trim() ?? '';
    if (price.isEmpty) {
      return 'addService.validation.priceRequired'.trns();
    }
    if (double.tryParse(price) == null) {
      return 'addService.validation.priceInvalid'.trns();
    }
    return null;
  }

  // ─── Image picking (media library) ───────────────────────────────────────

  /// Opens the WordPress-style media library sheet (single-select). The user
  /// can upload a new image there — it appears in realtime — or pick an
  /// existing one. UI reflects the selection; only `media_id` is sent.
  void pickImage(BuildContext context) {
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds: selectedMedia.value == null
          ? const []
          : [selectedMedia.value!.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        selectedMedia.value = items.first;
        imageFileName.value = items.first.name;
        existingImageUrl = null;
      },
    );
  }

  void clearImage() {
    selectedMedia.value = null;
    imageFileName.value = '';
    // In edit mode clearing reveals the original URL again? No — treat clear
    // as "remove override"; existingImageUrl stays for display fallback.
  }

  // ─── Save ────────────────────────────────────────────────────────────────

  Future<void> save(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (isVariationType) {
      if (variationInputs.isEmpty) {
        SnackbarService.showError(
          title: 'addService.errorTitle'.trns(),
          message: 'addService.validation.variationAtLeastOne'.trns(),
        );
        return;
      }
      if (_buildVariationDrafts().isEmpty) {
        SnackbarService.showError(
          title: 'addService.errorTitle'.trns(),
          message: 'addService.validation.variationRequired'.trns(),
        );
        return;
      }
    }

    final int? id = _editingService?.id;
    final branchId = showBranch ? selectedBranchId.value : null;
    final status = selectedStatus.value.isEmpty
        ? 'active'
        : selectedStatus.value;
    final type = selectedType.value.isEmpty ? 'normal' : selectedType.value;
    final bool isVariation = type == 'variation';
    // Only the relevant payload for the chosen type reaches the API:
    // default_price is a normal-service field, variations a variation one.
    final defaultPrice = isVariation ? null : defaultPriceCtrl.text.trim();
    final variations = isVariation
        ? _buildVariationDrafts()
        : <VariationDraft>[];

    isSaving.value = true;
    try {
      final response = id == null
          ? await _repository.createService(
              branchId: branchId,
              categoryId: selectedCategoryId.value,
              name: nameCtrl.text.trim(),
              serviceDuration: durationCtrl.text.trim(),
              status: status,
              type: type,
              defaultPrice: defaultPrice,
              description: descriptionCtrl.text.trim(),
              variations: variations,
              mediaId: selectedMediaId,
            )
          : await _repository.updateService(
              id: id,
              branchId: branchId,
              categoryId: selectedCategoryId.value,
              name: nameCtrl.text.trim(),
              serviceDuration: durationCtrl.text.trim(),
              status: status,
              type: type,
              defaultPrice: defaultPrice,
              description: descriptionCtrl.text.trim(),
              variations: variations,
              mediaId: selectedMediaId,
            );

      if (response.isCompleted) {
        SnackbarService.showSuccess(
          title: id == null
              ? 'addService.createSuccessTitle'.trns()
              : 'addService.updateSuccessTitle'.trns(),
          message:
              response.message ??
              (id == null
                  ? 'addService.createSuccessMessage'.trns()
                  : 'addService.updateSuccessMessage'.trns()),
        );
        // Let the snackbar paint before popping — avoids the GetX race where
        // going back instantly swallows/dismisses the success toast.
        if (!context.mounted) return;
        await NavigationHelper.safePop(context);
      } else {
        SnackbarService.showError(
          title: 'addService.errorTitle'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    categoryCtrl.dispose();
    nameCtrl.dispose();
    durationCtrl.dispose();
    statusCtrl.dispose();
    typeCtrl.dispose();
    defaultPriceCtrl.dispose();
    descriptionCtrl.dispose();
    for (final input in variationInputs) {
      input.dispose();
    }
    super.onClose();
  }
}
