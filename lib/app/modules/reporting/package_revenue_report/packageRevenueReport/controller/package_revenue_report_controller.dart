import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_report_model.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/repo/package_revenue_report_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageRevenueColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  PackageRevenueColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });
}

class PackageRevenueReportController extends GetxController {
  final PackageRevenueReportRepository _repository =
      PackageRevenueReportRepository();
  final AuthService _authService = Get.find<AuthService>();

  // ── Loading & states ──────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // ── API Response ──────────────────────────────────────────────────────
  final Rx<PackageRevenueReportModel?> reportData =
      Rx<PackageRevenueReportModel?>(null);

  // ── Filter state ──────────────────────────────────────────────────────
  final Rx<DateTime> fromDate =
      DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxInt selectedBranchId = 0.obs;
  final RxString selectedBranchLabel = ''.obs;
  final Rx<dynamic> selectedPackageId = 'all'.obs;
  final RxString selectedPackageLabel = ''.obs;

  // Temp filters
  final Rx<DateTime> tempFromDate =
      DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxInt tempBranchId = 0.obs;
  final RxString tempBranchLabel = ''.obs;
  final Rx<dynamic> tempPackageId = 'all'.obs;
  final RxString tempPackageLabel = ''.obs;

  // ── Dropdown Options ──────────────────────────────────────────────────
  final RxList<BranchFilterOption> branches = <BranchFilterOption>[].obs;
  final RxList<PackageFilterOption> packages = <PackageFilterOption>[].obs;

  // ── Column selector ───────────────────────────────────────────────────
  final RxList<PackageRevenueColumn> allColumns = <PackageRevenueColumn>[
    PackageRevenueColumn(
        key: 'branch_name',
        labelKey: 'packageRevenue.table.branch',
        width: 130,
        isSelected: true),
    PackageRevenueColumn(
        key: 'from',
        labelKey: 'packageRevenue.table.from',
        width: 120,
        isSelected: true),
    PackageRevenueColumn(
        key: 'to',
        labelKey: 'packageRevenue.table.to',
        width: 120,
        isSelected: true),
    PackageRevenueColumn(
        key: 'total_amount',
        labelKey: 'packageRevenue.table.totalAmount',
        width: 140,
        isSelected: true),
    PackageRevenueColumn(
        key: 'total_discount',
        labelKey: 'packageRevenue.table.totalDiscount',
        width: 150,
        isSelected: true),
    PackageRevenueColumn(
        key: 'net_revenue',
        labelKey: 'packageRevenue.table.netRevenue',
        width: 140,
        isSelected: true),
  ].obs;

  late RxList<bool> tempColumnSelected;

  // ── Computed ──────────────────────────────────────────────────────────
  List<MonthlyPackageData> get monthlyData =>
      reportData.value?.monthlyData ?? [];

  List<PackageRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  String get dateRangeLabel =>
      '${_formatDisplay(fromDate.value)} - ${_formatDisplay(toDate.value)}';

  bool get showBranchFilter => _authService.isOwner;

  bool get isEmpty => !isLoading.value && monthlyData.isEmpty;

  int? get userBranchId => _authService.currentUser.value?.branchId;

  String _formatDisplay(DateTime d) => DateFormat('MMM/dd/yyyy').format(d);

  String _formatApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    selectedBranchLabel.value = 'packageRevenue.filter.allBranches'.trns();
    selectedPackageLabel.value = 'packageRevenue.filter.allPackages'.trns();
    tempBranchLabel.value = selectedBranchLabel.value;
    tempPackageLabel.value = selectedPackageLabel.value;
    fetchReport();
  }

  // ── API Calls ─────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      int? branchParam;
      if (showBranchFilter) {
        branchParam = selectedBranchId.value > 0 ? selectedBranchId.value : null;
      } else {
        branchParam = userBranchId;
      }

      final response = await _repository.getPackageRevenueReport(
        fromDate: _formatApi(fromDate.value),
        toDate: _formatApi(toDate.value),
        branchId: branchParam,
        packageId: selectedPackageId.value,
      );

      if (response.isCompleted && response.data != null) {
        reportData.value = response.data;
        branches.value = response.data!.branches;
        packages.value = response.data!.packages;
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

  Future<void> refreshReport() async {
    isRefreshing.value = true;
    await fetchReport();
    isRefreshing.value = false;
  }

  // ── Filter Actions ────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempBranchId.value = selectedBranchId.value;
    tempBranchLabel.value = selectedBranchLabel.value;
    tempPackageId.value = selectedPackageId.value;
    tempPackageLabel.value = selectedPackageLabel.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedBranchLabel.value = tempBranchLabel.value;
    selectedPackageId.value = tempPackageId.value;
    selectedPackageLabel.value = tempPackageLabel.value;
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchId.value = 0;
    tempBranchLabel.value = 'packageRevenue.filter.allBranches'.trns();
    tempPackageId.value = 'all';
    tempPackageLabel.value = 'packageRevenue.filter.allPackages'.trns();
  }

  // ── Column Actions ────────────────────────────────────────────────────
  void initTempColumns() {
    tempColumnSelected = allColumns.map((c) => c.isSelected).toList().obs;
  }

  void applyColumnSelection() {
    for (int i = 0; i < allColumns.length; i++) {
      allColumns[i].isSelected = tempColumnSelected[i];
    }
    allColumns.refresh();
  }

  void resetColumnSelection() {
    for (int i = 0; i < tempColumnSelected.length; i++) {
      tempColumnSelected[i] = true;
    }
    tempColumnSelected.refresh();
  }

  void selectAllColumns() {
    for (int i = 0; i < tempColumnSelected.length; i++) {
      tempColumnSelected[i] = true;
    }
    tempColumnSelected.refresh();
  }

  void toggleTempColumn(int index) {
    tempColumnSelected[index] = !tempColumnSelected[index];
    tempColumnSelected.refresh();
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String getCellValue(MonthlyPackageData row, String key) {
    switch (key) {
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDisplayFromString(row.from);
      case 'to':
        return _formatDisplayFromString(row.to);
      case 'total_amount':
        return '\$${row.totalAmount.toStringAsFixed(2)}';
      case 'total_discount':
        return '\$${row.totalDiscount.toStringAsFixed(2)}';
      case 'net_revenue':
        return '\$${row.netRevenue.toStringAsFixed(2)}';
      default:
        return '-';
    }
  }

  String _formatDisplayFromString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM/dd/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────
  void navigateToDetails(MonthlyPackageData data) {
    Get.toNamed(
      Routes.PACKAGE_REVENUE_DETAILS,
      arguments: {
        'branch_id': data.branchId,
        'from_date': data.from,
        'to_date': data.to,
        'package_id': data.packageId,
      },
    );
  }
}