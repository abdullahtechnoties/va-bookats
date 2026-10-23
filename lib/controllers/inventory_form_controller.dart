// lib/controllers/inventory_form_controller.dart
//
// Shared create/edit form logic for the inventory lookup modules
// (brands, product categories, tags, units, product variations).
// Each form extends this with its extra fields, validation and body.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/inventory_item.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/repositories/inventory_repository.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

abstract class InventoryFormController extends GetxController {
  final InventoryRepository repository = InventoryRepository();
  final AuthService _authService = Get.find<AuthService>();

  // ─── Module config ───────────────────────────────────────────────────────
  String get resourceBase;
  String get trPrefix;

  String tr(String key) => '$trPrefix.$key'.trns();

  /// Permission noun derived from the endpoint base
  /// (`/brands` → `brands`, `/product-categories` → `product-categories`).
  String get permResource => resourceBase.replaceFirst(RegExp(r'^/'), '');

  // ─── Edit state (prefilled from the passed model, no details fetch) ─────
  InventoryItem? editingItem;
  bool get isEditMode => editingItem?.id != null;

  // ─── Shared fields ───────────────────────────────────────────────────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();

  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxnInt selectedBranchId = RxnInt();
  final RxString selectedBranch = ''.obs;
  final RxBool isLoadingBranches = false.obs;
  final RxBool isSaving = false.obs;

  /// Branch selector is only shown to the owner role; non-owners send
  /// `branch_id: null` (backend scopes to their branch).
  bool get showBranch => _authService.isOwner;

  int? get userBranchId => _authService.currentUser.value?.branchId;

  List<String> get branchLabels =>
      branches.map((b) => b.displayLabel).toList();

  List<String> get branchValues =>
      branches.map((b) => b.value?.toString() ?? '').toList();

  // ─── Optional single image (brand logo / category image) ────────────────
  final Rxn<MediaItem> pickedImage = Rxn<MediaItem>();
  final RxnString existingImageUrl = RxnString();

  String? get pickedImageUrl =>
      pickedImage.value?.thumbnailUrl ?? pickedImage.value?.networkUrl;

  String? get imagePreviewUrl =>
      pickedImageUrl ?? existingImageUrl.value;

  // ─── Per-form hooks ──────────────────────────────────────────────────────
  /// Extra body fields beyond branch_id/name.
  Map<String, dynamic> extraFields() => const {};

  /// Extra validation, null = valid.
  String? validateExtras() => null;

  /// Prefill per-form state from the edit model.
  void prefillExtras(InventoryItem item) {}

  // ─── Lifecycle ───────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _readArguments();
    // _guardPermission();
    if (showBranch) fetchBranches();
  }

  /// Direct route opens bypass gated entry buttons: create mode needs
  /// `<resource>.create`, edit mode needs `<resource>.edit`. Denied →
  /// graceful popup, then back out on dismiss.
  void _guardPermission() {
    final need = isEditMode
        ? AppPerm.edit(permResource)
        : AppPerm.create(permResource);
    if (Permissions.can(need)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showNoAccessDialog();
      Get.back();
    });
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is InventoryItem && args.id != null) {
      editingItem = args;
      nameCtrl.text = args.name ?? '';
      if (showBranch && args.branchId != null) {
        selectedBranchId.value = args.branchId;
      }
      prefillExtras(args);
    }
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    nameCtrl.dispose();
    super.onClose();
  }

  // ─── Branch ──────────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    if (branches.isNotEmpty) return;
    isLoadingBranches.value = true;
    final response = await repository.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
      // Restore the preselected edit branch label once options arrive.
      final id = selectedBranchId.value;
      if (id != null) {
        final match = branches.firstWhereOrNull((b) => b.value == id);
        if (match != null) {
          selectedBranch.value = match.displayLabel;
          branchCtrl.text = match.displayLabel;
        }
      }
    } else {
      SnackbarService.showError(
        title: tr('errorTitle'),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    isLoadingBranches.value = false;
  }

  void onBranchSelected(dynamic value) {
    final id = value == null ? null : int.tryParse(value.toString());
    selectedBranchId.value = id;
    final match = branches.firstWhereOrNull((b) => b.value == id);
    selectedBranch.value = match?.displayLabel ?? '';
    branchCtrl.text = selectedBranch.value;
    onBranchChanged(id);
  }

  /// Hook for branch-dependent state (e.g. category parent options).
  Future<void> onBranchChanged(int? branchId) async {}

  String? validateBranch(String? value) {
    if (!showBranch) return null;
    if (selectedBranchId.value == null) {
      return tr('validation.branchRequired');
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr('validation.nameRequired');
    }
    return null;
  }

  // ─── Save ────────────────────────────────────────────────────────────────

  Future<void> save(
    BuildContext context, {
    void Function(InventoryItem item)? onSuccess,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final extraError = validateExtras();
    if (extraError != null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: extraError,
      );
      return;
    }

    final branchId = showBranch ? selectedBranchId.value : userBranchId;
    final name = nameCtrl.text.trim();
    final fields = <String, dynamic>{
      'branch_id': ?branchId,
      'name': name,
      ...extraFields(),
    };

    isSaving.value = true;
    try {
      final id = editingItem?.id;
      final response = id == null
          ? await repository.create(base: resourceBase, fields: fields)
          : await repository.update(
              base: resourceBase,
              id: id,
              fields: fields,
            );

      if (response.isCompleted) {
        SnackbarService.showSuccess(
          title: id == null ? tr('createSuccessTitle') : tr('updateSuccessTitle'),
          message: response.message ??
              (id == null
                  ? tr('createSuccessMessage')
                  : tr('updateSuccessMessage')),
        );
        final created = response.data;
        if (created != null) onSuccess?.call(created);
        if (context.mounted) {
          await NavigationHelper.safePop(context, true);
        }
      } else {
        SnackbarService.showError(
          title: tr('errorTitle'),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }
}
