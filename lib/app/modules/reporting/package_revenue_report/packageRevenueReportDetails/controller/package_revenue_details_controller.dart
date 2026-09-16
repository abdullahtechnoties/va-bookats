import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_details_model.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/repo/package_revenue_report_repository.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageRevenueDetailsController extends GetxController {
  final PackageRevenueReportRepository _repository =
      PackageRevenueReportRepository();

  // ── Arguments ─────────────────────────────────────────────────────────
  late final int branchId;
  late final String fromDate;
  late final String toDate;
  late final dynamic packageId;

  // ── Loading & states ──────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // ── API Response ──────────────────────────────────────────────────────
  final Rx<PackageRevenueDetailsModel?> detailsData =
      Rx<PackageRevenueDetailsModel?>(null);

  // ── Pagination ────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;

  // ── Computed ──────────────────────────────────────────────────────────
  BranchInfoModel? get branch => detailsData.value?.branch;
  String get packageName =>
      detailsData.value?.packageName ?? 'packageRevenue.filter.allPackages'.trns();
  List<DailyPackageSummary> get dailySummaries =>
      detailsData.value?.dailyPackageSummaries.items ?? [];

  bool get isEmpty => !isLoading.value && dailySummaries.isEmpty;

  int get totalPages =>
      detailsData.value?.dailyPackageSummaries.meta.lastPage ?? 1;
  bool get hasNextPage =>
      detailsData.value?.dailyPackageSummaries.meta.hasNextPage ?? false;

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchDetails();
  }

  void _extractArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      Get.back();
      return;
    }

    branchId = args['branch_id'] as int;
    fromDate = args['from_date'] as String;
    toDate = args['to_date'] as String;
    packageId = args['package_id'];
  }

  // ── API Calls ─────────────────────────────────────────────────────────
  Future<void> fetchDetails({int page = 1}) async {
    try {
      if (page == 1) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await _repository.getPackageRevenueDetails(
        branchId: branchId,
        fromDate: fromDate,
        toDate: toDate,
        packageId: packageId,
        page: page,
      );

      if (response.isCompleted && response.data != null) {
        detailsData.value = response.data;
        currentPage.value = page;
      } else {
        errorMessage.value =
            response.message ?? 'errors.failedToFetch'.trns();
        SnackbarService.showError(
          title: 'errors.errorTitle'.trns(),
          message: errorMessage.value,
        );
      }
    } catch (e) {
      errorMessage.value = 'errors.unexpected'.trns();
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDetails() async {
    isRefreshing.value = true;
    await fetchDetails(page: 1);
    isRefreshing.value = false;
  }

  // ── Pagination ────────────────────────────────────────────────────────
  void nextPage() {
    if (currentPage.value < totalPages) {
      fetchDetails(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      fetchDetails(page: currentPage.value - 1);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM/dd/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String formatCurrency(String amount) {
    try {
      final num = double.tryParse(amount) ?? 0;
      return '\$${num.toStringAsFixed(2)}';
    } catch (e) {
      return amount;
    }
  }
}