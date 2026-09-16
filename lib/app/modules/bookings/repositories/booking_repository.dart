// lib/app/modules/bookings/repositories/booking_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BookingsPage {
  final List<BookingModel> bookings;
  final PaginationMeta meta;

  const BookingsPage({required this.bookings, required this.meta});
}

class ServiceDraft {
  final int serviceId;
  final int? variationId;
  final int? employeeId;
  final String amount;
  final String discount;
  final String totalAmount;

  const ServiceDraft({
    required this.serviceId,
    this.variationId,
    this.employeeId,
    required this.amount,
    required this.discount,
    required this.totalAmount,
  });
}

class PackageDraft {
  final int packageId;
  final String amount;
  final String discount;
  final String totalAmount;
  final List<int> staffIds;

  const PackageDraft({
    required this.packageId,
    required this.amount,
    required this.discount,
    required this.totalAmount,
    this.staffIds = const [],
  });
}

class ProductDraft {
  final int productId;
  final int? variantId;
  final String quantity;
  final String unitPrice;
  final String totalPrice;
  final String discount;
  final String afterDiscountPrice;

  const ProductDraft({
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.afterDiscountPrice,
  });
}

class BookingRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /bookings — paginated + filters.
  Future<ApiResponse<BookingsPage>> getBookings({
    required int page,
    String? status,
    String? search,
    String? fromDate,
    String? toDate,
    int? branchId,
    String? bookingType,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.bookings,
      queryParams: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        if (branchId != null) 'branch_id': branchId,
        if (bookingType != null && bookingType.isNotEmpty)
          'booking_type': bookingType,
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
    final bookings = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
            .where((b) => b.id != 0)
            .toList()
        : <BookingModel>[];

    return ApiResponse.completed(
      BookingsPage(
        bookings: bookings,
        meta: PaginationMeta.fromJson(body),
      ),
      message: response.message,
    );
  }

  /// GET /bookings/{id}
  Future<ApiResponse<BookingModel>> getBookingDetail(int id) async {
    final response = await _network.get(endpoint: ApiPath.booking(id));
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['booking'] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    return ApiResponse.completed(
      BookingModel.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }

  /// POST /bookings — multipart fields (arrays via indexed keys) + media_id.
  Future<ApiResponse<BookingModel>> createBooking({
    int? branchId,
    required String bookingType,
    int? customerId,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? note,
    String? totalAmount,
    String? amountPaid,
    String? discount,
    String? remainingAmount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    int? mediaId,
    List<ServiceDraft> services = const [],
    List<PackageDraft> packages = const [],
    List<ProductDraft> products = const [],
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.bookings,
      fields: _buildFields(
        branchId: branchId,
        bookingType: bookingType,
        customerId: customerId,
        guestName: guestName,
        guestEmail: guestEmail,
        guestPhone: guestPhone,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        note: note,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        discount: discount,
        remainingAmount: remainingAmount,
        paymentMethod: paymentMethod,
        status: status,
        transactionId: transactionId,
        mediaId: mediaId,
        services: services,
        packages: packages,
        products: products,
      ),
    );
    return _mapSingleBooking(response);
  }

  /// POST /bookings/{id} + `_method: PUT` (only when status is Pending).
  Future<ApiResponse<BookingModel>> updateBooking({
    required int id,
    int? branchId,
    required String bookingType,
    int? customerId,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? note,
    String? totalAmount,
    String? amountPaid,
    String? discount,
    String? remainingAmount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    int? mediaId,
    List<ServiceDraft> services = const [],
    List<PackageDraft> packages = const [],
    List<ProductDraft> products = const [],
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.booking(id),
      fields: {
        '_method': 'PUT',
        ..._buildFields(
          branchId: branchId,
          bookingType: bookingType,
          customerId: customerId,
          guestName: guestName,
          guestEmail: guestEmail,
          guestPhone: guestPhone,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
          note: note,
          totalAmount: totalAmount,
          amountPaid: amountPaid,
          discount: discount,
          remainingAmount: remainingAmount,
          paymentMethod: paymentMethod,
          status: status,
          transactionId: transactionId,
          mediaId: mediaId,
          services: services,
          packages: packages,
          products: products,
        ),
      },
    );
    return _mapSingleBooking(response);
  }

  /// POST /bookings/{id}/status + `_method: PUT`.
  /// Cancelling additionally sends return/payment fields.
  Future<ApiResponse<BookingModel>> changeBookingStatus({
    required int id,
    required String status,
    String? returnAmount,
    String? paymentMethod,
    String? transactionId,
    int? mediaId,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.bookingStatus(id),
      fields: {
        '_method': 'PUT',
        'status': status,
        if (returnAmount != null && returnAmount.isNotEmpty)
          'return_amount': returnAmount,
        if (paymentMethod != null && paymentMethod.isNotEmpty)
          'payment_method': paymentMethod,
        if (transactionId != null && transactionId.isNotEmpty)
          'transaction_id': transactionId,
        if (mediaId != null) 'media_id': mediaId,
      },
    );
    return _mapSingleBooking(response);
  }

  // ─── Lookups ─────────────────────────────────────────────────────────────

  Future<ApiResponse<List<BranchModel>>> getBranches() async {
    final response = await _network.getRaw(endpoint: ApiPath.branches);
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    if (raw is! List) return ApiResponse.error('errors.unexpectedShort'.trns());
    final branches = raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();
    return ApiResponse.completed(branches);
  }

  Future<ApiResponse<List<LookupOption>>> getCustomers() async {
    final response =
        await _network.getRaw(endpoint: ApiPath.bookingCustomers);
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    if (raw is! List) return ApiResponse.error('errors.unexpectedShort'.trns());
    final options = raw
        .whereType<Map>()
        .map((e) => LookupOption.fromJson(Map<String, dynamic>.from(e)))
        .where((o) => o.value.isNotEmpty)
        .toList();
    return ApiResponse.completed(options);
  }

  Future<ApiResponse<List<PackageLookup>>> getPackages(int branchId) async {
    final response = await _network.getRaw(
      endpoint: ApiPath.bookingPackages(branchId),
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
    final items = list
        .whereType<Map>()
        .map((e) => PackageLookup.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.value != 0)
        .toList();
    return ApiResponse.completed(items);
  }

  Future<ApiResponse<List<LookupOption>>> getPackageStaffs({
    required int packageId,
    String? bookingDate,
    String? startTime,
    String? endTime,
  }) async {
    var endpoint = ApiPath.bookingPackageStaffs(packageId);
    final query = <String>[];
    if (bookingDate != null && bookingDate.isNotEmpty) {
      query.add('booking_date=${Uri.encodeComponent(bookingDate)}');
    }
    if (startTime != null && startTime.isNotEmpty) {
      query.add('start_time=${Uri.encodeComponent(startTime)}');
    }
    if (endTime != null && endTime.isNotEmpty) {
      query.add('end_time=${Uri.encodeComponent(endTime)}');
    }
    if (query.isNotEmpty) endpoint += '?${query.join('&')}';
    return _getLookupList(endpoint);
  }

  Future<ApiResponse<List<ServiceLookup>>> getServices(int branchId) async {
    final response = await _network.getRaw(
      endpoint: ApiPath.bookingServices(branchId),
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
    final items = list
        .whereType<Map>()
        .map((e) => ServiceLookup.fromJson(Map<String, dynamic>.from(e)))
        .where((s) => s.value != 0)
        .toList();
    return ApiResponse.completed(items);
  }

  Future<ApiResponse<List<LookupOption>>> getServiceStaffs(
    int serviceId,
  ) async {
    return _getLookupList(ApiPath.bookingServiceStaffs(serviceId));
  }

  Future<ApiResponse<List<ProductLookup>>> getProducts(int branchId) async {
    final response = await _network.getRaw(
      endpoint: ApiPath.bookingProducts(branchId),
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
    final items = list
        .whereType<Map>()
        .map((e) => ProductLookup.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.value != 0)
        .toList();
    return ApiResponse.completed(items);
  }

  Future<ApiResponse<List<LookupOption>>> _getLookupList(
    String endpoint,
  ) async {
    final response = await _network.getRaw(endpoint: endpoint);
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
    final options = list
        .whereType<Map>()
        .map((e) => LookupOption.fromJson(Map<String, dynamic>.from(e)))
        .where((o) => o.value.isNotEmpty)
        .toList();
    return ApiResponse.completed(options);
  }

  // ─── Payload ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _buildFields({
    int? branchId,
    required String bookingType,
    int? customerId,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? note,
    String? totalAmount,
    String? amountPaid,
    String? discount,
    String? remainingAmount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    int? mediaId,
    List<ServiceDraft> services = const [],
    List<PackageDraft> packages = const [],
    List<ProductDraft> products = const [],
  }) {
    return {
      if (branchId != null) 'branch_id': branchId,
      'booking_type': bookingType,
      if (customerId != null) 'customer_id': customerId,
      if (guestName != null && guestName.isNotEmpty) 'guest_name': guestName,
      if (guestEmail != null && guestEmail.isNotEmpty)
        'guest_email': guestEmail,
      if (guestPhone != null && guestPhone.isNotEmpty)
        'guest_phone': guestPhone,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      if (note != null && note.isNotEmpty) 'note': note,
      if (totalAmount != null && totalAmount.isNotEmpty)
        'total_amount': totalAmount,
      if (amountPaid != null && amountPaid.isNotEmpty)
        'amount_paid': amountPaid,
      if (discount != null && discount.isNotEmpty) 'discount': discount,
      if (remainingAmount != null && remainingAmount.isNotEmpty)
        'remaining_amount': remainingAmount,
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'payment_method': paymentMethod,
      if (status != null && status.isNotEmpty) 'status': status,
      if (transactionId != null && transactionId.isNotEmpty)
        'transaction_id': transactionId,
      if (mediaId != null) 'media_id': mediaId,
      for (var i = 0; i < services.length; i++) ...{
        'serviceItems[$i][service_id]': services[i].serviceId,
        if (services[i].variationId != null)
          'serviceItems[$i][variation_id]': services[i].variationId,
        if (services[i].employeeId != null)
          'serviceItems[$i][employee_id]': services[i].employeeId,
        'serviceItems[$i][amount]': services[i].amount,
        'serviceItems[$i][discount]': services[i].discount,
        'serviceItems[$i][total_amount]': services[i].totalAmount,
      },
      for (var i = 0; i < packages.length; i++) ...{
        'packageItems[$i][package_id]': packages[i].packageId,
        'packageItems[$i][amount]': packages[i].amount,
        'packageItems[$i][discount]': packages[i].discount,
        'packageItems[$i][total_amount]': packages[i].totalAmount,
        for (var j = 0; j < packages[i].staffIds.length; j++)
          'packageItems[$i][package_employee_id][$j]':
              packages[i].staffIds[j],
      },
      for (var i = 0; i < products.length; i++) ...{
        'productItems[$i][product_id]': products[i].productId,
        if (products[i].variantId != null)
          'productItems[$i][product_variant_id]': products[i].variantId,
        'productItems[$i][quantity]': products[i].quantity,
        'productItems[$i][unit_price]': products[i].unitPrice,
        'productItems[$i][total_price]': products[i].totalPrice,
        'productItems[$i][discount]': products[i].discount,
        'productItems[$i][after_discount_price]':
            products[i].afterDiscountPrice,
      },
    };
  }

  ApiResponse<BookingModel> _mapSingleBooking(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['booking'] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    return ApiResponse.completed(
      BookingModel.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }
}
