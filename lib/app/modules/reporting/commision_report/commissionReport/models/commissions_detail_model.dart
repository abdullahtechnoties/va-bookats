import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';

class CommissionsDetailResponse {
  final BranchInfo branch;
  final String fromDate;
  final String toDate;
  final String staffName;
  final String? staffId;
  final PaginatedResult<StaffCommissionSummary> dailyStaffCommissionSummaries;

  CommissionsDetailResponse({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.staffName,
    this.staffId,
    required this.dailyStaffCommissionSummaries,
  });

  factory CommissionsDetailResponse.fromJson(Map<String, dynamic> json) {
    final summariesData =
        json['dailyStaffCommissionSummaries'] as Map<String, dynamic>? ?? {};
    final items =
        (summariesData['data'] as List?)
            ?.map((e) => StaffCommissionSummary.fromJson(e))
            .toList() ??
        [];
    final meta = PaginationMeta.fromJson(summariesData);

    return CommissionsDetailResponse(
      branch: BranchInfo.fromJson(json['branch'] ?? {}),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      staffId: json['staff_id']?.toString(),
      dailyStaffCommissionSummaries: PaginatedResult(items: items, meta: meta),
    );
  }
}

class BranchInfo {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? phonePrimary;
  final String? address;

  BranchInfo({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.phonePrimary,
    this.address,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      address: json['address']?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

class StaffCommissionSummary {
  final int id;
  final int staffId;
  final int totalServices;
  final int totalPackages;
  final String serviceCommission;
  final String packageCommission;
  final String totalCommission;
  final StaffInfo? staff;

  StaffCommissionSummary({
    required this.id,
    required this.staffId,
    required this.totalServices,
    required this.totalPackages,
    required this.serviceCommission,
    required this.packageCommission,
    required this.totalCommission,
    this.staff,
  });

  factory StaffCommissionSummary.fromJson(Map<String, dynamic> json) {
    return StaffCommissionSummary(
      id: _parseInt(json['id']) ?? 0,
      staffId: _parseInt(json['staff_id']) ?? 0,
      totalServices: _parseInt(json['total_services']) ?? 0,
      totalPackages: _parseInt(json['total_packages']) ?? 0,
      serviceCommission: json['service_commission']?.toString() ?? '0.00',
      packageCommission: json['package_commission']?.toString() ?? '0.00',
      totalCommission: json['total_commission']?.toString() ?? '0.00',
      staff: json['staff'] != null ? StaffInfo.fromJson(json['staff']) : null,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class StaffInfo {
  final int id;
  final String name;
  final String? email;
  final String? phonePrimary;
  final String? imageUrl;

  StaffInfo({
    required this.id,
    required this.name,
    this.email,
    this.phonePrimary,
    this.imageUrl,
  });

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    return StaffInfo(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
