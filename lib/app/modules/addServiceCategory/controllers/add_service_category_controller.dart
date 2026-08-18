// lib/app/modules/add_service_category/controllers/add_service_category_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/serviceCategories/repositories/service_category_repository.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class AddServiceCategoryController extends GetxController {
  AddServiceCategoryController({required ServiceCategoryRepository repository})
    : _repository = repository;

  final ServiceCategoryRepository _repository;
  final AuthService _authService = Get.find<AuthService>();

  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final RxString selectedBranch = ''.obs;
  final RxnInt selectedBranchId = RxnInt();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxBool isLoadingBranches = false.obs;
  final RxBool isSaving = false.obs;

  ServiceCategoryModel? _editingCategory;
  bool get isEditMode => _editingCategory != null;

  /// Branch selector is only shown to the owner role; non-owners send
  /// `branch_id: null`.
  bool get showBranch => _authService.isOwner;

  List<String> get branchLabels => branches.map((b) => b.displayLabel).toList();

  List<String> get branchValues =>
      branches.map((b) => b.value?.toString() ?? '').toList();

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    if (showBranch) {
      fetchBranches();
    }
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is ServiceCategoryModel) {
      _editingCategory = args;
      nameCtrl.text = args.name ?? '';
      if (showBranch) {
        selectedBranch.value = args.branchName;
        branchCtrl.text = args.branchName;
        selectedBranchId.value = args.branchId;
      }
    }
  }

  Future<void> fetchBranches() async {
    if (branches.isNotEmpty) return;
    isLoadingBranches.value = true;
    final response = await _repository.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
    } else {
      SnackbarService.showError(
        title: 'addServiceCategory.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    isLoadingBranches.value = false;
  }

  void onBranchSelected(dynamic value) {
    selectedBranchId.value = value == null
        ? null
        : int.tryParse(value.toString());
  }

  String? validateBranch(String? value) {
    if (!showBranch) return null;
    if (selectedBranchId.value == null) {
      return 'addServiceCategory.validation.branchRequired'.trns();
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'addServiceCategory.validation.nameRequired'.trns();
    }
    return null;
  }

  Future<void> save(
    BuildContext context, {
    void Function(ServiceCategoryModel category)? onSuccess,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final name = nameCtrl.text.trim();
    isSaving.value = true;
    try {
      final branchId = showBranch ? selectedBranchId.value : null;
      final int? id = _editingCategory?.id;

      final response = id == null
          ? await _repository.createServiceCategory(
              name: name,
              branchId: branchId,
            )
          : await _repository.updateServiceCategory(
              id: id,
              name: name,
              branchId: branchId,
            );

      if (response.isCompleted) {
        SnackbarService.showSuccess(
          title: id == null
              ? 'addServiceCategory.createSuccessTitle'.trns()
              : 'addServiceCategory.updateSuccessTitle'.trns(),
          message:
              response.message ??
              (id == null
                  ? 'addServiceCategory.createSuccessMessage'.trns()
                  : 'addServiceCategory.updateSuccessMessage'.trns()),
        );
        final created = response.data;
        if (created != null) {
          onSuccess?.call(created);
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        SnackbarService.showError(
          title: 'addServiceCategory.errorTitle'.trns(),
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
    nameCtrl.dispose();
    super.onClose();
  }
}
