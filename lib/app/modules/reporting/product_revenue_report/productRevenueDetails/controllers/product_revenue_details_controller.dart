import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/controllers/product_revenue_repo.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/models/product_revenue_models.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ProductRevenueDetailsController extends GetxController {
  final ProductRevenueRepository _repository = ProductRevenueRepository();

  // ── Parameters from route ──────────────────────────────────────────────
  late final int branchId;
  late final String fromDate;
  late final String toDate;
  late final String productId;

  // ── State ──────────────────────────────────────────────────────────────
  final Rx<ApiResponse<ProductRevenueDetails>> detailsResponse =
      ApiResponse<ProductRevenueDetails>.loading().obs;

  ProductRevenueDetails? get details => detailsResponse.value.data;
  bool get isLoading => detailsResponse.value.isLoading;
  bool get hasError => detailsResponse.value.isError;
  bool get hasData => details != null && details!.dailyProductSummaries.items.isNotEmpty;

  // ── Pagination ─────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  
  int get totalPages => details?.dailyProductSummaries.meta.lastPage ?? 1;
  bool get hasNextPage => details?.dailyProductSummaries.meta.hasNextPage ?? false;
  bool get hasPrevPage => currentPage.value > 1;

  List<DailyProductSummary> get items => details?.dailyProductSummaries.items ?? [];

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _extractParameters();
    fetchDetails();
  }

  void _extractParameters() {
    final params = Get.parameters;
    branchId = int.tryParse(params['branch_id'] ?? '0') ?? 0;
    fromDate = params['from_date'] ?? '';
    toDate = params['to_date'] ?? '';
    productId = params['product_id'] ?? 'all';
  }

  // ── API Calls ──────────────────────────────────────────────────────────
  Future<void> fetchDetails({bool showLoading = true}) async {
    if (showLoading) {
      detailsResponse.value = ApiResponse.loading();
    }

    final response = await _repository.getProductRevenueDetails(
      branchId: branchId,
      fromDate: fromDate,
      toDate: toDate,
      productId: productId,
      page: currentPage.value,
    );

    detailsResponse.value = response;

    if (response.isError) {
      SnackbarService.showError(
        title: 'reports.product.errors.title'.trns(),
        message: response.message ?? 'reports.product.errors.detailsFetchFailed'.trns(),
      );
    }
  }

  Future<void> refreshDetails() async {
    currentPage.value = 1;
    await fetchDetails(showLoading: false);
  }

  // ── Pagination Actions ─────────────────────────────────────────────────
  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchDetails();
    }
  }

  void prevPage() {
    if (hasPrevPage) {
      currentPage.value--;
      fetchDetails();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month]}/${date.day}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}