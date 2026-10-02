class ExpenseMonthlyDataModel {
  final double totalExpense;
  final String branchName;
  final String from;
  final String to;
  final int branchId;
  final String expenseCategoryId;
  // currency_symbol
  final String? currencySymbol;

  /// Every raw field from the API row, so report columns can be discovered
  /// dynamically (unknown future keys included).
  final Map<String, dynamic> rawFields;

  ExpenseMonthlyDataModel({
    required this.totalExpense,
    required this.branchName,
    required this.from,
    required this.to,
    required this.branchId,
    required this.expenseCategoryId,
    this.currencySymbol,
    Map<String, dynamic>? rawFields,
  }) : rawFields = rawFields ?? const {};

  factory ExpenseMonthlyDataModel.fromJson(Map<String, dynamic> json) {
    return ExpenseMonthlyDataModel(
      totalExpense:
          double.tryParse(json['total_expense']?.toString() ?? '0') ?? 0.0,
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      currencySymbol: json['currency_symbol']?.toString() ?? '\$',
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      expenseCategoryId: json['expense_category_id']?.toString() ?? 'all',
      rawFields: Map<String, dynamic>.from(json),
    );
  }
}
