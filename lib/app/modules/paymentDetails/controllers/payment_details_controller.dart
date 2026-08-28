// lib/app/modules/reports/payment_details/controllers/payment_details_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/revenueReport/service/revenue_service.dart';
import 'package:va_bookats/models/branch_info.dart';
import 'package:va_bookats/models/payment_item.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
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
  String getCellValue(PaymentItem item, String key) {
    switch (key) {
      case 'customer':
        return item.booking?.displayName ?? 'N/A';
      case 'bookingSerial':
        return '#${item.booking?.bookingSerial ?? 0}';
      case 'date':
        return item.date;
      case 'totalAmount':
        return '\$${item.totalAmount.toStringAsFixed(2)}';
      case 'paidAmount':
        return '\$${item.paidAmount.toStringAsFixed(2)}';
      case 'balance':
        return '\$${item.balance.toStringAsFixed(2)}';
      case 'paymentMethod':
        return item.paymentMethod ?? 'N/A';
      case 'status':
        return item.status;
      default:
        return '-';
    }
  }
}