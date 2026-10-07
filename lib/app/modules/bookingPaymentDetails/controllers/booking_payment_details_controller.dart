import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/models/booking_payment_details_model.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/repositories/booking_payment_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

enum PaymentDetailTab { details, payments, activities }

class BookingPaymentDetailsController extends GetxController {
  final BookingPaymentRepository _repository = BookingPaymentRepository();

  // ── Arguments ───────────────────────────────────────────────────────────
  late final int bookingId;

  // ── State ───────────────────────────────────────────────────────────────
  final Rx<ApiResponse<BookingPaymentDetailsResponse>> detailsResponse =
      ApiResponse<BookingPaymentDetailsResponse>.loading().obs;
  final Rx<PaymentDetailTab> activeTab = PaymentDetailTab.details.obs;

  BookingPaymentDetailsResponse? get data => detailsResponse.value.data;
  BookingDetailsData? get booking => data?.booking;
  bool get isLoading => detailsResponse.value.isLoading;
  bool get hasError => detailsResponse.value.isError;
  bool get hasData => booking != null && booking!.id != 0;

  // ── Pagination ──────────────────────────────────────────────────────────
  final RxInt paymentsPage = 1.obs;
  final RxInt activitiesPage = 1.obs;

  List<PaymentEntry> get paymentRecords => data?.payments.items ?? [];
  List<ActivityItem> get activityRecords => data?.activities.items ?? [];

  bool get hasNextPaymentsPage => data?.payments.meta.hasNextPage ?? false;
  bool get hasPrevPaymentsPage => paymentsPage.value > 1;
  bool get showPaymentsPagination =>
      hasNextPaymentsPage || hasPrevPaymentsPage;

  bool get hasNextActivitiesPage =>
      data?.activities.meta.hasNextPage ?? false;
  bool get hasPrevActivitiesPage => activitiesPage.value > 1;
  bool get showActivitiesPagination =>
      hasNextActivitiesPage || hasPrevActivitiesPage;

  // ── Branch card ─────────────────────────────────────────────────────────
  String get currencySymbol => booking?.branch?.currency?.symbol ?? '₨';
  String get branchName => booking?.branch?.name ?? '';
  String get branchEmail => booking?.branch?.emailPrimary ?? '';
  String get branchPhone => booking?.branch?.phonePrimary ?? '';
  String get branchDate => humanDate(booking?.bookingDate ?? '');
  String get customerName => booking?.displayName ?? '';

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchDetails();
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args is int) {
      bookingId = args;
    } else if (args is Map) {
      bookingId = int.tryParse(args['bookingId']?.toString() ?? '0') ?? 0;
    } else {
      bookingId = 0;
    }
  }

  // ── API ─────────────────────────────────────────────────────────────────
  Future<void> fetchDetails() async {
    detailsResponse.value = ApiResponse.loading();
    final response = await _repository.getDetails(
      bookingId: bookingId,
      paymentsPage: paymentsPage.value,
      activitiesPage: activitiesPage.value,
    );
    detailsResponse.value = response;
    if (response.isError) {
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: response.message ??
            'bookingPaymentDetails.errors.fetchFailed'.trns(),
      );
    }
  }

  Future<void> refreshDetails() async {
    paymentsPage.value = 1;
    activitiesPage.value = 1;
    await fetchDetails();
  }

  // ── Tabs ────────────────────────────────────────────────────────────────
  void setTab(PaymentDetailTab tab) => activeTab.value = tab;

  // ── Pagination ──────────────────────────────────────────────────────────
  Future<void> nextPaymentsPage() async {
    if (!hasNextPaymentsPage) return;
    paymentsPage.value++;
    await _fetchPaymentsPage();
  }

  Future<void> prevPaymentsPage() async {
    if (!hasPrevPaymentsPage) return;
    paymentsPage.value--;
    await _fetchPaymentsPage();
  }

  Future<void> _fetchPaymentsPage() async {
    final response = await _repository.getDetails(
      bookingId: bookingId,
      paymentsPage: paymentsPage.value,
      activitiesPage: activitiesPage.value,
    );
    if (response.isCompleted) {
      detailsResponse.value = response;
    } else {
      paymentsPage.value--;
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: response.message ??
            'bookingPaymentDetails.errors.fetchFailed'.trns(),
      );
    }
  }

  Future<void> nextActivitiesPage() async {
    if (!hasNextActivitiesPage) return;
    activitiesPage.value++;
    await _fetchActivitiesPage();
  }

  Future<void> prevActivitiesPage() async {
    if (!hasPrevActivitiesPage) return;
    activitiesPage.value--;
    await _fetchActivitiesPage();
  }

  Future<void> _fetchActivitiesPage() async {
    final response = await _repository.getDetails(
      bookingId: bookingId,
      paymentsPage: paymentsPage.value,
      activitiesPage: activitiesPage.value,
    );
    if (response.isCompleted) {
      detailsResponse.value = response;
    } else {
      activitiesPage.value--;
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: response.message ??
            'bookingPaymentDetails.errors.fetchFailed'.trns(),
      );
    }
  }

  // ── Details-tab lines table ─────────────────────────────────────────────
  List<BookingLineItem> get lineItems {
    final b = booking;
    if (b == null) return [];
    final out = <BookingLineItem>[];
    var i = 0;
    for (final p in b.packages) {
      out.add(
        BookingLineItem(
          index: ++i,
          name: p.packageName.isNotEmpty ? p.packageName : '-',
          staff: p.staffs.map((s) => s.staffName).where((n) => n.isNotEmpty).join(', '),
          category: '-',
          variation: '-',
          price: money(p.amount),
          qty: '-',
          total: money(p.totalAmount),
          discount: money(p.discount),
          afterDiscount: money(p.totalAmount),
        ),
      );
    }
    for (final s in b.services) {
      out.add(
        BookingLineItem(
          index: ++i,
          name: s.serviceName.isNotEmpty ? s.serviceName : '-',
          staff: s.employeeName.isNotEmpty ? s.employeeName : '-',
          category: s.categoryName.isNotEmpty ? s.categoryName : '-',
          variation: (s.variationName ?? '').isNotEmpty ? s.variationName! : '-',
          price: money(s.amount),
          qty: '1',
          total: money(s.totalAmount),
          discount: money(s.discount),
          afterDiscount: money(s.totalAmount),
        ),
      );
    }
    for (final p in b.products) {
      out.add(
        BookingLineItem(
          index: ++i,
          name: p.productName.isNotEmpty ? p.productName : '-',
          staff: '-',
          category: p.categoryNames.isNotEmpty
              ? p.categoryNames.join(', ')
              : '-',
          variation: p.variantNames.isNotEmpty
              ? p.variantNames.join(' / ')
              : '-',
          price: money(p.unitPrice),
          qty: '${p.quantity}',
          total: money(p.totalPrice),
          discount: money(p.discount),
          afterDiscount: money(p.afterDiscountPrice),
        ),
      );
    }
    return out;
  }

  // ── Navigation ──────────────────────────────────────────────────────────
  Future<void> openCreatePayment() async {
    final b = booking;
    if (b == null) return;
    final result = await Get.toNamed(
      Routes.ADD_NEW_PAYMENT,
      arguments: {
        'bookingId': b.id,
        'branchId': b.branchId,
        'branchName': branchName,
        'customerId': b.customerId,
      },
    );
    if (result == true) refreshDetails();
  }

  Future<void> openEditPayment(PaymentEntry payment) async {
    // Every payment is editable regardless of status; the form always
    // fetches that payment's own editData via its payment_id.
    final b = booking;
    final result = await Get.toNamed(
      Routes.ADD_NEW_PAYMENT,
      arguments: {
        'bookingId': payment.bookingId,
        'branchId': payment.branchId,
        'branchName': branchName,
        'customerId': b?.customerId,
        'paymentId': payment.id,
      },
    );
    if (result == true) refreshDetails();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  String money(String raw) {
    final n = double.tryParse(raw);
    if (n == null) return raw.isEmpty ? '-' : raw;
    return '$currencySymbol ${n.toStringAsFixed(2)}';
  }

  String humanDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return reportHumanDate(parsed);
  }

  String humanDateTime(String dateStr) {
    if (dateStr.isEmpty) return '-';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    final local = parsed.toLocal();
    final date = reportHumanDate(local);
    var hour = local.hour % 12;
    if (hour == 0) hour = 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$date $hour:$minute $period';
  }

  String formatStatus(String status) {
    final s = status.trim();
    if (s.isEmpty) return '-';
    if (s.length == 1) return s.toUpperCase();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
