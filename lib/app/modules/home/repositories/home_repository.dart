// lib/app/modules/home/repositories/home_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/home/models/home_charts_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class HomeRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /charts — booking counts + revenue graph points.
  /// Callers hide these sections gracefully when the call fails.
  Future<ApiResponse<HomeChartsData>> getCharts() async {
    try {
      final response = await _network.get(endpoint: ApiPath.charts);

      if (response.isCompleted && response.data != null) {
        return ApiResponse.completed(
          HomeChartsData.fromJson(response.data!),
          message: response.message,
        );
      }

      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    } catch (_) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }
}
