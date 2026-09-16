// lib/app/modules/personalInfo/repositories/profile_repository.dart

import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/models/user_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Repository for profile update, change password, and geo helpers.
class ProfileRepository {
  final NetworkService _network = Get.find<NetworkService>();

  // ─── Update Profile ─────────────────────────────────────────────────────

  /// Calls `POST /profile` with `_method: PUT` (Laravel-style spoofing).
  Future<ApiResponse<UserModel>> updateProfile({
    required String name,
    required String email,
    String? emailSecondary,
    String? phonePrimary,
    String? phoneSecondary,
    String? dateOfBirth,
    String? qualification,
    int? countryId,
    int? stateId,
    int? cityId,
    int? areaId,
    String? zipCode,
    String? address,
    String? latitude,
    String? longitude,
    int? mediaId,
    int? nicFrontMediaId,
    int? nicBackMediaId,
  }) async {
    final body = <String, dynamic>{
      '_method': 'PUT',
      'name': name,
      'email': email,
      if (emailSecondary != null) 'email_secondary': emailSecondary,
      if (phonePrimary != null) 'phone_primary': phonePrimary,
      if (phoneSecondary != null) 'phone_secondary': phoneSecondary,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (qualification != null) 'qualification': qualification,
      if (countryId != null) 'country_id': countryId,
      if (stateId != null) 'state_id': stateId,
      if (cityId != null) 'city_id': cityId,
      if (areaId != null) 'area_id': areaId,
      if (zipCode != null) 'zip_code': zipCode,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (mediaId != null) 'media_id': mediaId,
      if (nicFrontMediaId != null) 'nic_front_media_id': nicFrontMediaId,
      if (nicBackMediaId != null) 'nic_back_media_id': nicBackMediaId,
    };

    final response = await _network.post(
      endpoint: ApiPath.profile,
      body: body,
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final userData = response.data!['user'];
    if (userData == null || userData is! Map) {
      return ApiResponse.error('errors.emptyResponse'.trns());
    }

    return ApiResponse.completed(
      UserModel.fromJson(Map<String, dynamic>.from(userData)),
      message: response.message,
    );
  }

  // ─── Change Password ────────────────────────────────────────────────────

  /// Calls `POST /change-password` with `_method: PUT`.
  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.changePassword,
      body: {
        '_method': 'PUT',
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );

    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    return ApiResponse.completed(
      response.message ?? 'Password updated successfully.',
      message: response.message,
    );
  }

  // ─── Geo helpers (country → state → city → area) ────────────────────────

  Future<ApiResponse<List<LookupOption>>> getCountries() async =>
      _getLookup(ApiPath.countries);

  Future<ApiResponse<List<LookupOption>>> getStates(int countryId) async =>
      _getLookup(ApiPath.countryStates(countryId));

  Future<ApiResponse<List<LookupOption>>> getCities(int stateId) async =>
      _getLookup(ApiPath.stateCities(stateId));

  Future<ApiResponse<List<LookupOption>>> getAreas(int cityId) async =>
      _getLookup(ApiPath.cityAreas(cityId));

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
}
