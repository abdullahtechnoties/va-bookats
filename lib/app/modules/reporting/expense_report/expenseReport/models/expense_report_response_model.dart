import 'branch_model.dart';
import 'expense_category_model.dart';
import 'expense_monthly_data_model.dart';

class ExpenseReportResponseModel {
  final List<BranchModel> branches;
  final int branchId;
  final String fromDate;
  final String toDate;
  final List<ExpenseMonthlyDataModel> monthlyData;
  final List<ExpenseCategoryModel> expenseCategories;
  final String expenseCategoryId;

  ExpenseReportResponseModel({
    required this.branches,
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
    required this.expenseCategories,
    required this.expenseCategoryId,
  });

  factory ExpenseReportResponseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseReportResponseModel(
      branches:
          (json['branches'] as List?)
              ?.map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData:
          (json['monthlyData'] as List?)
              ?.map(
                (e) =>
                    ExpenseMonthlyDataModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      expenseCategories:
          (json['expenseCategories'] as List?)
              ?.map(
                (e) => ExpenseCategoryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      expenseCategoryId: json['expenseCategory_id']?.toString() ?? 'all',
    );
  }
}
