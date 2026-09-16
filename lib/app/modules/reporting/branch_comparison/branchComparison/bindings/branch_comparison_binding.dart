import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/controllers/branch_comparison_controller.dart';

class BranchComparisonReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchComparisonReportController>(
      () => BranchComparisonReportController(),
    );
  }
}