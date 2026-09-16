// lib/app/modules/bookingDetails/controllers/booking_details_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BookingDetailsController extends GetxController {
  BookingDetailsController({BookingRepository? repository})
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

  final RxBool isCustomerInfoExpanded = true.obs;
  final Rxn<BookingModel> booking = Rxn<BookingModel>();
  final RxBool isLoading = true.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyStatus = RxnInt();

  int? _bookingId;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    if (_bookingId != null) fetchDetail();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is int) {
      _bookingId = args;
    } else if (args is BookingModel) {
      _bookingId = args.id;
      booking.value = args;
    }
  }

  Future<void> fetchDetail() async {
    final id = _bookingId ?? booking.value?.id;
    if (id == null) return;
    isLoading.value = true;
    loadFailed.value = false;
    final res = await _repo.getBookingDetail(id);
    if (!res.isCompleted || res.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: res.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }
    booking.value = res.data;
    isLoading.value = false;
  }

  void retry() => fetchDetail();

  void toggleCustomerInfo() {
    isCustomerInfoExpanded.value = !isCustomerInfoExpanded.value;
  }

  Future<void> openEdit() async {
    final current = booking.value;
    if (current == null || !current.isEditable) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Only pending bookings can be edited',
      );
      return;
    }
    final result =
        await Get.toNamed(Routes.CREATE_BOOKING, arguments: current);
    if (result is BookingModel) {
      booking.value = result;
    } else {
      fetchDetail();
    }
  }

  Future<void> changeStatus(
    String newStatus, {
    String? returnAmount,
    String? paymentMethod,
    String? transactionId,
    int? mediaId,
  }) async {
    final current = booking.value;
    if (current == null || newStatus == current.status) return;
    busyStatus.value = current.id;
    final res = await _repo.changeBookingStatus(
      id: current.id,
      status: newStatus,
      returnAmount: returnAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      mediaId: mediaId,
    );
    busyStatus.value = null;
    if (res.isCompleted && res.data != null) {
      booking.value = res.data;
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: res.message ?? 'Status updated successfully!',
      );
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: res.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }
}
