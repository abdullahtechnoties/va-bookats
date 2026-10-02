// lib/app/modules/payments/repositories/payment_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/payment_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PaymentsPage {
  final List<PaymentModel> payments;
  final PaginationMeta meta;

  const PaymentsPage({required this.payments, required this.meta});
}

class PaymentRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /payments — paginated + filters.
  Future<ApiResponse<PaymentsPage>> getPayments({
    required int page,
    String? status,
    String? search,
    int? branchId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.payments,
      queryParams: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (branchId != null) 'branch_id': branchId,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      },
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawList = body['data'];
    final payments = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
              .where((p) => p.id != 0)
              .toList()
        : <PaymentModel>[];

    return ApiResponse.completed(
      PaymentsPage(payments: payments, meta: PaginationMeta.fromJson(body)),
      message: response.message,
    );
  }

  /// GET /payments/{id}
  Future<ApiResponse<PaymentModel>> getPaymentDetail(int id) async {
    final response = await _network.get(endpoint: ApiPath.payment(id));
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['payment'] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    return ApiResponse.completed(
      PaymentModel.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }

  /// GET /data/branches — top-level JSON array (for the branch filter).
  Future<ApiResponse<List<BranchModel>>> getBranches() async {
    final response = await _network.getRaw(endpoint: ApiPath.branches);
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    if (raw is! List) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    final branches = raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();
    return ApiResponse.completed(branches);
  }
}
