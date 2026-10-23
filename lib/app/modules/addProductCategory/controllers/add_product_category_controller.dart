import 'package:get/get.dart';
import 'package:va_bookats/controllers/inventory_form_controller.dart';
import 'package:va_bookats/models/inventory_item.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class AddProductCategoryController extends InventoryFormController {
  @override
  String get resourceBase => ApiPath.productCategories;

  @override
  String get trPrefix => 'addProductCategory';

  // ── Parent category (optional, branch-scoped tree) ──────────────────────
  final RxList<ProductLookup> parentOptions = <ProductLookup>[].obs;
  final RxnInt selectedParentId = RxnInt();
  final RxString parentLabel = ''.obs;
  final RxBool isLoadingParents = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!showBranch && !isEditMode) {
      fetchParents();
    }
  }

  @override
  Future<void> onBranchChanged(int? branchId) async {
    super.onBranchChanged(branchId);
    selectedParentId.value = null;
    parentLabel.value = '';
    await fetchParents();
  }

  Future<void> fetchParents() async {
    final branchId =
        selectedBranchId.value ?? (showBranch ? null : userBranchId);
    if (branchId == null) {
      parentOptions.clear();
      return;
    }
    isLoadingParents.value = true;
    final response = await repository
        .fetchLookupOptions(ApiPath.dataProductCategories(branchId));
    isLoadingParents.value = false;
    if (response.isCompleted && response.data != null) {
      final flat = response.data!
          .expand((o) => o.flattened)
          .toList(growable: false);
      // A category can never be its own parent.
      parentOptions.assignAll(
        flat.where((o) => o.value != editingItem?.id),
      );
      final kept = selectedParentId.value;
      if (kept != null &&
          parentOptions.every((o) => o.value != kept)) {
        selectedParentId.value = null;
        parentLabel.value = '';
      }
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  void selectParent(int? id) {
    selectedParentId.value = id;
    parentLabel.value = id == null
        ? ''
        : parentOptions.firstWhereOrNull((o) => o.value == id)?.label ?? '';
  }

  @override
  Map<String, dynamic> extraFields() {
    final mediaId = pickedImage.value?.mediaId;
    return {
      'parent_id': ?selectedParentId.value,
      'media_id': ?mediaId,
    };
  }

  @override
  void prefillExtras(InventoryItem item) {
    existingImageUrl.value = item.thumbUrl ?? item.imageUrl;
    if (item.parentId != null) {
      selectedParentId.value = item.parentId;
      fetchParents().then((_) {
        parentLabel.value = parentOptions
                .firstWhereOrNull((o) => o.value == item.parentId)
                ?.label ??
            '';
      });
    }
  }
}
