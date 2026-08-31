import 'package:get/get.dart';

import '../controllers/branch_comparison_controller.dart';

class BranchComparisonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchComparisonController>(
      () => BranchComparisonController(),
    );
  }
}
