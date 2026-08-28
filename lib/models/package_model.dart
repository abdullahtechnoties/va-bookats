import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// A package service line — links a service (and optionally a variation) to a
/// package. Returned by GET /packages/{id} inside `package_services`.
class PackageServiceModel {
  final int? id;
  final int? packageId;
  final int? serviceId;
  final int? variationId;
  final String? serviceName;
  final String? serviceDefaultPrice;
  final String? variationName;
  final String? variationPrice;

  const PackageServiceModel({
    this.id,
    this.packageId,
    this.serviceId,
    this.variationId,
    this.serviceName,
    this.serviceDefaultPrice,
    this.variationName,
    this.variationPrice,
  });

  factory PackageServiceModel.fromJson(Map<String, dynamic> json) {
    final rawService = json['service'];
    final rawVariation = json['variation'];
    return PackageServiceModel(
      id: _parseInt(json['id']),
      packageId: _parseInt(json['package_id']),
      serviceId: _parseInt(json['service_id']),
      variationId: _parseInt(json['variation_id']),
      serviceName: rawService is Map ? rawService['name']?.toString() : null,
      serviceDefaultPrice:
          rawService is Map ? rawService['default_price']?.toString() : null,
      variationName:
          rawVariation is Map ? rawVariation['name']?.toString() : null,
      variationPrice:
          rawVariation is Map ? rawVariation['price']?.toString() : null,
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

/// A service package, as returned by the packages endpoints.
///
/// The list endpoint returns a slim shape; the single-package GET adds
/// `description`, `starting_from`, `ending_on` and `package_services`.
///
/// Every field is parsed defensively so partial payloads never crash the app.
class PackageModel {
  final int? id;
  final String? name;
  final int? branchId;
  final String? status;
  final String? price;
  final String? description;
  final String? startingFrom;
  final String? endingOn;
  final BranchModel? branch;
  final List<PackageServiceModel> packageServices;

  const PackageModel({
    this.id,
    this.name,
    this.branchId,
    this.status,
    this.price,
    this.description,
    this.startingFrom,
    this.endingOn,
    this.branch,
    this.packageServices = const [],
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final rawBranch = json['branch'];
    final rawPs = json['package_services'];

    return PackageModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      branchId: _parseInt(json['branch_id']),
      status: json['status']?.toString(),
      price: json['price']?.toString(),
      description: json['description']?.toString(),
      startingFrom: json['starting_from']?.toString(),
      endingOn: json['ending_on']?.toString(),
      branch: rawBranch is Map
          ? BranchModel.fromJson(Map<String, dynamic>.from(rawBranch))
          : null,
      packageServices: rawPs is List
          ? rawPs
                .whereType<Map>()
                .map(
                  (e) => PackageServiceModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get isActive => status?.toLowerCase() == 'active';

  String get branchName => branch?.label ?? '';

  String get statusDisplay =>
      isActive ? 'packages.card.active'.trns() : 'packages.card.inactive'.trns();

  String get priceDisplay {
    if (price == null || price!.isEmpty) return '—';
    return 'Rs: $price';
  }

  PackageModel copyWith({String? status}) {
    return PackageModel(
      id: id,
      name: name,
      branchId: branchId,
      status: status ?? this.status,
      price: price,
      description: description,
      startingFrom: startingFrom,
      endingOn: endingOn,
      branch: branch,
      packageServices: packageServices,
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