class BranchFilterOption {
  final String label;
  final int value;

  BranchFilterOption({required this.label, required this.value});

  factory BranchFilterOption.fromJson(Map<String, dynamic> json) {
    return BranchFilterOption(
      label: json['label'] as String? ?? '',
      value: json['value'] as int? ?? 0,
    );
  }
}

class PackageFilterOption {
  final String label;
  final dynamic value;
  final String? price;

  PackageFilterOption({
    required this.label,
    required this.value,
    this.price,
  });

  factory PackageFilterOption.fromJson(Map<String, dynamic> json) {
    return PackageFilterOption(
      label: json['label'] as String? ?? '',
      value: json['value'],
      price: json['price'] as String?,
    );
  }
}

class MonthlyPackageData {
  final String branchName;
  final String from;
  final String to;
  final dynamic packageId;
  final int branchId;
  final num totalAmount;
  final num totalDiscount;
  final num netRevenue;

  MonthlyPackageData({
    required this.branchName,
    required this.from,
    required this.to,
    required this.packageId,
    required this.branchId,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
  });

  factory MonthlyPackageData.fromJson(Map<String, dynamic> json) {
    return MonthlyPackageData(
      branchName: json['branch_name'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      packageId: json['package_id'],
      branchId: json['branch_id'] as int? ?? 0,
      totalAmount: (json['total_amount'] is String)
          ? num.tryParse(json['total_amount']) ?? 0
          : json['total_amount'] as num? ?? 0,
      totalDiscount: (json['total_discount'] is String)
          ? num.tryParse(json['total_discount']) ?? 0
          : json['total_discount'] as num? ?? 0,
      netRevenue: (json['net_revenue'] is String)
          ? num.tryParse(json['net_revenue']) ?? 0
          : json['net_revenue'] as num? ?? 0,
    );
  }
}

class PackageRevenueReportModel {
  final List<BranchFilterOption> branches;
  final int branchId;
  final String fromDate;
  final String toDate;
  final List<MonthlyPackageData> monthlyData;
  final List<PackageFilterOption> packages;
  final dynamic packageId;

  PackageRevenueReportModel({
    required this.branches,
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
    required this.packages,
    required this.packageId,
  });

  factory PackageRevenueReportModel.fromJson(Map<String, dynamic> json) {
    return PackageRevenueReportModel(
      branches: (json['branches'] as List?)
              ?.map((e) =>
                  BranchFilterOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branchId: json['branch_id'] as int? ?? 0,
      fromDate: json['from_date'] as String? ?? '',
      toDate: json['to_date'] as String? ?? '',
      monthlyData: (json['monthlyData'] as List?)
              ?.map((e) =>
                  MonthlyPackageData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      packages: (json['packages'] as List?)
              ?.map((e) =>
                  PackageFilterOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      packageId: json['package_id'],
    );
  }
}