class ExpenseMonthlyDataModel {
  final double totalExpense;
  final String branchName;
  final String from;
  final String to;
  final int branchId;
  final String expenseCategoryId;

  ExpenseMonthlyDataModel({
    required this.totalExpense,
    required this.branchName,
    required this.from,
    required this.to,
    required this.branchId,
    required this.expenseCategoryId,
  });

  factory ExpenseMonthlyDataModel.fromJson(Map<String, dynamic> json) {
    return ExpenseMonthlyDataModel(
      totalExpense:
          double.tryParse(json['total_expense']?.toString() ?? '0') ?? 0.0,
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      expenseCategoryId: json['expense_category_id']?.toString() ?? 'all',
    );
  }
}
