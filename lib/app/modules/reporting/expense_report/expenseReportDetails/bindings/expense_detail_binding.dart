import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReportDetails/controller/expense_detail_controller.dart';

class ExpenseDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseDetailController>(() => ExpenseDetailController());
  }
}
