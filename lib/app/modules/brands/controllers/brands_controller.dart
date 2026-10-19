import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/controllers/inventory_list_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class BrandsController extends InventoryListController {
  @override
  String get resourceBase => ApiPath.brands;

  @override
  String get permResource => 'brands';

  @override
  String get trPrefix => 'brands';

  @override
  String get addRoute => Routes.ADD_BRAND;
}
