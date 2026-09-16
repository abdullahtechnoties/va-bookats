import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/controllers/commissions_report_controller.dart';

class CommissionsReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommissionsReportController>(() => CommissionsReportController());
  }
}