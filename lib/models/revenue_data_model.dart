class RevenueData {
  final double totalAmount;
  final double totalDiscount;
  final double totalBalance;
  final double totalRevenue;
  final int totalCount;
  final int cashCount;
  final int cardCount;
  final int onlineCount;
  final double cashPayment;
  final double cardPayment;
  final double onlinePayment;
  final int unpaidCount;
  final double unpaidAmount;
  final int returnCount;
  final double returnAmount;
  final int paidCount;
  final double serviceRevenue;
  final double productRevenue;
  final double packageRevenue;
  final double serviceDiscount;
  final double productDiscount;
  final double packageDiscount;
  final double serviceAmount;
  final double productAmount;
  final double packageAmount;
  final int totalServicesSold;
  final int totalProductsSold;
  final int totalPackagesSold;
  final String branchName;
  final String from;
  final String to;
  final int branchId;

  RevenueData({
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
    required this.returnCount,
    required this.returnAmount,
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

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      totalAmount: _parseDouble(json['total_amount']),
      totalDiscount: _parseDouble(json['total_discount']),
      totalBalance: _parseDouble(json['total_balance']),
      totalRevenue: _parseDouble(json['total_revenue']),
      totalCount: _parseInt(json['total_count']),
      cashCount: _parseInt(json['cash_count']),
      cardCount: _parseInt(json['card_count']),
      onlineCount: _parseInt(json['online_count']),
      cashPayment: _parseDouble(json['cash_payment']),
      cardPayment: _parseDouble(json['card_payment']),
      onlinePayment: _parseDouble(json['online_payment']),
      unpaidCount: _parseInt(json['unpaid_count']),
      unpaidAmount: _parseDouble(json['unpaid_amount']),
      returnCount: _parseInt(json['return_count']),
      returnAmount: _parseDouble(json['return_amount']),
      paidCount: _parseInt(json['paid_count']),
      serviceRevenue: _parseDouble(json['service_revenue']),
      productRevenue: _parseDouble(json['product_revenue']),
      packageRevenue: _parseDouble(json['package_revenue']),
      serviceDiscount: _parseDouble(json['service_discount']),
      productDiscount: _parseDouble(json['product_discount']),
      packageDiscount: _parseDouble(json['package_discount']),
      serviceAmount: _parseDouble(json['service_amount']),
      productAmount: _parseDouble(json['product_amount']),
      packageAmount: _parseDouble(json['package_amount']),
      totalServicesSold: _parseInt(json['total_services_sold']),
      totalProductsSold: _parseInt(json['total_products_sold']),
      totalPackagesSold: _parseInt(json['total_packages_sold']),
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      branchId: _parseInt(json['branch_id']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}