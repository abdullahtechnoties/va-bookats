class BranchFilterOption {
  final String label;
  final int value;

  BranchFilterOption({required this.label, required this.value});

  factory BranchFilterOption.fromJson(Map<String, dynamic> json) {
    return BranchFilterOption(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value']?.toString() ?? '0') ?? 0,
    );
  }
}

class PackageFilterOption {
  final String label;
  final dynamic value;
  final String? price;

  PackageFilterOption({required this.label, required this.value, this.price});

  factory PackageFilterOption.fromJson(Map<String, dynamic> json) {
    return PackageFilterOption(
      label: json['label']?.toString() ?? '',
      value: json['value'],
      price: json['price']?.toString(),
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
  final String? currencySymbol;

  /// Every raw field from the API row, so report columns can be discovered
  /// dynamically (unknown future keys included).
  final Map<String, dynamic> rawFields;

  MonthlyPackageData({
    required this.branchName,
    required this.from,
    required this.to,
    required this.packageId,
    required this.branchId,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
    this.currencySymbol,
    Map<String, dynamic>? rawFields,
  }) : rawFields = rawFields ?? const {};

  factory MonthlyPackageData.fromJson(Map<String, dynamic> json) {
    return MonthlyPackageData(
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      packageId: json['package_id'],
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      totalAmount: _parseNum(json['total_amount']),
      totalDiscount: _parseNum(json['total_discount']),
      netRevenue: _parseNum(json['net_revenue']),
      currencySymbol: json['currency_symbol']?.toString(),
      rawFields: Map<String, dynamic>.from(json),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
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
      branches:
          (json['branches'] as List?)
              ?.map(
                (e) => BranchFilterOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData:
          (json['monthlyData'] as List?)
              ?.map(
                (e) => MonthlyPackageData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      packages:
          (json['packages'] as List?)
              ?.map(
                (e) => PackageFilterOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      packageId: json['package_id'],
    );
  }
}
