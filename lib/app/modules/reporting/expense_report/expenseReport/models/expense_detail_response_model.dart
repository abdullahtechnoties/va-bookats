import 'package:va_bookats/network/response/pagination_helper.dart';
import 'expense_item_model.dart';

class ExpenseDetailResponseModel {
  final BranchDetailModel branch;
  final String fromDate;
  final String toDate;
  final List<ExpenseItemModel> expenses;
  final PaginationMeta paginationMeta;
  final String expenseCategoryId;

  ExpenseDetailResponseModel({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.expenses,
    required this.paginationMeta,
    required this.expenseCategoryId,
  });

  factory ExpenseDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final expensesPaginated = json['expenses'] as Map<String, dynamic>? ?? {};

    return ExpenseDetailResponseModel(
      branch: BranchDetailModel.fromJson(
        json['branch'] as Map<String, dynamic>? ?? {},
      ),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      expenses:
          (expensesPaginated['data'] as List?)
              ?.map((e) => ExpenseItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paginationMeta: PaginationMeta.fromJson(expensesPaginated),
      expenseCategoryId: json['expenseCategory_id']?.toString() ?? 'all',
    );
  }
}

class BranchDetailModel {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? phonePrimary;
  final String? address;

  BranchDetailModel({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.phonePrimary,
    this.address,
  });

  factory BranchDetailModel.fromJson(Map<String, dynamic> json) {
    return BranchDetailModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      address: json['address']?.toString(),
    );
  }
}
