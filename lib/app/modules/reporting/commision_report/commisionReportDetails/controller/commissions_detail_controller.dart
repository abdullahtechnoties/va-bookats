import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/models/commissions_detail_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class CommissionsDetailController extends GetxController {
  final NetworkService _network = Get.find();

  // ── Route Params ──────────────────────────────────────────────────────────
  late final int branchId;
  late final String fromDate;
  late final String toDate;
  final String? staffId;

  CommissionsDetailController({
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    this.staffId,
  });

  // ── API Response ──────────────────────────────────────────────────────────
  final Rx<ApiResponse<CommissionsDetailResponse>> apiResponse =
      ApiResponse<CommissionsDetailResponse>.loading().obs;

  final RxInt currentPage = 1.obs;

  // ── Computed ──────────────────────────────────────────────────────────────
  BranchInfo? get branch => apiResponse.value.data?.branch;

  List<StaffCommissionSummary> get summaries =>
      apiResponse.value.data?.dailyStaffCommissionSummaries.items ?? [];

  PaginationMeta? get paginationMeta =>
      apiResponse.value.data?.dailyStaffCommissionSummaries.meta;

  bool get hasNextPage => paginationMeta?.hasNextPage ?? false;

  String get dateRangeLabel {
    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);
      final fmt = DateFormat('MMM/d/yyyy');
      return '${fmt.format(from)} - ${fmt.format(to)}';
    } catch (_) {
      return '$fromDate - $toDate';
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  // ── API ───────────────────────────────────────────────────────────────────
  Future<void> fetchDetails({bool showLoading = true}) async {
    if (showLoading) {
      apiResponse.value = ApiResponse.loading();
    }

    final endpoint = ApiPath.commissionsReportDetails(
      branchId: branchId,
      fromDate: fromDate,
      toDate: toDate,
      staffId: staffId,
      page: currentPage.value,
    );

    final response = await _network.get(endpoint: endpoint);

    if (response.isCompleted && response.data != null) {
      try {
        final data = CommissionsDetailResponse.fromJson(response.data!);
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

  // ── Pagination ────────────────────────────────────────────────────────────
  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchDetails(showLoading: false);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchDetails(showLoading: false);
    }
  }

  // ── Refresh ───────────────────────────────────────────────────────────────
  Future<void> onRefresh() async {
    currentPage.value = 1;
    await fetchDetails();
  }
}