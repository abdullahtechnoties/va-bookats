// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class HomeController extends GetxController {
  HomeController({BookingRepository? repository})
      : _repository = repository;

  final BookingRepository? _repository;
  BookingRepository get _repo {
    final r = _repository;
    if (r != null) return r;
    if (Get.isRegistered<BookingRepository>()) {
      return Get.find<BookingRepository>();
    }
    return BookingRepository();
  }

  final AuthService _auth = Get.find<AuthService>();

  final RxList<BookingModel> todayBookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyBookingId = RxnInt();

  String get userName =>
      _auth.currentUser.value?.displayName ?? '';
  String get userImage =>
      _auth.currentUser.value?.image ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchTodayBookings();
  }

  String _todayApiDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchTodayBookings() async {
    isLoading.value = true;
    loadFailed.value = false;
    // Today's bookings via date filter; backend ignores unknown params safely.
    final today = _todayApiDate();
    final response = await _repo.getBookings(
      page: 1,
      fromDate: today,
      toDate: today,
    );
    if (!response.isCompleted || response.data == null) {
      // Fallback: unfiltered first page so home never looks broken when the
      // backend doesn't support date params.
      final fallback = await _repo.getBookings(page: 1);
      if (!fallback.isCompleted || fallback.data == null) {
        loadFailed.value = true;
        isLoading.value = false;
        return;
      }
      todayBookings.assignAll(fallback.data!.bookings);
      isLoading.value = false;
      return;
    }
    var list = response.data!.bookings;
    // If date filter returned nothing, show recent bookings instead.
    if (list.isEmpty) {
      final fallback = await _repo.getBookings(page: 1);
      if (fallback.isCompleted && fallback.data != null) {
        list = fallback.data!.bookings;
      }
    }
    todayBookings.assignAll(list);
    isLoading.value = false;
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    await fetchTodayBookings();
    isRefreshing.value = false;
  }

  void retry() => fetchTodayBookings();

  /// Homepage search bar → AllBookings with search opened + focused.
  void openSearch() {
    Get.toNamed(Routes.ALL_BOOKING, arguments: {'autoFocusSearch': true});
  }

  void openDetails(BookingModel booking) {
    Get.toNamed(Routes.BOOKING_DETAILS, arguments: booking.id)?.then((_) {
      // Details may change status → refresh silently.
      fetchTodayBookings();
    });
  }

  Future<void> openCreate() async {
    await Get.toNamed(Routes.CREATE_BOOKING);
    handleRefresh();
  }

  Future<void> changeStatus(
    BookingModel booking,
    String newStatus, {
    String? returnAmount,
    String? paymentMethod,
    String? transactionId,
    int? mediaId,
  }) async {
    if (newStatus == booking.status) return;
    busyBookingId.value = booking.id;
    final response = await _repo.changeBookingStatus(
      id: booking.id,
      status: newStatus,
      returnAmount: returnAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      mediaId: mediaId,
    );
    busyBookingId.value = null;
    if (response.isCompleted && response.data != null) {
      final index = todayBookings.indexWhere((b) => b.id == booking.id);
      if (index != -1) todayBookings[index] = response.data!;
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: response.message ?? 'Status updated successfully!',
      );
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }
}
