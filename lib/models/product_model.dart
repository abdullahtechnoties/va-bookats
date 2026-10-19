import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/utilities/image_path_helper.dart';

/// A product gallery image. URLs go through [getImage] because the API
/// sometimes returns relative paths instead of full URLs.
class ProductMedia {
  final int? id;
  final String? fileName;
  final String? url;
  final String? thumbnailUrl;

  const ProductMedia({this.id, this.fileName, this.url, this.thumbnailUrl});

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      id: _parseInt(json['id']),
      fileName: json['file_name']?.toString(),
      url: _imageUrl(json['url']?.toString()),
      thumbnailUrl: _imageUrl(json['thumbnail_url']?.toString()),
    );
  }

  /// Display image: thumbnail first, then full image.
  String? get displayUrl => thumbnailUrl ?? url;
}

/// A product category / tag (pivot-wrapped in details responses).
class ProductLabel {
  final int? id;
  final String? name;

  const ProductLabel({this.id, this.name});

  factory ProductLabel.fromJson(Map<String, dynamic> json) {
    return ProductLabel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

/// One product variation value (e.g. "Spray", "100ml", "Small").
class VariationValue {
  final int? id;
  final String? name;

  const VariationValue({this.id, this.name});

  factory VariationValue.fromJson(Map<String, dynamic> json) {
    return VariationValue(
      id: _parseInt(json['id']) ?? _parseInt(json['value']),
      name: json['name']?.toString() ?? json['label']?.toString(),
    );
  }
}

/// A single product variant (SKU row in the details page).
class ProductVariant {
  final int? id;
  final String? price;
  final int? stock;
  final String? sku;
  final String? code;
  final List<VariationValue> variationValues;

  const ProductVariant({
    this.id,
    this.price,
    this.stock,
    this.sku,
    this.code,
    this.variationValues = const [],
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final rawValues = json['variation_values'];
    return ProductVariant(
      id: _parseInt(json['id']),
      price: json['price']?.toString(),
      stock: _parseInt(json['stock']),
      sku: json['sku']?.toString(),
      code: json['code']?.toString(),
      variationValues: rawValues is List
          ? rawValues
                .whereType<Map>()
                .map(
                  (e) => VariationValue.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  /// "Spray / 100ml / Small".
  String get displayName => variationValues
      .map((v) => v.name ?? '')
      .where((n) => n.isNotEmpty)
      .join(' / ');
}

/// A product, as returned by the products endpoints.
///
/// The list endpoint returns a slim shape; `GET /products/{id}` adds
/// `description`, brand/unit/categories/tags/variants/media.
///
/// Every field is parsed defensively so partial payloads never crash the app.
class ProductModel {
  final int? id;
  final String? name;
  final int? branchId;
  final String? status;
  final String? productType;
  final String? price;
  final int? stock;
  final String? sku;
  final String? code;
  final String? shortDescription;
  final String? description;
  final String? brandName;
  final int? brandId;
  final String? unitName;
  final int? unitId;
  final BranchModel? branch;
  final List<ProductMedia> media;
  final List<ProductLabel> categories;
  final List<ProductLabel> tags;
  final List<ProductVariant> variants;

  const ProductModel({
    this.id,
    this.name,
    this.branchId,
    this.status,
    this.productType,
    this.price,
    this.stock,
    this.sku,
    this.code,
    this.shortDescription,
    this.description,
    this.brandName,
    this.brandId,
    this.unitName,
    this.unitId,
    this.branch,
    this.media = const [],
    this.categories = const [],
    this.tags = const [],
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawBrand = json['brand'];
    final rawUnit = json['unit'];

    int? idOf(dynamic raw, dynamic fallback) {
      if (raw is Map) {
        final v = _parseInt(raw['id']);
        if (v != null) return v;
      }
      return _parseInt(fallback);
    }

    return ProductModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      branchId: _parseInt(json['branch_id']),
      status: json['status']?.toString(),
      productType: json['product_type']?.toString(),
      price: json['price']?.toString(),
      stock: _parseInt(json['stock']),
      sku: json['sku']?.toString(),
      code: json['code']?.toString(),
      shortDescription: json['short_description']?.toString(),
      description: json['description']?.toString(),
      brandName: rawBrand is Map ? rawBrand['name']?.toString() : null,
      brandId: idOf(rawBrand, json['brand_id']),
      unitName: rawUnit is Map ? rawUnit['name']?.toString() : null,
      unitId: idOf(rawUnit, json['unit_id']),
      branch: json['branch'] is Map
          ? BranchModel.fromJson(
              Map<String, dynamic>.from(json['branch'] as Map),
            )
          : null,
      media: _parseMedia(json['media']),
      categories: _parseLabels(json['categories']),
      tags: _parseLabels(json['tags']),
      variants: json['variants'] is List
          ? (json['variants'] as List)
                .whereType<Map>()
                .map(
                  (e) => ProductVariant.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get isActive => status?.toLowerCase() == 'active';

  String get branchName => branch?.displayLabel ?? '';

  /// First gallery image for card thumbnails (thumb preferred).
  String? get coverUrl =>
      media.isEmpty ? null : (media.first.displayUrl);

  /// Plain-text description (API returns HTML like "<p>Demo</p>").
  String get plainDescription {
    final raw = description ?? shortDescription ?? '';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String get categoryNames => categories
      .map((c) => c.name ?? '')
      .where((n) => n.isNotEmpty)
      .join(', ');

  String get tagNames => tags
      .map((t) => t.name ?? '')
      .where((n) => n.isNotEmpty)
      .join(', ');

  /// Category / tag ids for form pre-selection.
  List<int> get categoryIds => categories
      .map((c) => c.id)
      .whereType<int>()
      .toList();

  List<int> get tagIds =>
      tags.map((t) => t.id).whereType<int>().toList();

  ProductModel copyWith({String? status}) {
    return ProductModel(
      id: id,
      name: name,
      branchId: branchId,
      status: status ?? this.status,
      productType: productType,
      price: price,
      stock: stock,
      sku: sku,
      code: code,
      shortDescription: shortDescription,
      description: description,
      brandName: brandName,
      brandId: brandId,
      unitName: unitName,
      unitId: unitId,
      branch: branch,
      media: media,
      categories: categories,
      tags: tags,
      variants: variants,
    );
  }

  static List<ProductMedia> _parseMedia(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ProductMedia.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<ProductLabel> _parseLabels(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ProductLabel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// A `{label, value}` dropdown option from the `/data/*` lookup endpoints.
/// Product categories additionally nest `children` (parent/child tree).
class ProductLookup {
  final String label;
  final int value;
  final List<ProductLookup> children;

  const ProductLookup({
    required this.label,
    required this.value,
    this.children = const [],
  });

  factory ProductLookup.fromJson(Map<String, dynamic> json) {
    // List shape: {label, value, children?}; nested shape: {id, name, ...}.
    final rawChildren = json['children'];
    return ProductLookup(
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      value:
          _parseInt(json['value']) ??
          _parseInt(json['id']) ??
          0,
      children: rawChildren is List
          ? rawChildren
                .whereType<Map>()
                .map(
                  (e) => ProductLookup.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  /// Self + descendants flattened for pickers (`Parent › Child` labels).
  List<ProductLookup> get flattened {
    final out = <ProductLookup>[this];
    for (final child in children) {
      for (final flat in child.flattened) {
        out.add(
          ProductLookup(
            label: '$label › ${flat.label}',
            value: flat.value,
            children: flat.children,
          ),
        );
      }
    }
    return out;
  }
}

/// A variation type together with its selectable values (from the
/// runtime-create response or the best-effort values probe).
class VariationTypeWithValues {
  final int id;
  final String name;
  final List<VariationValue> values;

  VariationTypeWithValues({
    required this.id,
    required this.name,
    List<VariationValue>? values,
  }) : values = values ?? [];

  factory VariationTypeWithValues.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'] ?? json['variation_values'];
    return VariationTypeWithValues(
      id:
          _parseInt(json['id']) ??
          _parseInt(json['value']) ??
          0,
      name: json['name']?.toString() ?? json['label']?.toString() ?? '',
      values: rawValues is List
          ? rawValues
                .whereType<Map>()
                .map(
                  (e) => VariationValue.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .where((v) => v.id != null)
                .toList()
          : [],
    );
  }
}

/// Paginated products result (+ filter branches, like packages).
class ProductsPage {
  final List<ProductModel> products;
  final PaginationMeta meta;
  final List<BranchModel> branches;

  const ProductsPage({
    required this.products,
    required this.meta,
    this.branches = const [],
  });
}

String? _imageUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return getImage(raw);
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
