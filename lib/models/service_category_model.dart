import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// A service category, as returned by the service-categories endpoints:
///
/// ```json
/// {
///   "id": 1,
///   "name": "Hair Care",
///   "branch_id": 1,
///   "status": "active",
///   "branch": { "id": 1, "name": "Branch" }
/// }
/// ```
///
/// Every field is parsed defensively so partial payloads never crash the app.
class ServiceCategoryModel {
  final int? id;
  final String? name;
  final int? branchId;
  final String? status;
  final BranchModel? branch;

  const ServiceCategoryModel({
    this.id,
    this.name,
    this.branchId,
    this.status,
    this.branch,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawBranch = json['branch'];

    return ServiceCategoryModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      branchId: _parseInt(json['branch_id']),
      status: json['status']?.toString(),
      branch: rawBranch is Map
          ? BranchModel.fromJson(Map<String, dynamic>.from(rawBranch))
          : null,
    );
  }

  bool get isActive => status?.toLowerCase() == 'active';

  String get branchName => branch?.label ?? '';

  String get statusDisplay =>
      isActive ? 'serviceCategories.active'.trns() : 'serviceCategories.inactive'.trns();

  ServiceCategoryModel copyWith({String? status}) {
    return ServiceCategoryModel(
      id: id,
      name: name,
      branchId: branchId,
      status: status ?? this.status,
      branch: branch,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
