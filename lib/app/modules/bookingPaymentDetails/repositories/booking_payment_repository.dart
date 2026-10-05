// lib/app/modules/bookingPaymentDetails/repositories/booking_payment_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/models/booking_payment_details_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BookingPaymentRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /bookings/{id}/details — booking + activities + payments + editData
  /// (when [paymentId] is sent).
  Future<ApiResponse<BookingPaymentDetailsResponse>> getDetails({
    required int bookingId,
    int? paymentId,
    int paymentsPage = 1,
    int activitiesPage = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'payments_page': paymentsPage,
        'activities_page': activitiesPage,
      };
      if (paymentId != null) queryParams['payment_id'] = paymentId;
      final response = await _network.get(
        endpoint: ApiPath.bookingDetails(bookingId),
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final model =
            BookingPaymentDetailsResponse.fromJson(response.data!);
        return ApiResponse.completed(model, message: response.message);
      }

      return ApiResponse.error(
        response.message ??
            'bookingPaymentDetails.errors.fetchFailed'.trns(),
        errors: response.errors,
      );
    } catch (_) {
      return ApiResponse.error(
        'bookingPaymentDetails.errors.unexpected'.trns(),
      );
    }
  }

  /// POST /payments
  Future<ApiResponse<Map<String, dynamic>>> createPayment(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _network.post(
        endpoint: ApiPath.payments,
        body: body,
      );

      if (response.isCompleted && response.data != null) {
        return ApiResponse.completed(
          response.data!,
          message: response.message,
        );
      }

      return ApiResponse.error(
        response.message ?? 'addNewPayment.errors.createFailed'.trns(),
        errors: response.errors,
      );
    } catch (_) {
      return ApiResponse.error('addNewPayment.errors.unexpected'.trns());
    }
  }

  /// POST /payments/{id} with `_method: PUT` (Laravel method spoofing).
  Future<ApiResponse<Map<String, dynamic>>> updatePayment({
    required int paymentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _network.post(
        endpoint: ApiPath.payment(paymentId),
        body: {'_method': 'PUT', ...body},
      );

      if (response.isCompleted && response.data != null) {
        return ApiResponse.completed(
          response.data!,
          message: response.message,
        );
      }

      return ApiResponse.error(
        response.message ?? 'addNewPayment.errors.updateFailed'.trns(),
        errors: response.errors,
      );
    } catch (_) {
      return ApiResponse.error('addNewPayment.errors.unexpected'.trns());
    }
  }
}
