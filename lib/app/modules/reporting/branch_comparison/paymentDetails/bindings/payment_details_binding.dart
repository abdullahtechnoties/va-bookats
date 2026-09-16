import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/paymentDetails/controllers/payment_details_controller.dart';


class BranchComparisonReportDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchComparisonReportDetailsController>(
      () => BranchComparisonReportDetailsController(),
    );
  }
}