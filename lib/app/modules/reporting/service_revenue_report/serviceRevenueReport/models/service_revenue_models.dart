// lib/app/modules/service_revenue_report/models/service_revenue_models.dart

class BranchOption {
  final String label;
  final int value;

  BranchOption({required this.label, required this.value});

  factory BranchOption.fromJson(Map<String, dynamic> json) {
    return BranchOption(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class ServiceOption {
  final String label;
  final dynamic value; // can be "all" or int
  final String? defaultPrice;
  final String? type;
  final List<ServiceVariation>? variations;

  ServiceOption({
    required this.label,
    required this.value,
    this.defaultPrice,
    this.type,
    this.variations,
  });

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      label: json['label']?.toString() ?? '',
      value: json['value'], // can be "all" or int
      defaultPrice: json['default_price']?.toString(),
      type: json['type']?.toString(),
      variations: json['variations'] != null
          ? (json['variations'] as List)
              .map((v) => ServiceVariation.fromJson(v))
              .toList()
          : null,
    );
  }
}

class ServiceVariation {
  final int id;
  final String name;
  final String price;

  ServiceVariation({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ServiceVariation.fromJson(Map<String, dynamic> json) {
    return ServiceVariation(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
    );
  }
}

class ServiceRevenueData {
  final String branchName;
  final String from;
  final String to;
  final dynamic serviceId; // can be "all" or int
  final int branchId;
  final String totalAmount;
  final String totalDiscount;
  final String netRevenue;

  ServiceRevenueData({
    required this.branchName,
    required this.from,
    required this.to,
    required this.serviceId,
    required this.branchId,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
  });

  factory ServiceRevenueData.fromJson(Map<String, dynamic> json) {
    return ServiceRevenueData(
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      serviceId: json['service_id'],
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      totalDiscount: json['total_discount']?.toString() ?? '0',
      netRevenue: json['net_revenue']?.toString() ?? '0',
    );
  }
}

class ServiceRevenueResponse {
  final List<BranchOption> branches;
  final int? branchId;
  final String fromDate;
  final String toDate;
  final List<ServiceRevenueData> monthlyData;
  final List<ServiceOption> services;
  final dynamic serviceId;

  ServiceRevenueResponse({
    required this.branches,
    this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
    required this.services,
    this.serviceId,
  });

  factory ServiceRevenueResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRevenueResponse(
      branches: json['branches'] != null
          ? (json['branches'] as List)
              .map((b) => BranchOption.fromJson(b))
              .toList()
          : [],
      branchId: json['branch_id'] != null
          ? int.tryParse(json['branch_id'].toString())
          : null,
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData: json['monthlyData'] != null
          ? (json['monthlyData'] as List)
              .map((d) => ServiceRevenueData.fromJson(d))
              .toList()
          : [],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((s) => ServiceOption.fromJson(s))
              .toList()
          : [],
      serviceId: json['service_id'],
    );
  }
}