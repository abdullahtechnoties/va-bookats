// lib/app/modules/customers/repositories/customer_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/customer_model.dart';
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class CustomersPage {
  final List<CustomerModel> customers;
  final PaginationMeta meta;

  const CustomersPage({required this.customers, required this.meta});
}

class AttachmentDraft {
  final String title;
  final int mediaId;

  const AttachmentDraft({required this.title, required this.mediaId});
}

class CustomerRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /customers — paginated + server-side filters.
  Future<ApiResponse<CustomersPage>> getCustomers({
    required int page,
    String? search,
    String? status,
    String? fromDate,
    String? toDate,
    int? countryId,
    int? branchId,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.customers,
      queryParams: {
        'page': page,
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        if (countryId != null) 'country_id': countryId,
        if (branchId != null) 'branch_id': branchId,
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
    final customers = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.id != 0)
            .toList()
        : <CustomerModel>[];

    return ApiResponse.completed(
      CustomersPage(
        customers: customers,
        meta: PaginationMeta.fromJson(body),
      ),
      message: response.message,
    );
  }

  /// GET /customers/{id} — returns a top-level JSON array:
  /// `[customerDetail, attachmentsPaginator]`.
  Future<ApiResponse<CustomerDetail>> getCustomerDetail(int id) async {
    final response = await _network.getRaw(endpoint: ApiPath.customer(id));
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final raw = response.data;
    if (raw is! List || raw.isEmpty || raw.first is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    final customer = CustomerModel.fromJson(
      Map<String, dynamic>.from(raw.first as Map),
    );

    var attachments = <CustomerAttachment>[];
    PaginationMeta? meta;
    if (raw.length > 1 && raw[1] is Map) {
      final pageMap = Map<String, dynamic>.from(raw[1] as Map);
      final rawList = pageMap['data'];
      if (rawList is List) {
        attachments = rawList
            .whereType<Map>()
            .map((e) =>
                CustomerAttachment.fromJson(Map<String, dynamic>.from(e)))
            .where((a) => a.id != 0)
            .toList();
      }
      try {
        meta = PaginationMeta.fromJson(pageMap);
      } catch (_) {
        meta = null;
      }
    }

    return ApiResponse.completed(
      CustomerDetail(
        customer: customer,
        attachments: attachments,
        attachmentsMeta: meta,
      ),
    );
  }

  /// POST /customers — multipart fields incl. `media_id` + indexed attachments.
  Future<ApiResponse<CustomerModel>> createCustomer({
    required String name,
    required String email,
    required String phonePrimary,
    String? gender,
    int? countryId,
    int? stateId,
    int? cityId,
    int? areaId,
    String? zipCode,
    String? address,
    String? latitude,
    String? longitude,
    int? mediaId,
    List<AttachmentDraft> attachments = const [],
    String? status,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.customers,
      fields: _buildFields(
        name: name,
        email: email,
        phonePrimary: phonePrimary,
        gender: gender,
        countryId: countryId,
        stateId: stateId,
        cityId: cityId,
        areaId: areaId,
        zipCode: zipCode,
        address: address,
        latitude: latitude,
        longitude: longitude,
        mediaId: mediaId,
        attachments: attachments,
        status: status,
      ),
    );
    return _mapSingleCustomer(response);
  }

  /// POST /customers/{id} + `_method: PUT`.
  Future<ApiResponse<CustomerModel>> updateCustomer({
    required int id,
    required String name,
    required String email,
    required String phonePrimary,
    String? gender,
    int? countryId,
    int? stateId,
    int? cityId,
    int? areaId,
    String? zipCode,
    String? address,
    String? latitude,
    String? longitude,
    int? mediaId,
    List<AttachmentDraft> attachments = const [],
    String? status,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.customer(id),
      fields: {
        '_method': 'PUT',
        ..._buildFields(
          name: name,
          email: email,
          phonePrimary: phonePrimary,
          gender: gender,
          countryId: countryId,
          stateId: stateId,
          cityId: cityId,
          areaId: areaId,
          zipCode: zipCode,
          address: address,
          latitude: latitude,
          longitude: longitude,
          mediaId: mediaId,
          attachments: attachments,
          status: status,
        ),
      },
    );
    return _mapSingleCustomer(response);
  }

  /// PUT /customers/{id}/status — toggles active/inactive.
  Future<ApiResponse<String>> changeCustomerStatus(int id) async {
    final response = await _network.put(
      endpoint: ApiPath.customerStatus(id),
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final status = response.data!['status']?.toString() ?? '';
    return ApiResponse.completed(status, message: response.message);
  }

  /// DELETE /customers/{id}
  Future<ApiResponse<void>> deleteCustomer(int id) async {
    final response = await _network.delete(endpoint: ApiPath.customer(id));
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  // ─── Geo helpers (country → state → city → area) ────────────────────────

  Future<ApiResponse<List<LookupOption>>> getCountries() async =>
      _getLookup(ApiPath.geoCountries);

  Future<ApiResponse<List<LookupOption>>> getStates(int countryId) async =>
      _getLookup(ApiPath.geoStates(countryId));

  Future<ApiResponse<List<LookupOption>>> getCities(int stateId) async =>
      _getLookup(ApiPath.geoCities(stateId));

  Future<ApiResponse<List<LookupOption>>> getAreas(int cityId) async =>
      _getLookup(ApiPath.geoAreas(cityId));

  Future<ApiResponse<List<LookupOption>>> _getLookup(String endpoint) async {
    final response = await _network.getRaw(endpoint: endpoint);
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
      );
    }
    final raw = response.data;
    final list = _extractList(raw);
    final options = list
        .whereType<Map>()
        .map((e) => LookupOption.fromJson(Map<String, dynamic>.from(e)))
        .where((o) => o.value.isNotEmpty)
        .toList();
    return ApiResponse.completed(options);
  }

  List _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      for (final key in ['data', 'countries', 'states', 'cities', 'areas']) {
        final inner = raw[key];
        if (inner is List) return inner;
      }
    }
    return const [];
  }

  Map<String, dynamic> _buildFields({
    required String name,
    required String email,
    required String phonePrimary,
    String? gender,
    int? countryId,
    int? stateId,
    int? cityId,
    int? areaId,
    String? zipCode,
    String? address,
    String? latitude,
    String? longitude,
    int? mediaId,
    List<AttachmentDraft> attachments = const [],
    String? status,
  }) {
    return {
      'name': name,
      'email': email,
      'phone_primary': phonePrimary,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (countryId != null) 'country_id': countryId,
      if (stateId != null) 'state_id': stateId,
      if (cityId != null) 'city_id': cityId,
      if (areaId != null) 'area_id': areaId,
      if (zipCode != null && zipCode.isNotEmpty) 'zip_code': zipCode,
      if (address != null && address.isNotEmpty) 'address': address,
      if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
      if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      if (mediaId != null) 'media_id': mediaId,
      if (status != null && status.isNotEmpty) 'status': status,
      for (var i = 0; i < attachments.length; i++) ...{
        'attachments[$i][title]': attachments[i].title,
        'attachments[$i][media_id]': attachments[i].mediaId,
      },
    };
  }

  ApiResponse<CustomerModel> _mapSingleCustomer(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['customer'] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    return ApiResponse.completed(
      CustomerModel.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }
}
