import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/controllers/inventory_list_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class VariationsController extends InventoryListController {
  @override
  String get resourceBase => ApiPath.productVariations;

  @override
  String get permResource => 'product-variations';

  @override
  String get trPrefix => 'variations';

  @override
  String get addRoute => Routes.ADD_VARIATIONS;
}
