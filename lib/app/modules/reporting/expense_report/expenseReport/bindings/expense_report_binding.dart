import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/controller/expense_report_controller.dart';

class ExpenseReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseReportController>(() => ExpenseReportController());
  }
}
