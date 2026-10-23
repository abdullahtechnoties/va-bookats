// lib/app/modules/addProduct/controllers/add_product_controller.dart

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addProduct/repositories/add_product_repository.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/app/modules/products/repositories/product_repository.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// API product-type values (backend expects these exact strings).
class ProductType {
  static const String simple = 'Simple Product';
  static const String variation = 'Variation Product';
}

/// One variation set row: a type + its selected values.
class VariationSetDraft {
  final RxnInt typeId = RxnInt();
  final RxString typeLabel = ''.obs;
  final RxList<VariationValue> values = <VariationValue>[].obs;
  final RxSet<int> selectedValueIds = <int>{}.obs;
  final RxBool isLoadingValues = false.obs;
}

/// One sellable combination row (cartesian product of the sets).
class CombinationDraft {
  final RxString name;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController codeCtrl;

  CombinationDraft({
    required String name,
    String price = '',
    String stock = '',
    String sku = '',
    String code = '',
  }) : name = name.obs,
       priceCtrl = TextEditingController(text: price),
       stockCtrl = TextEditingController(text: stock),
       skuCtrl = TextEditingController(text: sku),
       codeCtrl = TextEditingController(text: code);

  void dispose() {
    priceCtrl.dispose();
    stockCtrl.dispose();
    skuCtrl.dispose();
    codeCtrl.dispose();
  }
}

class AddProductController extends GetxController {
  AddProductController({required AddProductRepository repository})
    : _formRepo = repository;

  final AddProductRepository _formRepo;
  final ProductRepository _productRepo = ProductRepository();
  final AuthService _auth = Get.find<AuthService>();

  // ── Mode ────────────────────────────────────────────────────────────────
  int? editingId;
  bool get isEditMode => editingId != null;

  // ── Product type (top selector) ─────────────────────────────────────────
  final RxString productType = ProductType.simple.obs;
  bool get isSimple => productType.value == ProductType.simple;

  // ── Text fields ─────────────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final shortDescCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  // ── Status ──────────────────────────────────────────────────────────────
  final RxString status = 'active'.obs;

  // ── Branch (first: every lookup below depends on it) ───────────────────
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxnInt selectedBranchId = RxnInt();
  final RxString branchLabel = ''.obs;
  final RxBool isLoadingBranches = false.obs;

  bool get isOwner => _auth.isOwner;
  int? get userBranchId => _auth.currentUser.value?.branchId;

  // ── Branch-scoped lookups ───────────────────────────────────────────────
  final RxList<ProductLookup> brands = <ProductLookup>[].obs;
  final RxnInt selectedBrandId = RxnInt();
  final RxString brandLabel = ''.obs;
  final RxBool isLoadingBrands = false.obs;

  final RxList<ProductLookup> categories = <ProductLookup>[].obs;
  final RxSet<int> selectedCategoryIds = <int>{}.obs;
  final RxBool isLoadingCategories = false.obs;

  final RxList<ProductLookup> tags = <ProductLookup>[].obs;
  final RxSet<int> selectedTagIds = <int>{}.obs;
  final RxBool isLoadingTags = false.obs;

  final RxList<ProductLookup> units = <ProductLookup>[].obs;
  final RxnInt selectedUnitId = RxnInt();
  final RxString unitLabel = ''.obs;
  final RxBool isLoadingUnits = false.obs;

  final RxList<ProductLookup> variationTypes = <ProductLookup>[].obs;
  final RxBool isLoadingVariationTypes = false.obs;

  /// Values cache per variation type (probe results + runtime creates).
  final Map<int, List<VariationValue>> _valuesCache = {};

  // ── Images (media library, multi) ───────────────────────────────────────
  final RxList<MediaItem> pickedImages = <MediaItem>[].obs;

  /// Gallery kept from the details API in edit mode (removable).
  final RxList<ProductMedia> keptMedia = <ProductMedia>[].obs;

  List<int> get initialImageIds => [
    ...keptMedia.map((m) => m.id).whereType<int>(),
    ...pickedImages.map((m) => m.mediaId),
  ];

  List<int> get submitImageIds => initialImageIds;

  // ── Variation sets + combinations ───────────────────────────────────────
  final RxList<VariationSetDraft> sets = <VariationSetDraft>[].obs;
  final RxList<CombinationDraft> combinations = <CombinationDraft>[].obs;

  // ── State ───────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isPrefilling = false.obs;
  bool _suspendComboRebuild = false;

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    if (!isEditMode && isOwner) {
      fetchBranches();
    }
    if (!isOwner && userBranchId != null) {
      selectBranch(userBranchId!);
    }
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args is ProductModel && args.id != null) {
      editingId = args.id;
      _prefillFromDetails();
    } else if (args is Map && args['id'] != null) {
      editingId = int.tryParse(args['id'].toString()) ?? args['id'] as int?;
      if (editingId != null) _prefillFromDetails();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    shortDescCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    skuCtrl.dispose();
    codeCtrl.dispose();
    for (final c in combinations) {
      c.dispose();
    }
    super.onClose();
  }

  // ── Branch ──────────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    isLoadingBranches.value = true;
    final response = await _formRepo.getBranches();
    isLoadingBranches.value = false;
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
      if (!isOwner && userBranchId != null) {
        selectBranch(userBranchId!);
      }
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  /// Branch FIRST: clears every branch-scoped selection, then reloads all
  /// dropdown data for the new branch.
  Future<void> selectBranch(int id) async {
    if (selectedBranchId.value == id && brands.isNotEmpty) return;
    final match = branches.firstWhereOrNull((b) => b.value == id);
    selectedBranchId.value = id;
    branchLabel.value = match?.displayLabel ?? '';
    _clearDependents();
    if (isOwner) {
      await loadDependents();
    }
    // await loadDependents();
  }

  void _clearDependents() {
    brands.clear();
    selectedBrandId.value = null;
    brandLabel.value = '';
    categories.clear();
    selectedCategoryIds.clear();
    tags.clear();
    selectedTagIds.clear();
    units.clear();
    selectedUnitId.value = null;
    unitLabel.value = '';
    variationTypes.clear();
    _valuesCache.clear();
    for (final s in sets) {
      s.typeId.value = null;
      s.typeLabel.value = '';
      s.values.clear();
      s.selectedValueIds.clear();
    }
    sets.clear();
    _disposeCombinations();
  }

  bool get _hasBranch => selectedBranchId.value != null;

  /// Guards every dependent picker: branch must come first.
  bool ensureBranch() {
    if (_hasBranch) return true;
    SnackbarService.showError(
      title: 'common.error'.trns(),
      message: 'addProduct.validation.branchFirst'.trns(),
    );
    return false;
  }

  Future<void> loadDependents() async {
    final branchId = selectedBranchId.value;
    if (branchId == null) return;
    isLoadingBrands.value = true;
    isLoadingCategories.value = true;
    isLoadingTags.value = true;
    isLoadingUnits.value = true;
    final results = await Future.wait([
      _formRepo.getBrands(branchId),
      _formRepo.getCategories(branchId),
      _formRepo.getTags(branchId),
      _formRepo.getUnits(branchId),
    ]);
    isLoadingBrands.value = false;
    isLoadingCategories.value = false;
    isLoadingTags.value = false;
    isLoadingUnits.value = false;

    final b = results[0];
    if (b.isCompleted && b.data != null) brands.assignAll(b.data!);
    final c = results[1];
    if (c.isCompleted && c.data != null) {
      categories.assignAll(c.data!.expand((o) => o.flattened).toList());
    }
    final t = results[2];
    if (t.isCompleted && t.data != null) tags.assignAll(t.data!);
    final u = results[3];
    if (u.isCompleted && u.data != null) units.assignAll(u.data!);
    if (productType.value == ProductType.variation) {
      await loadVariationTypes();
    }
  }

  Future<void> loadVariationTypes() async {
    final branchId = selectedBranchId.value;
    if (branchId == null ||
        isLoadingVariationTypes.value ||
        variationTypes.isNotEmpty) {
      return;
    }
    isLoadingVariationTypes.value = true;
    final response = await _formRepo.getVariationTypes(branchId);
    isLoadingVariationTypes.value = false;
    if (response.isCompleted && response.data != null) {
      variationTypes.assignAll(response.data!);
    }
  }

  // ── Single-select setters ───────────────────────────────────────────────

  void selectBrand(int id) {
    selectedBrandId.value = id;
    brandLabel.value =
        brands.firstWhereOrNull((b) => b.value == id)?.label ?? '';
  }

  void selectUnit(int id) {
    selectedUnitId.value = id;
    unitLabel.value = units.firstWhereOrNull((u) => u.value == id)?.label ?? '';
  }

  void setStatus(String value) => status.value = value;

  Future<void> setProductType(String value) async {
    if (productType.value == value) return;
    productType.value = value;
    if (value == ProductType.variation) {
      await loadVariationTypes();
    }
  }

  // ── Images ──────────────────────────────────────────────────────────────

  void onImagesConfirmed(List<MediaItem> items) {
    final known = pickedImages.map((m) => m.mediaId).toSet();
    for (final item in items) {
      if (!known.contains(item.mediaId)) {
        pickedImages.add(item);
        known.add(item.mediaId);
      }
    }
  }

  void removePickedImage(MediaItem item) {
    pickedImages.removeWhere((m) => m.mediaId == item.mediaId);
  }

  void removeKeptMedia(ProductMedia media) {
    keptMedia.removeWhere((m) => m.id == media.id);
  }

  // ── Variation sets ──────────────────────────────────────────────────────

  void addSet() {
    sets.add(VariationSetDraft());
  }

  void removeSet(int index) {
    if (index < 0 || index >= sets.length) return;
    sets.removeAt(index);
    rebuildCombinations();
  }

  Future<void> selectSetType(VariationSetDraft set, int typeId) async {
    if (set.typeId.value == typeId && set.values.isNotEmpty) return;
    set.typeId.value = typeId;
    set.typeLabel.value =
        variationTypes.firstWhereOrNull((t) => t.value == typeId)?.label ?? '';
    set.selectedValueIds.clear();
    await loadSetValues(set, force: true);
    rebuildCombinations();
  }

  /// Loads selectable values for a set's type (cached probe + runtime data).
  Future<void> loadSetValues(
    VariationSetDraft set, {
    bool force = false,
  }) async {
    final typeId = set.typeId.value;
    if (typeId == null) {
      set.values.clear();
      return;
    }
    if (!force && _valuesCache.containsKey(typeId)) {
      set.values.assignAll(_valuesCache[typeId]!);
      return;
    }
    set.isLoadingValues.value = true;
    final values = await _formRepo.getVariationValues(typeId);
    set.isLoadingValues.value = false;
    _valuesCache[typeId] = values;
    // Drop selections that no longer exist for this type.
    final valid = values.map((v) => v.id).whereType<int>().toSet();
    set.selectedValueIds.retainAll(valid);
    set.values.assignAll(values);
  }

  void toggleSetValue(VariationSetDraft set, int valueId) {
    if (set.selectedValueIds.contains(valueId)) {
      set.selectedValueIds.remove(valueId);
    } else {
      set.selectedValueIds.add(valueId);
    }
    rebuildCombinations();
  }

  /// Cartesian product of the sets → combination rows. Existing rows are
  /// matched by name so typed prices/stock survive regeneration.
  void rebuildCombinations() {
    if (_suspendComboRebuild) return;
    final usable = sets
        .where((s) => s.typeId.value != null && s.selectedValueIds.isNotEmpty)
        .toList();
    if (usable.isEmpty) {
      _disposeCombinations();
      return;
    }
    // Deterministic value order: options order filtered by selection
    // (same order _buildFields uses for variationSets values).
    final pools = usable.map((s) {
      return s.values
          .where((v) => v.id != null && s.selectedValueIds.contains(v.id))
          .toList();
    }).toList();
    if (pools.any((p) => p.isEmpty)) {
      _disposeCombinations();
      return;
    }
    final names = _cartesianNames(pools);
    final previous = {for (final c in combinations) c.name.value: c};
    final next = <CombinationDraft>[];
    for (final name in names) {
      next.add(previous[name] ?? CombinationDraft(name: name));
    }
    for (final entry in previous.entries) {
      if (!names.contains(entry.key)) entry.value.dispose();
    }
    combinations.assignAll(next);
  }

  List<String> _cartesianNames(List<List<VariationValue>> pools) {
    var acc = <String>[''];
    for (final pool in pools) {
      final out = <String>[];
      for (final prefix in acc) {
        for (final v in pool) {
          final name = v.name ?? '';
          if (name.isEmpty) continue;
          out.add(prefix.isEmpty ? name : '$prefix-$name');
        }
      }
      acc = out;
    }
    return acc;
  }

  void _disposeCombinations() {
    for (final c in combinations) {
      c.dispose();
    }
    combinations.clear();
  }

  // ── Runtime creation (dropdown items added on the fly) ──────────────────

  Future<bool> createBrand(String name, {int? logoMediaId}) async {
    final branchId = selectedBranchId.value;
    if (branchId == null || name.trim().isEmpty) return false;
    isLoading.value = true;
    final response = await _formRepo.createBrand(
      branchId: branchId,
      name: name.trim(),
      mediaId: logoMediaId,
    );
    isLoading.value = false;
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return false;
    }
    final created = response.data!;
    if (!brands.any((b) => b.value == created.value)) {
      brands.insert(0, created);
    }
    selectBrand(created.value);
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: response.message ?? 'addProduct.messages.successSaved'.trns(),
    );
    return true;
  }

  Future<bool> createCategory(
    String name, {
    int? parentId,
    int? mediaId,
  }) async {
    final branchId = selectedBranchId.value ?? _auth.currentUser.value?.branchId;
    if (branchId == null || name.trim().isEmpty) return false;
    isLoading.value = true;
    final response = await _formRepo.createCategory(
      branchId: branchId,
      name: name.trim(),
      parentId: parentId,
      mediaId: mediaId,
    );
    isLoading.value = false;
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return false;
    }
    final created = response.data!;
    // Reload so the tree (and the new child under its parent) is correct,
    // then select the freshly created category.
    final reload = await _formRepo.getCategories(branchId);
    if (reload.isCompleted && reload.data != null) {
      categories.assignAll(reload.data!.expand((o) => o.flattened).toList());
    } else if (!categories.any((c) => c.value == created.value)) {
      categories.insert(0, created);
    }
    selectedCategoryIds.add(created.value);
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: response.message ?? 'addProduct.messages.successSaved'.trns(),
    );
    return true;
  }

  Future<bool> createTag(String name) async {
    final branchId = selectedBranchId.value ?? _auth.currentUser.value?.branchId;
    if (branchId == null || name.trim().isEmpty) return false;
    isLoading.value = true;
    final response = await _formRepo.createTag(
      branchId: branchId,
      name: name.trim(),
    );
    isLoading.value = false;
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return false;
    }
    final created = response.data!;
    if (!tags.any((t) => t.value == created.value)) {
      tags.insert(0, created);
    }
    selectedTagIds.add(created.value);
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: response.message ?? 'addProduct.messages.successSaved'.trns(),
    );
    return true;
  }

  Future<bool> createUnit(String name) async {
    final branchId = selectedBranchId.value ?? _auth.currentUser.value?.branchId;
    if (branchId == null || name.trim().isEmpty) return false;
    isLoading.value = true;
    final response = await _formRepo.createUnit(
      branchId: branchId,
      name: name.trim(),
    );
    isLoading.value = false;
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return false;
    }
    final created = response.data!;
    if (!units.any((u) => u.value == created.value)) {
      units.insert(0, created);
    }
    selectUnit(created.value);
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: response.message ?? 'addProduct.messages.successSaved'.trns(),
    );
    return true;
  }

  /// Creates a variation type (with its values) and auto-selects it as a
  /// new set with all returned values selected.
  Future<bool> createVariationType(String name, List<String> valueNames) async {
    final branchId = selectedBranchId.value ?? _auth.currentUser.value?.branchId;
    if (branchId == null || name.trim().isEmpty) return false;
    final clean = valueNames
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    if (clean.isEmpty) return false;
    isLoading.value = true;
    final response = await _formRepo.createVariationType(
      branchId: branchId,
      name: name.trim(),
      valueNames: clean,
    );
    isLoading.value = false;
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return false;
    }
    final created = response.data!;
    if (!variationTypes.any((t) => t.value == created.id)) {
      variationTypes.insert(
        0,
        ProductLookup(label: created.name, value: created.id),
      );
    }
    _valuesCache[created.id] = created.values
        .where((v) => v.id != null)
        .toList();
    final set = VariationSetDraft()
      ..typeId.value = created.id
      ..typeLabel.value = created.name
      ..values.assignAll(_valuesCache[created.id]!)
      ..selectedValueIds.addAll(
        _valuesCache[created.id]!.map((v) => v.id!).toSet(),
      );
    sets.add(set);
    rebuildCombinations();
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: response.message ?? 'addProduct.messages.successSaved'.trns(),
    );
    return true;
  }

  // ── Edit prefill (everything comes from the details API) ────────────────

  Future<void> _prefillFromDetails() async {
    final id = editingId;
    if (id == null) return;
    isPrefilling.value = true;
    final response = await _productRepo.getProduct(id);
    isPrefilling.value = false;
    final product = response.data;
    if (!response.isCompleted || product == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'productDetails.errors.fetchFailed'.trns(),
      );
      return;
    }

    _suspendComboRebuild = true;
    nameCtrl.text = product.name ?? '';
    shortDescCtrl.text = product.shortDescription ?? '';
    descCtrl.text = product.plainDescription;
    status.value = (product.status ?? 'active').toLowerCase();
    productType.value =
        (product.productType ?? '').toLowerCase().contains('variation')
        ? ProductType.variation
        : ProductType.simple;

    keptMedia.assignAll(product.media.where((m) => m.id != null).toList());

    // Branch first, then dependents, then id-based selections.
    final branchId = product.branchId;
    if (branchId != null) {
      selectedBranchId.value = branchId;
      branchLabel.value = product.branchName;
      await loadDependents();
    }

    if (product.brandId != null) selectBrand(product.brandId!);
    if (product.unitId != null) selectUnit(product.unitId!);
    selectedCategoryIds.addAll(
      product.categoryIds.where((id) => categories.any((c) => c.value == id)),
    );
    selectedTagIds.addAll(
      product.tagIds.where((id) => tags.any((t) => t.value == id)),
    );

    if (isSimple) {
      priceCtrl.text = product.price ?? '';
      stockCtrl.text = '${product.stock ?? ''}';
      skuCtrl.text = product.sku ?? '';
      codeCtrl.text = product.code ?? '';
    } else {
      // Combinations always come straight from the variants (names match
      // the generated "<v1>-<v2>" pattern, so later regenerations keep
      // the prefilled prices).
      for (final variant in product.variants) {
        final name = variant.variationValues
            .map((v) => v.name ?? '')
            .where((n) => n.isNotEmpty)
            .join('-');
        if (name.isEmpty) continue;
        combinations.add(
          CombinationDraft(
            name: name,
            price: variant.price ?? '',
            stock: '${variant.stock ?? ''}',
            sku: variant.sku ?? '',
            code: variant.code ?? '',
          ),
        );
      }
      await _reconstructSets(product);
    }
    _suspendComboRebuild = false;
  }

  /// Rebuilds variation sets from the product's variants by resolving
  /// each value id to its type (cached probe). All-or-nothing: sets are
  /// only assigned when every value maps cleanly, otherwise they stay
  /// empty while the prefilled combinations above still carry the data.
  Future<void> _reconstructSets(ProductModel product) async {
    final valueToType = <int, int>{};
    for (final type in variationTypes) {
      var values = _valuesCache[type.value];
      values ??= await _formRepo.getVariationValues(type.value);
      _valuesCache[type.value] = values;
      for (final v in values) {
        if (v.id != null) valueToType.putIfAbsent(v.id!, () => type.value);
      }
    }
    final orderedTypes = <int>[];
    final valuesByType = <int, LinkedHashSet<int>>{};
    for (final variant in product.variants) {
      for (final value in variant.variationValues) {
        final valueId = value.id;
        if (valueId == null) continue;
        final typeId = valueToType[valueId];
        if (typeId == null) return; // unmapped → leave sets empty
        if (!orderedTypes.contains(typeId)) orderedTypes.add(typeId);
        (valuesByType[typeId] ??= LinkedHashSet<int>()).add(valueId);
      }
    }
    final built = <VariationSetDraft>[];
    for (final typeId in orderedTypes) {
      final type = variationTypes.firstWhereOrNull((t) => t.value == typeId);
      if (type == null) return; // unknown type → leave sets empty
      built.add(
        VariationSetDraft()
          ..typeId.value = typeId
          ..typeLabel.value = type.label
          ..values.assignAll(_valuesCache[typeId] ?? const [])
          ..selectedValueIds.addAll(valuesByType[typeId] ?? const {}),
      );
    }
    sets.assignAll(built);
  }

  // ── Validation + submit ─────────────────────────────────────────────────

  String? _validate() {
    if (selectedBranchId.value == null) {
      return 'addProduct.validation.branchRequired'.trns();
    }
    if (nameCtrl.text.trim().isEmpty) {
      return 'addProduct.validation.nameRequired'.trns();
    }
    if (selectedBrandId.value == null) {
      return 'addProduct.validation.brandRequired'.trns();
    }
    if (selectedCategoryIds.isEmpty) {
      return 'addProduct.validation.categoryRequired'.trns();
    }
    if (selectedTagIds.isEmpty) {
      return 'addProduct.validation.tagRequired'.trns();
    }
    if (selectedUnitId.value == null) {
      return 'addProduct.validation.unitRequired'.trns();
    }
    if (isSimple) {
      if (priceCtrl.text.trim().isEmpty ||
          double.tryParse(priceCtrl.text.trim()) == null) {
        return 'addProduct.validation.priceRequired'.trns();
      }
      if (stockCtrl.text.trim().isEmpty ||
          int.tryParse(stockCtrl.text.trim()) == null) {
        return 'addProduct.validation.stockRequired'.trns();
      }
      return null;
    }
    // Variation product.
    final usable = sets
        .where((s) => s.typeId.value != null && s.selectedValueIds.isNotEmpty)
        .toList();
    if (usable.isEmpty) {
      return 'addProduct.validation.setsRequired'.trns();
    }
    if (combinations.isEmpty) {
      return 'addProduct.validation.combinationsRequired'.trns();
    }
    for (final c in combinations) {
      if (c.priceCtrl.text.trim().isEmpty ||
          double.tryParse(c.priceCtrl.text.trim()) == null ||
          c.stockCtrl.text.trim().isEmpty ||
          int.tryParse(c.stockCtrl.text.trim()) == null) {
        return 'addProduct.validation.combinationFieldsRequired'.trns();
      }
    }
    return null;
  }

  Map<String, dynamic> _buildFields() {
    final fields = <String, dynamic>{
      'branch_id': selectedBranchId.value ?? _auth.currentUser.value?.branchId,
      'name': nameCtrl.text.trim(),
      'short_description': shortDescCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'brand_id': selectedBrandId.value,
      'unit_id': selectedUnitId.value,
      'status': status.value,
      'variation': productType.value,
    };
    final categoryIds = selectedCategoryIds.toList();
    for (var i = 0; i < categoryIds.length; i++) {
      fields['categories[$i][value]'] = categoryIds[i];
    }
    final tagIds = selectedTagIds.toList();
    for (var i = 0; i < tagIds.length; i++) {
      fields['tags[$i][value]'] = tagIds[i];
    }
    final imageIds = submitImageIds;
    for (var i = 0; i < imageIds.length; i++) {
      fields['images[$i]'] = imageIds[i];
    }
    if (isSimple) {
      fields['price'] = priceCtrl.text.trim();
      fields['stock'] = stockCtrl.text.trim();
      if (skuCtrl.text.trim().isNotEmpty) {
        fields['sku'] = skuCtrl.text.trim();
      }
      if (codeCtrl.text.trim().isNotEmpty) {
        fields['code'] = codeCtrl.text.trim();
      }
    } else {
      final usable = sets
          .where((s) => s.typeId.value != null && s.selectedValueIds.isNotEmpty)
          .toList();
      for (var i = 0; i < usable.length; i++) {
        fields['variationSets[$i][type]'] = usable[i].typeId.value;
        // Same deterministic options order as rebuildCombinations, so
        // set values and generated combination names always agree.
        final valueIds = usable[i].values
            .where(
              (v) => v.id != null && usable[i].selectedValueIds.contains(v.id),
            )
            .map((v) => v.id!)
            .toList();
        for (var j = 0; j < valueIds.length; j++) {
          fields['variationSets[$i][values][$j][value]'] = valueIds[j];
        }
      }
      for (var i = 0; i < combinations.length; i++) {
        final c = combinations[i];
        fields['combinations[$i][name]'] = c.name.value;
        fields['combinations[$i][price]'] = c.priceCtrl.text.trim();
        fields['combinations[$i][stock]'] = c.stockCtrl.text.trim();
        if (c.skuCtrl.text.trim().isNotEmpty) {
          fields['combinations[$i][sku]'] = c.skuCtrl.text.trim();
        }
        if (c.codeCtrl.text.trim().isNotEmpty) {
          fields['combinations[$i][code]'] = c.codeCtrl.text.trim();
        }
      }
    }
    return fields;
  }

  Future<void> save(BuildContext context) async {
    final error = _validate();
    if (error != null) {
      SnackbarService.showError(title: 'common.error'.trns(), message: error);
      return;
    }
    isLoading.value = true;
    final response = isEditMode
        ? await _formRepo.updateProduct(id: editingId!, fields: _buildFields())
        : await _formRepo.createProduct(_buildFields());
    isLoading.value = false;

    if (!response.isCompleted) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'addProduct.errors.saveFailed'.trns(),
      );
      return;
    }
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message:
          response.message ??
          (isEditMode
              ? 'addProduct.messages.updated'.trns()
              : 'addProduct.messages.successSaved'.trns()),
    );
    if (!context.mounted) return;
    await NavigationHelper.safePop(context, true);
  }
}
