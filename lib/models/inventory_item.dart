import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/utilities/image_path_helper.dart';

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// One value inside a variation (e.g. "Small").
class InventoryValue {
  final int? id;
  final String? name;

  const InventoryValue({this.id, this.name});

  factory InventoryValue.fromJson(Map<String, dynamic> json) {
    return InventoryValue(
      id: _parseInt(json['id']) ?? _parseInt(json['value']),
      name: json['name']?.toString() ?? json['label']?.toString(),
    );
  }
}

/// A single row of any inventory lookup list: brands, product categories,
/// tags, units, product variations.
///
/// All five list endpoints share the paginated shape
/// `{current_page, data: [{id, name, branch_id, status, branch, …}], …}`
/// with per-resource extras (logo/image urls, parent_id, values[]).
/// Every field is parsed defensively so partial payloads never crash.
class InventoryItem {
  final int? id;
  final String? name;
  final int? branchId;
  final String? status;
  final BranchModel? branch;
  final String? imageUrl;
  final String? thumbUrl;
  final int? parentId;
  final List<InventoryValue> values;

  const InventoryItem({
    this.id,
    this.name,
    this.branchId,
    this.status,
    this.branch,
    this.imageUrl,
    this.thumbUrl,
    this.parentId,
    this.values = const [],
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'];
    return InventoryItem(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      branchId: _parseInt(json['branch_id']),
      status: json['status']?.toString(),
      branch: json['branch'] is Map
          ? BranchModel.fromJson(
              Map<String, dynamic>.from(json['branch'] as Map),
            )
          : null,
      imageUrl: _img(
        json['logo_url']?.toString() ?? json['image_url']?.toString(),
      ),
      thumbUrl: _img(
        json['logo_thumb_url']?.toString() ??
            json['image_thumb_url']?.toString(),
      ),
      parentId: _parseInt(json['parent_id']),
      values: rawValues is List
          ? rawValues
                .whereType<Map>()
                .map(
                  (e) => InventoryValue.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get isActive => status?.toLowerCase() == 'active';

  String get branchName => branch?.displayLabel ?? '';

  /// Display image: thumbnail first, then full image.
  String? get displayUrl => thumbUrl ?? imageUrl;

  String get valuesLabel =>
      values.map((v) => v.name ?? '').where((n) => n.isNotEmpty).join(', ');

  InventoryItem copyWith({
    String? status,
    String? name,
    String? imageUrl,
    String? thumbUrl,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      branchId: branchId,
      status: status ?? this.status,
      branch: branch,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      parentId: parentId,
      values: values,
    );
  }

  static String? _img(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return getImage(raw);
  }
}
