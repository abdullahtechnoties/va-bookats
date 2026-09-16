// lib/app/modules/service_revenue_report/models/service_revenue_detail_models.dart

import 'package:va_bookats/network/response/pagination_helper.dart';

class BranchDetail {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? emailSecondary;
  final String? phonePrimary;
  final String? phoneSecondary;
  final String? address;

  BranchDetail({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.emailSecondary,
    this.phonePrimary,
    this.phoneSecondary,
    this.address,
  });

  factory BranchDetail.fromJson(Map<String, dynamic> json) {
    return BranchDetail(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      emailSecondary: json['email_secondary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      phoneSecondary: json['phone_secondary']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class ServiceInfo {
  final int id;
  final String name;
  final String? serviceUrl;
  final String? serviceThumbUrl;

  ServiceInfo({
    required this.id,
    required this.name,
    this.serviceUrl,
    this.serviceThumbUrl,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      serviceUrl: json['service_url']?.toString(),
      serviceThumbUrl: json['service_thumb_url']?.toString(),
    );
  }
}

class DailyServiceSummary {
  final int id;
  final int dailyClosingId;
  final int serviceId;
  final int totalCustomers;
  final String serviceAmount;
  final String totalAmount;
  final String totalDiscount;
  final String netRevenue;
  final String createdAt;
  final ServiceInfo? service;

  DailyServiceSummary({
    required this.id,
    required this.dailyClosingId,
    required this.serviceId,
    required this.totalCustomers,
    required this.serviceAmount,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
    required this.createdAt,
    this.service,
  });

  factory DailyServiceSummary.fromJson(Map<String, dynamic> json) {
    return DailyServiceSummary(
      id: int.tryParse(json['id'].toString()) ?? 0,
      dailyClosingId: int.tryParse(json['daily_closing_id'].toString()) ?? 0,
      serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
      totalCustomers: int.tryParse(json['total_customers'].toString()) ?? 0,
      serviceAmount: json['service_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      totalDiscount: json['total_discount']?.toString() ?? '0',
      netRevenue: json['net_revenue']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '',
      service: json['service'] != null
          ? ServiceInfo.fromJson(json['service'])
          : null,
    );
  }
}

class ServiceRevenueDetailResponse {
  final BranchDetail branch;
  final String fromDate;
  final String toDate;
  final String serviceName;
  final PaginatedResult<DailyServiceSummary> dailyServiceSummaries;
  final dynamic serviceId;

  ServiceRevenueDetailResponse({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.serviceName,
    required this.dailyServiceSummaries,
    this.serviceId,
  });

  factory ServiceRevenueDetailResponse.fromJson(Map<String, dynamic> json) {
    final summariesJson = json['dailyServiceSummaries'] as Map<String, dynamic>? ?? {};
    final data = (summariesJson['data'] as List?)
            ?.map((item) => DailyServiceSummary.fromJson(item))
            .toList() ??
        [];

    final meta = PaginationMeta.fromJson(summariesJson);

    return ServiceRevenueDetailResponse(
      branch: BranchDetail.fromJson(json['branch'] ?? {}),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      dailyServiceSummaries: PaginatedResult(items: data, meta: meta),
      serviceId: json['service_id'],
    );
  }
}