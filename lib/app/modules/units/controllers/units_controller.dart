import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/controllers/inventory_list_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class UnitsController extends InventoryListController {
  @override
  String get resourceBase => ApiPath.units;

  @override
  String get permResource => 'units';

  @override
  String get trPrefix => 'units';

  @override
  String get addRoute => Routes.ADD_UNIT;
}
