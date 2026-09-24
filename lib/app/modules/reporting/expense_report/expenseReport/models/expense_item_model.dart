class ExpenseItemModel {
  final int id;
  final int branchId;
  final int categoryId;
  final int createdBy;
  final String name;
  final double amount;
  final String date;
  final String status;
  final String? description;
  final String? billUrl;
  final String? billThumbUrl;
  final ExpenseCategoryDetail? category;

  ExpenseItemModel({
    required this.id,
    required this.branchId,
    required this.categoryId,
    required this.createdBy,
    required this.name,
    required this.amount,
    required this.date,
    required this.status,
    this.description,
    this.billUrl,
    this.billThumbUrl,
    this.category,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      createdBy: int.tryParse(json['created_by']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      billUrl: json['bill_url']?.toString(),
      billThumbUrl: json['bill_thumb_url']?.toString(),
      category: json['category'] != null
          ? ExpenseCategoryDetail.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ExpenseCategoryDetail {
  final int id;
  final String name;
  final String status;
  final int branchId;

  ExpenseCategoryDetail({
    required this.id,
    required this.name,
    required this.status,
    required this.branchId,
  });

  factory ExpenseCategoryDetail.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
    );
  }
}
