import 'package:va_bookats/controllers/inventory_form_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class AddTagController extends InventoryFormController {
  @override
  String get resourceBase => ApiPath.tags;

  @override
  String get trPrefix => 'addTag';
}
