// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/allBooking/controllers/all_booking_controller.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/modules/home/models/home_model.dart';
import 'package:va_bookats/app/modules/home/repositories/home_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class HomeController extends GetxController {
  HomeController({BookingRepository? repository}) : _repository = repository;

  final BookingRepository? _repository;
  BookingRepository get _repo {
    final r = _repository;
    if (r != null) return r;
    if (Get.isRegistered<BookingRepository>()) {
      return Get.find<BookingRepository>();
    }
    return BookingRepository();
  }

  final AuthService auth = Get.find<AuthService>();
  final HomeRepository _homeRepo = HomeRepository();

  final RxList<BookingModel> todayBookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyBookingId = RxnInt();

  // ── Home dashboard (counts, revenue graph, and recent bookings) ───────
  final Rx<ApiResponse<HomeData>> homeResponse =
      ApiResponse<HomeData>.loading().obs;

  HomeData? get home => homeResponse.value.data;
  bool get hasHome => home != null;
  bool get isLoadingHome => homeResponse.value.isLoading;

  String get userName => auth.currentUser.value?.displayName ?? '';
  String get userImage => auth.currentUser.value?.image ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchHome();
  }

  Future<void> fetchHome() async {
    isLoading.value = true;
    loadFailed.value = false;

    final response = await _homeRepo.getHome();
    homeResponse.value = response;
    if (response.isCompleted && response.data != null) {
      todayBookings.assignAll(response.data!.bookings);
    } else {
      loadFailed.value = true;
    }
    isLoading.value = false;
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    await fetchHome();
    isRefreshing.value = false;
  }

  void retry() {
    fetchHome();
  }

  /// Homepage search bar → AllBookings with search opened + focused.
  /// The AllBookings controller already lives inside the bottom-nav
  /// IndexedStack, so switch to its tab and drive it directly instead of
  /// pushing a duplicate route with Get.arguments (which caused the
  /// setState-during-build red screen).
  void openSearch() {
    if (!Permissions.can(AppPerm.index(AppPerm.bookings))) {
      showNoAccessDialog();
      return;
    }
    try {
      final bottomnav = Get.find<BottomnavController>();
      bottomnav.changeTabIndex(1);
      // Let the IndexedStack settle, then open search on the shared instance.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<AllBookingController>()) {
          Get.find<AllBookingController>().openSearchMode();
        } else {
          Get.toNamed(Routes.ALL_BOOKING, arguments: {'autoFocusSearch': true});
        }
      });
    } catch (_) {
      Get.toNamed(Routes.ALL_BOOKING, arguments: {'autoFocusSearch': true});
    }
  }

  void openAllBookings() {
    if (!Permissions.can(AppPerm.index(AppPerm.bookings))) {
      showNoAccessDialog();
      return;
    }
    try {
      Get.find<BottomnavController>().changeTabIndex(1);
    } catch (_) {
      Get.toNamed(Routes.ALL_BOOKING, arguments: {'autoFocusSearch': false});
    }
  }

  void openDetails(BookingModel booking) {
    Get.toNamed(Routes.BOOKING_DETAILS, arguments: booking.id)?.then((_) {
      // Details may change status → refresh silently.
      fetchHome();
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
