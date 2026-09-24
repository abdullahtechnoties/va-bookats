class BranchComparisonReportModel {
  final List<BranchFilterOption> branches;
  final List<int> branchIds;
  final String fromDate;
  final String toDate;
  final List<BranchComparisonItemModel> monthlyData;

  BranchComparisonReportModel({
    required this.branches,
    required this.branchIds,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
  });

  factory BranchComparisonReportModel.fromJson(Map<String, dynamic> json) {
    return BranchComparisonReportModel(
      branches:
          (json['branches'] as List?)
              ?.map(
                (e) => BranchFilterOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      branchIds:
          (json['branch_ids'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData:
          (json['monthlyData'] as List?)
              ?.map(
                (e) => BranchComparisonItemModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class BranchFilterOption {
  final String label;
  final int value;

  BranchFilterOption({required this.label, required this.value});

  factory BranchFilterOption.fromJson(Map<String, dynamic> json) {
    return BranchFilterOption(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value']?.toString() ?? '') ?? 0,
    );
  }
}

class BranchComparisonItemModel {
  final String totalAmount;
  final String totalDiscount;
  final String totalBalance;
  final String totalRevenue;
  final int totalCount;
  final int cashCount;
  final int cardCount;
  final int onlineCount;
  final String cashPayment;
  final String cardPayment;
  final String onlinePayment;
  final int unpaidCount;
  final String unpaidAmount;
  final int paidCount;
  final String serviceRevenue;
  final String productRevenue;
  final String packageRevenue;
  final String serviceDiscount;
  final String productDiscount;
  final String packageDiscount;
  final String serviceAmount;
  final String productAmount;
  final String packageAmount;
  final int totalServicesSold;
  final int totalProductsSold;
  final int totalPackagesSold;
  final String branchName;
  final String from;
  final String to;
  final int branchId;

  BranchComparisonItemModel({
    required this.totalAmount,
    required this.totalDiscount,
    required this.totalBalance,
    required this.totalRevenue,
    required this.totalCount,
    required this.cashCount,
    required this.cardCount,
    required this.onlineCount,
    required this.cashPayment,
    required this.cardPayment,
    required this.onlinePayment,
    required this.unpaidCount,
    required this.unpaidAmount,
    required this.paidCount,
    required this.serviceRevenue,
    required this.productRevenue,
    required this.packageRevenue,
    required this.serviceDiscount,
    required this.productDiscount,
    required this.packageDiscount,
    required this.serviceAmount,
    required this.productAmount,
    required this.packageAmount,
    required this.totalServicesSold,
    required this.totalProductsSold,
    required this.totalPackagesSold,
    required this.branchName,
    required this.from,
    required this.to,
    required this.branchId,
  });

  factory BranchComparisonItemModel.fromJson(Map<String, dynamic> json) {
    return BranchComparisonItemModel(
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      totalDiscount: json['total_discount']?.toString() ?? '0.00',
      totalBalance: json['total_balance']?.toString() ?? '0.00',
      totalRevenue: json['total_revenue']?.toString() ?? '0.00',
      totalCount: json['total_count'] as int? ?? 0,
      cashCount: json['cash_count'] as int? ?? 0,
      cardCount: json['card_count'] as int? ?? 0,
      onlineCount: json['online_count'] as int? ?? 0,
      cashPayment: json['cash_payment']?.toString() ?? '0.00',
      cardPayment: json['card_payment']?.toString() ?? '0.00',
      onlinePayment: json['online_payment']?.toString() ?? '0.00',
      unpaidCount: json['unpaid_count'] as int? ?? 0,
      unpaidAmount: json['unpaid_amount']?.toString() ?? '0.00',
      paidCount: json['paid_count'] as int? ?? 0,
      serviceRevenue: json['service_revenue']?.toString() ?? '0.00',
      productRevenue: json['product_revenue']?.toString() ?? '0.00',
      packageRevenue: json['package_revenue']?.toString() ?? '0.00',
      serviceDiscount: json['service_discount']?.toString() ?? '0.00',
      productDiscount: json['product_discount']?.toString() ?? '0.00',
      packageDiscount: json['package_discount']?.toString() ?? '0.00',
      serviceAmount: json['service_amount']?.toString() ?? '0.00',
      productAmount: json['product_amount']?.toString() ?? '0.00',
      packageAmount: json['package_amount']?.toString() ?? '0.00',
      totalServicesSold: json['total_services_sold'] as int? ?? 0,
      totalProductsSold: json['total_products_sold'] as int? ?? 0,
      totalPackagesSold: json['total_packages_sold'] as int? ?? 0,
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      branchId: json['branch_id'] as int? ?? 0,
    );
  }
}
