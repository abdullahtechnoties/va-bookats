import 'package:va_bookats/models/service_model.dart';

/// Lightweight service item returned by `GET /data/services?branch_id=N`.
///
/// ```json
/// {
///   "label": "Hair Color",
///   "value": 2,
///   "default_price": "500.00",
///   "type": "normal",
///   "variations": []
/// }
/// ```
class DataServiceItem {
  final String? label;
  final int? value;
  final String? defaultPrice;
  final String? type;
  final List<ServiceVariation> variations;

  const DataServiceItem({
    this.label,
    this.value,
    this.defaultPrice,
    this.type,
    this.variations = const [],
  });

  factory DataServiceItem.fromJson(Map<String, dynamic> json) {
    final rawVariations = json['variations'];
    return DataServiceItem(
      label: json['label']?.toString(),
      value: _parseInt(json['value']),
      defaultPrice: json['default_price']?.toString(),
      type: json['type']?.toString(),
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

  bool get isVariationType => type?.toLowerCase() == 'variation';
  bool get isNormalType => type?.toLowerCase() == 'normal';
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}