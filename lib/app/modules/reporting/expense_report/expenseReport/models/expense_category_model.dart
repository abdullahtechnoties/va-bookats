class ExpenseCategoryModel {
  final String label;
  final dynamic value; // can be int or "all"

  ExpenseCategoryModel({required this.label, required this.value});

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      label: json['label']?.toString() ?? '',
      value: json['value'],
    );
  }

  String get displayValue => value.toString();
}
