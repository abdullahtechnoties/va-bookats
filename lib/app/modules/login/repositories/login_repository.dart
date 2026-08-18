// lib/app/modules/login/repositories/login_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/login_response_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Repository pattern wrapper around the auth/login network call.
/// Controllers never touch [NetworkService] directly — they go through here.
class LoginRepository {
  final NetworkService _network = Get.find<NetworkService>();
  final AuthService _auth = Get.find<AuthService>();

  /// Sends the login request.
  ///
  /// [login] accepts either an email or a phone number — the API decides.
  /// The [companyId] is attached to the request body (`X-Company_Id`) and is
  /// also pushed into [AuthService] so the global interceptor attaches the
  /// `X-Company-Id` header automatically.
  Future<ApiResponse<LoginResponse>> login({
    required String login,
    required String password,
    required String companyId,
  }) async {
    // Expose the company id so the network interceptor adds X-Company-Id.
    await _auth.setCompanyId(companyId);

    final response = await _network.post(
      endpoint: ApiPath.login,
      body: {
        'login': login,
        'password': password,
        'X-Company_Id': companyId,
      },
    );

    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final data = response.data;
    if (data == null) {
      return ApiResponse.error('errors.emptyResponse');
    }

    return ApiResponse.completed(
      LoginResponse.fromJson(data),
      message: response.message,
    );
  }
}
