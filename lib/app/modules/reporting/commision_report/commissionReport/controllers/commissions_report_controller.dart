import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/models/commissions_report_model.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class CommissionsReportController extends GetxController {
  final NetworkService _network = Get.find();
  final AuthService _auth = Get.find();

  // ── API Response ──────────────────────────────────────────────────────────
  final Rx<ApiResponse<CommissionsReportResponse>> apiResponse =
      ApiResponse<CommissionsReportResponse>.loading().obs;

  // ── Filters ───────────────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxnString selectedBranchId = RxnString(null);
  final RxnString selectedStaffId = RxnString(null);

  // Temp filters (inside bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxnString tempBranchId = RxnString(null);
  final RxnString tempStaffId = RxnString(null);

  // ── Columns ───────────────────────────────────────────────────────────────
  final RxList<CommissionsColumn> allColumns = <CommissionsColumn>[
    CommissionsColumn(key: 'branchName', labelKey: 'commissions.table.branch', width: 140, isSelected: true),
    CommissionsColumn(key: 'from', labelKey: 'commissions.table.from', width: 110, isSelected: true),
    CommissionsColumn(key: 'to', labelKey: 'commissions.table.to', width: 110, isSelected: true),
    CommissionsColumn(key: 'totalServices', labelKey: 'commissions.table.totalServices', width: 130, isSelected: true),
    CommissionsColumn(key: 'totalPackages', labelKey: 'commissions.table.totalPackages', width: 130, isSelected: true),
    CommissionsColumn(key: 'serviceCommission', labelKey: 'commissions.table.serviceCommission', width: 150, isSelected: true),
    CommissionsColumn(key: 'packageCommission', labelKey: 'commissions.table.packageCommission', width: 150, isSelected: true),
    CommissionsColumn(key: 'totalCommission', labelKey: 'commissions.table.totalCommission', width: 150, isSelected: true),
  ].obs;

  late RxList<bool> tempColumnSelected;

  // ── Computed ──────────────────────────────────────────────────────────────
  List<CommissionsColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  bool get isOwner => _auth.isOwner;

  int? get userBranchId => _auth.currentUser.value?.branchId;

  List<DropdownOption> get branches =>
      apiResponse.value.data?.branches ?? [];

  List<DropdownOption> get staffs =>
      apiResponse.value.data?.staffs ?? [];

  List<CommissionMonthlyData> get monthlyData =>
      apiResponse.value.data?.monthlyData ?? [];

  String get dateRangeLabel {
    final fmt = DateFormat('MMM/d/yyyy');
    return '${fmt.format(fromDate.value)} - ${fmt.format(toDate.value)}';
  }

  String? get selectedBranchLabel {
    if (selectedBranchId.value == null) return null;
    return branches
        .firstWhereOrNull((b) => b.value.toString() == selectedBranchId.value)
        ?.label;
  }

  String? get selectedStaffLabel {
    if (selectedStaffId.value == null) return null;
    return staffs
        .firstWhereOrNull((s) => s.value.toString() == selectedStaffId.value)
        ?.label;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initFilters();
    fetchReport();
  }

  void _initFilters() {
    if (!isOwner && userBranchId != null) {
      selectedBranchId.value = userBranchId.toString();
      tempBranchId.value = userBranchId.toString();
    }
  }

  // ── API ───────────────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    apiResponse.value = ApiResponse.loading();

    final params = <String, dynamic>{
      'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value),
      'to_date': DateFormat('yyyy-MM-dd').format(toDate.value),
    };

    if (isOwner && selectedBranchId.value != null) {
      params['branch_id'] = selectedBranchId.value;
    } else if (!isOwner && userBranchId != null) {
      params['branch_id'] = userBranchId;
    }

    if (selectedStaffId.value != null && selectedStaffId.value != 'all') {
      params['staff_id'] = selectedStaffId.value;
    }

    final response = await _network.get(
      endpoint: ApiPath.commissionsReport,
      queryParams: params,
    );

    if (response.isCompleted && response.data != null) {
      try {
        final data = CommissionsReportResponse.fromJson(response.data!);
        apiResponse.value = ApiResponse.completed(data);
      } catch (e) {
        apiResponse.value = ApiResponse.error('commissions.errors.parseFailed'.trns());
      }
    } else {
      apiResponse.value = ApiResponse.error(
        response.message ?? 'commissions.errors.fetchFailed'.trns(),
      );
    }
  }

  // ── Filter Actions ────────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempBranchId.value = selectedBranchId.value;
    tempStaffId.value = selectedStaffId.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedStaffId.value = tempStaffId.value;
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchId.value = isOwner ? null : userBranchId?.toString();
    tempStaffId.value = null;
  }

  // ── Column Selection ──────────────────────────────────────────────────────
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

  // ── Cell Value ────────────────────────────────────────────────────────────
  String getCellValue(CommissionMonthlyData row, String key) {
    switch (key) {
      case 'branchName':
        return row.branchName;
      case 'from':
        return _formatDate(row.from);
      case 'to':
        return _formatDate(row.to);
      case 'totalServices':
        return row.totalServices.toString();
      case 'totalPackages':
        return row.totalPackages.toString();
      case 'serviceCommission':
        return '\$${row.serviceCommission}';
      case 'packageCommission':
        return '\$${row.packageCommission}';
      case 'totalCommission':
        return '\$${row.totalCommission}';
      default:
        return '-';
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('MMM/d/yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void viewDetails(CommissionMonthlyData row) {
    Get.toNamed(
      Routes.COMMISSIONS_DETAIL,
      parameters: {
        'branch_id': row.branchId.toString(),
        'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value),
        'to_date': DateFormat('yyyy-MM-dd').format(toDate.value),
        if (selectedStaffId.value != null && selectedStaffId.value != 'all')
          'staff_id': selectedStaffId.value!,
      },
    );
  }
}