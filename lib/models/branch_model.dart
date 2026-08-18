/// A branch, returned in two shapes:
///
/// Dropdown (`/data/branches`):
/// ```json
/// { "label": "Glamour Touch Salon - Clifton Branch", "value": 2 }
/// ```
///
/// Nested in a category (`branch` object):
/// ```json
/// { "id": 1, "name": "Branch" }
/// ```
///
/// Both shapes are handled gracefully by falling back between the key pairs.
class BranchModel {
  final int? value;
  final String? label;

  const BranchModel({this.value, this.label});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      value: _parseInt(json['value']) ?? _parseInt(json['id']),
      label: json['label']?.toString() ?? json['name']?.toString(),
    );
  }

  String get displayLabel => label ?? '';

  bool get isValid => value != null && (label?.isNotEmpty ?? false);

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
