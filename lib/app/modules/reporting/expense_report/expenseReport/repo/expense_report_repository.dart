import 'package:get/get.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import '../models/expense_category_model.dart';
import '../models/expense_report_response_model.dart';
import '../models/expense_detail_response_model.dart';

class ExpenseReportRepository {
  final NetworkService _network = Get.find<NetworkService>();

  Future<ApiResponse<ExpenseReportResponseModel>> fetchExpenseReport({
    List<String>? branchIds,
    List<String>? expenseCategoryIds,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
      };
      if (branchIds != null) {
        addIndexedParams(queryParams, 'branch_ids', branchIds);
      }
      if (expenseCategoryIds != null) {
        addIndexedParams(
          queryParams,
          'expenseCategory_ids',
          expenseCategoryIds,
        );
      }
      final response = await _network.get(
        endpoint: ApiPath.expenseReport,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final model = ExpenseReportResponseModel.fromJson(response.data!);
        return ApiResponse.completed(model);
      }

      return ApiResponse.error(response.message ?? 'errors.fetchFailed'.trns());
    } catch (e) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }

  Future<ApiResponse<List<ExpenseCategoryModel>>> fetchExpenseCategories({
    required String branchId,
  }) async {
    try {
      final response = await _network.getRaw(
        endpoint: ApiPath.expenseCategories(int.parse(branchId)),
      );
      if (response.isCompleted && response.data != null) {
        final raw = response.data;
        final list = raw is List
            ? raw
            : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
        return ApiResponse.completed(
          list
              .whereType<Map>()
              .map(
                (e) => ExpenseCategoryModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
        );
      }
      return ApiResponse.error(response.message ?? 'errors.fetchFailed'.trns());
    } catch (_) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }

  Future<ApiResponse<ExpenseDetailResponseModel>> fetchExpenseDetails({
    required int branchId,
    required String expenseCategoryId,
    required String fromDate,
    required String toDate,
    int page = 1,
  }) async {
    try {
      final response = await _network.get(
        endpoint: ApiPath.expenseReportDetails(
          branchId: branchId,
          expenseCategoryId: expenseCategoryId,
          fromDate: fromDate,
          toDate: toDate,
          page: page,
        ),
      );

      if (response.isCompleted && response.data != null) {
        final model = ExpenseDetailResponseModel.fromJson(response.data!);
        return ApiResponse.completed(model);
      }

      return ApiResponse.error(response.message ?? 'errors.fetchFailed'.trns());
    } catch (e) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }
}
