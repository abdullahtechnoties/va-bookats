// lib/app/modules/productDetail/controllers/product_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/products/repositories/product_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ProductDetailController extends GetxController {
  final ProductRepository _repository = ProductRepository();

  // ── Arguments ───────────────────────────────────────────────────────────
  late final int productId;

  // ── State ───────────────────────────────────────────────────────────────
  final Rx<ApiResponse<ProductModel>> detailResponse =
      ApiResponse<ProductModel>.loading().obs;

  ProductModel? get product => detailResponse.value.data;
  bool get isLoading => detailResponse.value.isLoading;
  bool get hasError => detailResponse.value.isError;
  bool get hasData => product != null && product!.id != null;

  final RxnInt busyStatus = RxnInt();
  final RxnInt busyDelete = RxnInt();

  // Gallery pager.
  final RxInt galleryIndex = 0.obs;
  final PageController galleryController = PageController();

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchDetails();
  }

  @override
  void onClose() {
    galleryController.dispose();
    super.onClose();
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args is int) {
      productId = args;
    } else if (args is Map) {
      productId = int.tryParse(args['id']?.toString() ?? '0') ?? 0;
    } else {
      productId = 0;
    }
  }

  // ── API ─────────────────────────────────────────────────────────────────
  Future<void> fetchDetails() async {
    detailResponse.value = ApiResponse.loading();
    final response = await _repository.getProduct(productId);
    detailResponse.value = response;
    if (response.isError) {
      SnackbarService.showError(
        title: 'productDetails.errors.title'.trns(),
        message: response.message ??
            'productDetails.errors.fetchFailed'.trns(),
      );
    } else {
      galleryIndex.value = 0;
      if (galleryController.hasClients) {
        galleryController.jumpToPage(0);
      }
    }
  }

  Future<void> refreshDetails() async => fetchDetails();

  // ── Mutations ───────────────────────────────────────────────────────────

  Future<void> changeStatus() async {
    final current = product;
    if (current?.id == null || busyStatus.value != null) return;
    final newStatus = current!.isActive ? 'inactive' : 'active';

    final confirmed = await _confirmStatusChange(newStatus);
    if (confirmed != true) return;

    busyStatus.value = current.id;
    final response = await _repository.changeProductStatus(
      id: current.id!,
      status: newStatus,
    );
    busyStatus.value = null;

    if (response.isCompleted) {
      await fetchDetails();
      SnackbarService.showSuccess(
        title: 'products.statusSuccessTitle'.trns(),
        message:
            response.message ?? 'products.statusSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'products.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> deleteProduct() async {
    final current = product;
    if (current?.id == null || busyDelete.value != null) return;

    final confirmed = await _confirmDelete();
    if (confirmed != true) return;

    busyDelete.value = current!.id;
    final response = await _repository.deleteProduct(current.id!);
    busyDelete.value = null;

    if (response.isCompleted) {
      SnackbarService.showSuccess(
        title: 'products.deleteSuccessTitle'.trns(),
        message:
            response.message ?? 'products.deleteSuccessMessage'.trns(),
      );
      Get.back(result: true);
    } else {
      SnackbarService.showError(
        title: 'products.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  void openEdit() {
    final current = product;
    if (current == null) return;
    Get.toNamed(Routes.ADD_PRODUCT, arguments: current)?.then((_) {
      fetchDetails();
    });
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────

  Future<bool?> _confirmDelete() {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text('products.deleteDialogTitle'.trns()),
        content: Text(
          'products.deleteDialogMessage'.trnsFormat({
            'name': product?.name ?? '',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('products.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'products.delete'.trns(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<bool?> _confirmStatusChange(String newStatus) {
    final active = newStatus == 'active';
    return Get.dialog<bool>(
      AlertDialog(
        title: Text('products.changeStatusTitle'.trns()),
        content: Text(
          active
              ? 'products.statusConfirm.active'.trns()
              : 'products.statusConfirm.inactive'.trns(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('products.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'products.confirm'.trns(),
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
