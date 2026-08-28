class BranchInfo {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? phonePrimary;
  final String? address;

  BranchInfo({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.phonePrimary,
    this.address,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary'],
      phonePrimary: json['phone_primary'],
      address: json['address'],
    );
  }
}