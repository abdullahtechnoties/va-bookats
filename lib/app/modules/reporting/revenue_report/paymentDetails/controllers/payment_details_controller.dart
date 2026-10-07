// lib/app/modules/reports/payment_details/controllers/payment_details_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/revenue_report/revenueReport/service/revenue_service.dart';
import 'package:va_bookats/models/branch_info.dart';
import 'package:va_bookats/models/payment_item.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

enum PaymentTab { paid, unpaid, returned }

class PaymentDetailsController extends GetxController {
  final ReportService _reportService = Get.find<ReportService>();

  // ── Screen state ─────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final Rx<PaymentTab> activeTab = PaymentTab.paid.obs;

  // ── Arguments from route ─────────────────────────────────────────────────
  late int branchId;
  late String fromDate;
  late String toDate;

  // ── Branch info ──────────────────────────────────────────────────────────
  Rx<BranchInfo?> branchInfo = Rx<BranchInfo?>(null);

  // ── Payment lists ────────────────────────────────────────────────────────
  final RxList<PaymentItem> paidPayments = <PaymentItem>[].obs;
  final RxList<PaymentItem> unpaidPayments = <PaymentItem>[].obs;
  final RxList<PaymentItem> returnedPayments = <PaymentItem>[].obs;

  // ── Pagination meta ──────────────────────────────────────────────────────
  Rx<PaginationMeta?> paidMeta = Rx<PaginationMeta?>(null);
  Rx<PaginationMeta?> unpaidMeta = Rx<PaginationMeta?>(null);
  Rx<PaginationMeta?> returnMeta = Rx<PaginationMeta?>(null);

  final RxInt paidPage = 1.obs;
  final RxInt unpaidPage = 1.obs;
  final RxInt returnPage = 1.obs;

  // ── Computed ─────────────────────────────────────────────────────────────
  List<PaymentItem> get currentList {
    switch (activeTab.value) {
      case PaymentTab.paid:
        return paidPayments;
      case PaymentTab.unpaid:
        return unpaidPayments;
      case PaymentTab.returned:
        return returnedPayments;
    }
  }

  PaginationMeta? get currentMeta {
    switch (activeTab.value) {
      case PaymentTab.paid:
        return paidMeta.value;
      case PaymentTab.unpaid:
        return unpaidMeta.value;
      case PaymentTab.returned:
        return returnMeta.value;
    }
  }

  bool get hasNextPage => currentMeta?.hasNextPage ?? false;
  bool get hasPrevPage => (currentPage > 1);
  bool get showPagination => hasNextPage || hasPrevPage;

  /// `Sep 2, 2026 - Oct 2, 2026` — human readable range passed from the
  /// previous page, used in the top details card.
  String get dateRangeLabel {
    final from = _humanDate(fromDate);
    final to = _humanDate(toDate);
    if (from.isEmpty && to.isEmpty) return '';
    return '$from - $to';
  }

  int get currentPage {
    switch (activeTab.value) {
      case PaymentTab.paid:
        return paidPage.value;
      case PaymentTab.unpaid:
        return unpaidPage.value;
      case PaymentTab.returned:
        return returnPage.value;
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    fetchDetails();
  }

  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    branchId = args['branchId'] ?? 0;
    fromDate = args['fromDate'] ?? '';
    toDate = args['toDate'] ?? '';
  }

  // ── API Call ─────────────────────────────────────────────────────────────
  Future<void> fetchDetails({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final response = await _reportService.getRevenueDetails(
        branchId: branchId,
        fromDate: fromDate,
        toDate: toDate,
        paymentsPage: paidPage.value,
        unpaidPage: unpaidPage.value,
        returnPage: returnPage.value,
      );

      if (response.isCompleted && response.data != null) {
        _parseDetailsResponse(response.data!);
      } else {
        SnackbarService.showError(
          title: 'errors.errorTitle'.trns(),
          message: response.message ?? 'errors.unexpected'.trns(),
        );
      }
    } catch (e) {
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: 'errors.unexpected'.trns(),
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void _parseDetailsResponse(Map<String, dynamic> data) {
    // Branch info
    if (data['branch'] != null) {
      branchInfo.value = BranchInfo.fromJson(data['branch']);
    }

    // Paid payments
    if (data['payments'] != null) {
      final paidData = data['payments'] as Map<String, dynamic>;
      paidMeta.value = PaginationMeta.fromJson(paidData);
      paidPayments.value = (paidData['data'] as List? ?? [])
          .map((e) => PaymentItem.fromJson(e))
          .toList();
    }

    // Unpaid payments
    if (data['unpaidPayments'] != null) {
      final unpaidData = data['unpaidPayments'] as Map<String, dynamic>;
      unpaidMeta.value = PaginationMeta.fromJson(unpaidData);
      unpaidPayments.value = (unpaidData['data'] as List? ?? [])
          .map((e) => PaymentItem.fromJson(e))
          .toList();
    }

    // Return payments
    if (data['returnPayments'] != null) {
      final returnData = data['returnPayments'] as Map<String, dynamic>;
      returnMeta.value = PaginationMeta.fromJson(returnData);
      returnedPayments.value = (returnData['data'] as List? ?? [])
          .map((e) => PaymentItem.fromJson(e))
          .toList();
    }
  }

  // ── Tab Actions ──────────────────────────────────────────────────────────
  void setTab(PaymentTab tab) {
    activeTab.value = tab;
  }

  // ── Pagination ───────────────────────────────────────────────────────────
  void nextPage() {
    if (!hasNextPage) return;

    switch (activeTab.value) {
      case PaymentTab.paid:
        paidPage.value++;
        break;
      case PaymentTab.unpaid:
        unpaidPage.value++;
        break;
      case PaymentTab.returned:
        returnPage.value++;
        break;
    }

    fetchDetails();
  }

  void prevPage() {
    if (!hasPrevPage) return;

    switch (activeTab.value) {
      case PaymentTab.paid:
        paidPage.value--;
        break;
      case PaymentTab.unpaid:
        unpaidPage.value--;
        break;
      case PaymentTab.returned:
        returnPage.value--;
        break;
    }

    fetchDetails();
  }

  // ── Table helpers ────────────────────────────────────────────────────────
  /// Columns: customer_name, customer_email, customer_phone, payment_method,
  /// date, status, total amount, discount, total paid, total balance.
  String getCellValue(PaymentItem item, String key) {
    switch (key) {
      case 'customer_name':
        return item.booking?.displayName ?? 'N/A';
      case 'customer_email':
        return item.booking?.guestEmail ?? 'N/A';
      case 'customer_phone':
        return item.booking?.guestPhone ?? 'N/A';
      case 'payment_method':
        return item.paymentMethod ?? 'N/A';
      case 'date':
        return _humanDate(item.date);
      case 'status':
        return item.status;
      case 'total_amount':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.totalAmount)}';
      case 'discount':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.discountAmount)}';
      case 'total_paid':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.paidAmount)}';
      case 'total_balance':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.balance)}';
      // Legacy keys kept for backward compatibility.
      case 'customer':
        return item.booking?.displayName ?? 'N/A';
      case 'bookingSerial':
        return '#${item.booking?.bookingSerial ?? 0}';
      case 'totalAmount':
        return formatReportCell(key, item.totalAmount);
      case 'paidAmount':
        return formatReportCell(key, item.paidAmount);
      case 'balance':
        return formatReportCell(key, item.balance);
      case 'paymentMethod':
        return item.paymentMethod ?? 'N/A';
      default:
        return '-';
    }
  }

  String _humanDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return reportHumanDate(parsed);
  }
}
