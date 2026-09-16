class CommissionsReportResponse {
  final List<DropdownOption> branches;
  final List<DropdownOption> staffs;
  final int? branchId;
  final String? staffId;
  final String fromDate;
  final String toDate;
  final List<CommissionMonthlyData> monthlyData;

  CommissionsReportResponse({
    required this.branches,
    required this.staffs,
    this.branchId,
    this.staffId,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
  });

  factory CommissionsReportResponse.fromJson(Map<String, dynamic> json) {
    return CommissionsReportResponse(
      branches: (json['branches'] as List?)
              ?.map((e) => DropdownOption.fromJson(e))
              .toList() ??
          [],
      staffs: (json['staffs'] as List?)
              ?.map((e) => DropdownOption.fromJson(e))
              .toList() ??
          [],
      branchId: _parseInt(json['branch_id']),
      staffId: json['staff_id']?.toString(),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData: (json['monthlyData'] as List?)
              ?.map((e) => CommissionMonthlyData.fromJson(e))
              .toList() ??
          [],
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

class CommissionMonthlyData {
  final String branchName;
  final String from;
  final String to;
  final String staffId;
  final int branchId;
  final int totalServices;
  final int totalPackages;
  final String serviceCommission;
  final String packageCommission;
  final String totalCommission;

  CommissionMonthlyData({
    required this.branchName,
    required this.from,
    required this.to,
    required this.staffId,
    required this.branchId,
    required this.totalServices,
    required this.totalPackages,
    required this.serviceCommission,
    required this.packageCommission,
    required this.totalCommission,
  });

  factory CommissionMonthlyData.fromJson(Map<String, dynamic> json) {
    return CommissionMonthlyData(
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      staffId: json['staff_id']?.toString() ?? '',
      branchId: _parseInt(json['branch_id']) ?? 0,
      totalServices: _parseInt(json['total_services']) ?? 0,
      totalPackages: _parseInt(json['total_packages']) ?? 0,
      serviceCommission: json['service_commission']?.toString() ?? '0',
      packageCommission: json['package_commission']?.toString() ?? '0',
      totalCommission: json['total_commission']?.toString() ?? '0',
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class DropdownOption {
  final String label;
  final dynamic value;

  DropdownOption({required this.label, required this.value});

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      label: json['label']?.toString() ?? '',
      value: json['value'],
    );
  }
}

class CommissionsColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  CommissionsColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });
}