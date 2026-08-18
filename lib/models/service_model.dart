import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// A service variation, e.g. `{ id, service_id, name, price }`.
class ServiceVariation {
  final int? id;
  final int? serviceId;
  final String? name;
  final String? price;

  const ServiceVariation({
    this.id,
    this.serviceId,
    this.name,
    this.price,
  });

  factory ServiceVariation.fromJson(Map<String, dynamic> json) {
    return ServiceVariation(
      id: _parseInt(json['id']),
      serviceId: _parseInt(json['service_id']),
      name: json['name']?.toString(),
      price: json['price']?.toString(),
    );
  }
}

/// A service, as returned by the services endpoints:
///
/// ```json
/// {
///   "id": 2,
///   "name": "Hair Color",
///   "service_duration": "60 min",
///   "category_id": 1,
///   "branch_id": 1,
///   "status": "active",
///   "image": null,
///   "type": "normal",
///   "default_price": "500",
///   "description": "Test",
///   "branch": { "id": 1, "name": "Branch" },
///   "category": { "id": 1, "name": "Hair Care" },
///   "variations": []
/// }
/// ```
///
/// Every field is parsed defensively so partial payloads never crash the app.
class ServiceModel {
  final int? id;
  final String? name;
  final String? serviceDuration;
  final int? categoryId;
  final int? branchId;
  final String? status;
  final String? image;
  final String? type;
  final String? defaultPrice;
  final String? description;
  final BranchModel? branch;
  final ServiceCategoryModel? category;
  final List<ServiceVariation> variations;

  const ServiceModel({
    this.id,
    this.name,
    this.serviceDuration,
    this.categoryId,
    this.branchId,
    this.status,
    this.image,
    this.type,
    this.defaultPrice,
    this.description,
    this.branch,
    this.category,
    this.variations = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final rawBranch = json['branch'];
    final rawCategory = json['category'];
    final rawVariations = json['variations'];

    return ServiceModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      serviceDuration: json['service_duration']?.toString(),
      categoryId: _parseInt(json['category_id']),
      branchId: _parseInt(json['branch_id']),
      status: json['status']?.toString(),
      image: json['image']?.toString(),
      type: json['type']?.toString(),
      defaultPrice: json['default_price']?.toString(),
      description: json['description']?.toString(),
      branch: rawBranch is Map
          ? BranchModel.fromJson(Map<String, dynamic>.from(rawBranch))
          : null,
      category: rawCategory is Map
          ? ServiceCategoryModel.fromJson(
              Map<String, dynamic>.from(rawCategory),
            )
          : null,
      variations: rawVariations is List
          ? rawVariations
                .whereType<Map>()
                .map(
                  (e) => ServiceVariation.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get isActive => status?.toLowerCase() == 'active';

  String get branchName => branch?.label ?? '';

  String get categoryName => category?.name ?? '';

  String get imageUrl => image ?? '';

  bool get isVariationType => type?.toLowerCase() == 'variation';

  bool get isNormalType => type?.toLowerCase() == 'normal';

  String get statusDisplay =>
      isActive ? 'services.card.active'.trns() : 'services.card.inactive'.trns();

  /// Shown in the price slot of the card — either the default price, a
  /// variations count, or a dash when neither is available.
  String get priceOrVariationsDisplay {
    final price = defaultPrice;
    if (price != null && price.isNotEmpty) return 'Rs: $price';
    if (variations.isNotEmpty) {
      return '${variations.length} ${'services.card.variationsLabel'.trns()}';
    }
    return '—';
  }

  ServiceModel copyWith({String? status}) {
    return ServiceModel(
      id: id,
      name: name,
      serviceDuration: serviceDuration,
      categoryId: categoryId,
      branchId: branchId,
      status: status ?? this.status,
      image: image,
      type: type,
      defaultPrice: defaultPrice,
      description: description,
      branch: branch,
      category: category,
      variations: variations,
    );
  }

}
   int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }