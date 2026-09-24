// lib/app/modules/customerDetails/controllers/customer_details_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/models/customer_report_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

enum BookingStatusTab { all, completed, pending, cancelled }

class CustomerDetailsController extends GetxController {
  final NetworkService _network = Get.find<NetworkService>();

  // ── Route params ──────────────────────────────────────────────────────────
  late final int branchId;
  late final String customerId;
  late final String fromDate;
  late final String toDate;
  late final String branchName;

  // ── API response state ────────────────────────────────────────────────────
  final Rx<ApiResponse<CustomerDetailsResponse>> detailsResponse =
      ApiResponse<CustomerDetailsResponse>.loading().obs;

  // ── Tab state ─────────────────────────────────────────────────────────────
  final Rx<BookingStatusTab> activeTab = BookingStatusTab.all.obs;

  // ── Pagination ────────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  final RxBool isLoadingMore = false.obs;

  // ── Computed ──────────────────────────────────────────────────────────────
  BranchDetails? get branch => detailsResponse.value.data?.branch;
  String get customerName => detailsResponse.value.data?.customerName ?? '';

  List<BookingData> get allBookings =>
      detailsResponse.value.data?.bookings ?? [];

  List<BookingData> get filteredBookings {
    switch (activeTab.value) {
      case BookingStatusTab.completed:
        return allBookings.where((b) => b.isCompleted).toList();
      case BookingStatusTab.pending:
        return allBookings.where((b) => b.isPending).toList();
      case BookingStatusTab.cancelled:
        return allBookings.where((b) => b.isCancelled).toList();
      case BookingStatusTab.all:
        return allBookings;
    }
  }

  PaginationMeta? get paginationMeta =>
      detailsResponse.value.data?.paginationMeta;
  bool get hasMorePages => paginationMeta?.hasNextPage ?? false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadParams();
    fetchDetails();
  }

  void _loadParams() {
    branchId = int.tryParse(Get.parameters['branch_id'] ?? '0') ?? 0;
    customerId = Get.parameters['customer_id'] ?? 'all';
    fromDate = Get.parameters['from_date'] ?? '';
    toDate = Get.parameters['to_date'] ?? '';
    branchName = Get.parameters['branch_name'] ?? '';
  }

  // ── API Calls ─────────────────────────────────────────────────────────────
  Future<void> fetchDetails({int page = 1}) async {
    try {
      if (page == 1) {
        detailsResponse.value = ApiResponse.loading();
      } else {
        isLoadingMore.value = true;
      }

      final params = <String, dynamic>{
        'branch_id': branchId,
        'customer_id': customerId,
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
      };

      final response = await _network.get(
        endpoint: ApiPath.customersReportDetails,
        queryParams: params,
      );

      if (response.isCompleted && response.data != null) {
        final parsed = CustomerDetailsResponse.fromJson(response.data!);

        if (page == 1) {
          detailsResponse.value = ApiResponse.completed(parsed);
        } else {
          // Append bookings for pagination
          final existingBookings = detailsResponse.value.data?.bookings ?? [];
          final updatedResponse = CustomerDetailsResponse(
            branch: parsed.branch,
            fromDate: parsed.fromDate,
            toDate: parsed.toDate,
            customerName: parsed.customerName,
            bookings: [...existingBookings, ...parsed.bookings],
            paginationMeta: parsed.paginationMeta,
            customerId: parsed.customerId,
          );
          detailsResponse.value = ApiResponse.completed(updatedResponse);
        }
        currentPage.value = page;
      } else {
        if (page == 1) {
          detailsResponse.value = ApiResponse.error(
            response.message ?? 'customerDetails.errors.fetchFailed'.trns(),
          );
        }
      }
    } catch (e) {
      if (page == 1) {
        detailsResponse.value = ApiResponse.error(e.toString());
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshDetails() async {
    currentPage.value = 1;
    await fetchDetails(page: 1);
  }

  void loadNextPage() {
    if (!isLoadingMore.value && hasMorePages) {
      fetchDetails(page: currentPage.value + 1);
    }
  }

  // ── Tab Actions ───────────────────────────────────────────────────────────
  void setTab(BookingStatusTab tab) {
    activeTab.value = tab;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String formatDate(String apiDate) {
    try {
      final parsed = DateTime.parse(apiDate);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[parsed.month]}/${parsed.day}/${parsed.year}';
    } catch (_) {
      return apiDate;
    }
  }

  String formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time;
    }
  }
}
