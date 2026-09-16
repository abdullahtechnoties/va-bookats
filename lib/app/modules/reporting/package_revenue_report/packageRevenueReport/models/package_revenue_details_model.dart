import 'package:va_bookats/network/response/pagination_helper.dart';

class BranchInfoModel {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? emailSecondary;
  final String? phonePrimary;
  final String? phoneSecondary;
  final String? address;

  BranchInfoModel({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.emailSecondary,
    this.phonePrimary,
    this.phoneSecondary,
    this.address,
  });

  factory BranchInfoModel.fromJson(Map<String, dynamic> json) {
    return BranchInfoModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      emailPrimary: json['email_primary'] as String?,
      emailSecondary: json['email_secondary'] as String?,
      phonePrimary: json['phone_primary'] as String?,
      phoneSecondary: json['phone_secondary'] as String?,
      address: json['address'] as String?,
    );
  }
}

class PackageInfoInSummary {
  final int id;
  final String name;
  final String price;

  PackageInfoInSummary({
    required this.id,
    required this.name,
    required this.price,
  });

  factory PackageInfoInSummary.fromJson(Map<String, dynamic> json) {
    return PackageInfoInSummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '0',
    );
  }
}

class DailyPackageSummary {
  final int id;
  final int dailyClosingId;
  final int packageId;
  final int totalCustomers;
  final int totalQty;
  final String packageAmount;
  final String totalAmount;
  final String totalDiscount;
  final String netRevenue;
  final String createdAt;
  final PackageInfoInSummary? package;

  DailyPackageSummary({
    required this.id,
    required this.dailyClosingId,
    required this.packageId,
    required this.totalCustomers,
    required this.totalQty,
    required this.packageAmount,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
    required this.createdAt,
    this.package,
  });

  factory DailyPackageSummary.fromJson(Map<String, dynamic> json) {
    return DailyPackageSummary(
      id: json['id'] as int? ?? 0,
      dailyClosingId: json['daily_closing_id'] as int? ?? 0,
      packageId: json['package_id'] as int? ?? 0,
      totalCustomers: json['total_customers'] as int? ?? 0,
      totalQty: json['total_qty'] as int? ?? 0,
      packageAmount: json['package_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      totalDiscount: json['total_discount']?.toString() ?? '0',
      netRevenue: json['net_revenue']?.toString() ?? '0',
      createdAt: json['created_at'] as String? ?? '',
      package: json['package'] != null
          ? PackageInfoInSummary.fromJson(
              json['package'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PackageRevenueDetailsModel {
  final BranchInfoModel branch;
  final String fromDate;
  final String toDate;
  final String packageName;
  final PaginatedResult<DailyPackageSummary> dailyPackageSummaries;
  final dynamic packageId;

  PackageRevenueDetailsModel({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.packageName,
    required this.dailyPackageSummaries,
    required this.packageId,
  });

  factory PackageRevenueDetailsModel.fromJson(Map<String, dynamic> json) {
    final summariesJson =
        json['dailyPackageSummaries'] as Map<String, dynamic>? ?? {};

    final items = (summariesJson['data'] as List?)
            ?.map((e) =>
                DailyPackageSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final meta = PaginationMeta.fromJson(summariesJson);

    return PackageRevenueDetailsModel(
      branch: BranchInfoModel.fromJson(
          json['branch'] as Map<String, dynamic>? ?? {}),
      fromDate: json['from_date'] as String? ?? '',
      toDate: json['to_date'] as String? ?? '',
      packageName: json['package_name'] as String? ?? 'All Packages',
      dailyPackageSummaries: PaginatedResult(items: items, meta: meta),
      packageId: json['package_id'],
    );
  }
}