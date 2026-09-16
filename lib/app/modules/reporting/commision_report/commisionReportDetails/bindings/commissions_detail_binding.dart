import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commisionReportDetails/controller/commissions_detail_controller.dart';

class CommissionsDetailBinding extends Bindings {
  @override
  void dependencies() {
    final params = Get.parameters;
    Get.lazyPut<CommissionsDetailController>(
      () => CommissionsDetailController(
        branchId: int.parse(params['branch_id'] ?? '0'),
        fromDate: params['from_date'] ?? '',
        toDate: params['to_date'] ?? '',
        staffId: params['staff_id'],
      ),
    );
  }
}