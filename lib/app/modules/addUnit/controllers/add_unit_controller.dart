import 'package:va_bookats/controllers/inventory_form_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class AddUnitController extends InventoryFormController {
  @override
  String get resourceBase => ApiPath.units;

  @override
  String get trPrefix => 'addUnit';
}
