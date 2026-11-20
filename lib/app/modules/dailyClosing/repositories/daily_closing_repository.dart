// lib/app/modules/dailyClosing/repositories/daily_closing_repository.dart
//
// API layer for daily closings — mirrors the patterns used by
// CustomerRepository (paginated list + typed ApiResponse + lookups).

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Detail tab sections that carry their own `*_page` query parameter.
enum ClosingSection {
  activities('activities_page'),
  bookings('bookings_page'),
  payments('payments_page'),
  staffCommissions('staffs_page'),
  expenses('expenses_page'),
  services('services_page'),
  products('products_page'),
  packages('packages_page'),
  cashFlow('cashflow_page');

  const ClosingSection(this.pageParam);
  final String pageParam;
}

class DailyClosingRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /daily-closings — paginated + server-side filters.
  Future<ApiResponse<DailyClosingsPage>> getDailyClosings({
    int page = 1,
    int? branchId,
    String? search,
    String? status,
    String? fromDate,
    String? toDate,
    String? quickRange,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.dailyClosings,
      queryParams: {
        'page': page,
        if (branchId != null) 'branch_id': branchId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        if (quickRange != null && quickRange.isNotEmpty)
          'quick_range': quickRange,
      },
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final paginator = body['dailyClosings'];
    final map = paginator is Map
        ? Map<String, dynamic>.from(paginator)
        : <String, dynamic>{};
    final rawList = map['data'];
    final items = rawList is List
        ? rawList
              .whereType<Map>()
              .map(
                (e) => DailyClosingModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .where((c) => c.id != 0)
              .toList()
        : <DailyClosingModel>[];

    final today = body['today'] is Map
        ? TodayClosing.fromJson(Map<String, dynamic>.from(body['today'] as Map))
        : null;

    return ApiResponse.completed(
      DailyClosingsPage(
        items: items,
        meta: PaginationMeta.fromJson(map),
        today: today,
        branchId: closingInt(body['branch_id']),
      ),
      message: response.message,
    );
  }

  /// GET /daily-closings/{id}
  ///
  /// Each tab is a separate paginator. Pass [section] + [page] to append a
  /// single section (used by the "Load more" buttons); leave both null for
  /// the initial load that returns page 1 of every section.
  Future<ApiResponse<DailyClosingDetail>> getDetail(
    int id, {
    ClosingSection? section,
    int page = 1,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.dailyClosing(id),
      queryParams: {if (section != null) section.pageParam: page},
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawClosing = body['dailyClosing'];
    if (rawClosing is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    final closing = DailyClosingModel.fromJson(
      Map<String, dynamic>.from(rawClosing),
    );

    final activities = _rawItems(
      body['activities'],
    ).map(ClosingActivity.fromJson).toList();

    final cash = body['cashFlowSummary'];
    final cashMap = cash is Map ? cash : const {};

    return ApiResponse.completed(
      DailyClosingDetail(
        closing: closing,
        activities: activities,
        bookings: _rawSection(body['bookings']),
        payments: _rawSection(body['payments']),
        staffCommissions: _rawSection(body['staffCommissions']),
        expenses: _rawSection(body['expenses']),
        serviceSummary: _rawSection(body['serviceSummary']),
        productSummary: _rawSection(body['productSummary']),
        packageSummary: _rawSection(body['packageSummary']),
        cashFlow: _rawSection(body['cashFlow']),
        cashIn: closingString(cashMap['total_in'], '0'),
        cashOut: closingString(cashMap['total_out'], '0'),
        cashNet: closingString(cashMap['net'], '0'),
      ),
      message: response.message,
    );
  }

  /// POST /daily-closings
  /// body: branch_id, date (`yyyy/MM/dd`), opening_balance
  Future<ApiResponse<DailyClosingModel>> create({
    required int branchId,
    required String date,
    required String openingBalance,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.dailyClosings,
      fields: {
        'branch_id': branchId,
        'date': date,
        'opening_balance': openingBalance,
      },
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['daily_closing'];
    final model = raw is Map
        ? DailyClosingModel.fromJson(Map<String, dynamic>.from(raw))
        : DailyClosingModel(id: 0);
    return ApiResponse.completed(model, message: response.message);
  }

  /// PUT /daily-closings/{id}/status — Pending ⇄ Approved.
  Future<ApiResponse<String>> changeStatus(int id) async {
    final response = await _network.put(
      endpoint: ApiPath.dailyClosingStatus(id),
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(
      response.data!['status']?.toString() ?? '',
      message: response.message,
    );
  }

  /// GET /daily-closings/today?branch_id=N
  Future<ApiResponse<TodayClosing>> getToday(int branchId) async {
    final response = await _network.get(
      endpoint: ApiPath.dailyClosingToday(branchId: branchId),
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(TodayClosing.fromJson(response.data!));
  }

  /// GET /data/branches — owner-only branch selector source.
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

  // ─── Parsing helpers ─────────────────────────────────────────────────────

  RawSection _rawSection(dynamic raw) {
    final Map<String, dynamic> map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    return RawSection(
      items: _rawItems(raw),
      meta: PaginationMeta.fromJson(
        map.isEmpty
            ? {'current_page': 1, 'last_page': 1, 'total': 0, 'per_page': 10}
            : map,
      ),
    );
  }

  List<Map<String, dynamic>> _rawItems(dynamic raw) {
    if (raw is! Map) return const [];
    final list = raw['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
