class BranchOption {
  final String label;
  final int value;

  BranchOption({required this.label, required this.value});

  factory BranchOption.fromJson(Map<String, dynamic> json) {
    return BranchOption(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}