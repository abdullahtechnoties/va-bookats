import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/controllers/inventory_list_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class TagsController extends InventoryListController {
  @override
  String get resourceBase => ApiPath.tags;

  @override
  String get permResource => 'tags';

  @override
  String get trPrefix => 'tags';

  @override
  String get addRoute => Routes.ADD_TAG;
}
