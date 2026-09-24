class BranchModel {
  final String label;
  final int value;

  BranchModel({required this.label, required this.value});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value'].toString()) ?? 0,
    );
  }
}
